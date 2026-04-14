(async()=>{
	const fs = await import('fs');

    const themeFile = (process.env["XDG_CONFIG_HOME"] || `${process.env["HOME"]}/.config`) + "/fluxer/theme.css";
    console.log(themeFile);

	fs.watchFile(themeFile, {persistent: false, interval: 200}, loadCSS);

	const intervalID = setInterval(()=>mainWindow?.webContents && clearInterval(intervalID) || mainWindow.webContents.on('dom-ready', loadCSS), 10);

	async function loadCSS() {

		const theme = await new Promise(
			(resolve, reject) => fs.readFile(themeFile, {encoding: "utf8"}, (err, data) => { if (err) return reject(err); resolve(data); })
		);
		mainWindow.webContents.executeJavaScript(`
			{
				const theme = ${JSON.stringify(theme)};

				let styleEl = document.querySelector("style#themeFile");
				if (!styleEl) {
					styleEl = document.createElement("style");
					styleEl.id = "themeFile";
					document.head.appendChild(styleEl);
				}

				styleEl.textContent = theme;
			}
		`)

	}
})();

