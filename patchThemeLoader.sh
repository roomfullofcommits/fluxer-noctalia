#! /bin/bash

echo
if ! which asar > /dev/null; then
	echo "asar not found, please install asar"
	echo "Exiting"
	exit 1
fi

pathMessage="Fluxer install path:"

while true; do
	appAsarPath="$(grep -o '/.*asar' $(which fluxer || echo /dev/null))"
	if ! [[ -z "$appAsarPath" ]] && test -e "$appAsarPath"; then
		echo "Found app.asar at $appAsarPath" && echo
		pathMessage="Fluxer install path [$(dirname "$appAsarPath")]:"
	else
		echo "Warning: Didn't find Fluxer install path automatically" && echo
	fi

	echo $pathMessage
	read -e input

	if ! [[ -z "$input" ]]; then
		fluxerDir="$input"
		echo "looking for app.asar in $fluxerDir"

		if test -e "$fluxerDir/resources/app.asar"; then
			appAsarPath="$fluxerDir/resources/app.asar"
			echo "found app.asar at $appAsarPath" && echo
			break
		elif test -e "$fluxerDir/app.asar"; then
			appAsarPath="$fluxerDir/app.asar"
			echo "found app.asar at $appAsarPath" && echo
			break
		else
			echo "didnt find app.asar, is the fluxer path correct?"
		fi
	elif ! [[ -z "$appAsarPath" ]] && test -e "$appAsarPath"; then
		break
	fi
done

if ! grep --silent THEME_LOADER_MAGIC "$appAsarPath"; then
	echo "app looks unpatched, making backup"
	cp "$appAsarPath" "$appAsarPath.bak"
	if ! [ $? -eq 0 ]; then
		echo "Copy failed, try running this script with sudo"
		echo "Exiting"
		exit 3
	fi
fi

cp "$appAsarPath.bak" "$appAsarPath"
if ! [ $? -eq 0 ]; then
	echo "Copy failed, try running this script with sudo"
	echo "Exiting"
	exit 3
fi

tempDir="$(mktemp -d)"
if ! [ $? -eq 0 ]; then
	echo "Couldn't create temp directory, exiting"
	exit 2
fi
asar e "$appAsarPath" "$tempDir"

indexJsPath="$tempDir/dist/main/index.js"
if ! test -e "$indexJsPath"; then
	indexJsPath="$tempDir/src-electron/dist/main/index.js"
fi
if ! test -e "$indexJsPath"; then
	echo "Couldn't find index.js, exiting"
	exit 4
fi

echo // THEME_LOADER_MAGIC >> "$indexJsPath"
cat themeLoader.js >> "$indexJsPath"

asar p "$tempDir" "$appAsarPath"

if grep --silent THEME_LOADER_MAGIC "$appAsarPath"; then
	echo "Patch successful!"
else
	echo "Patch failed"
fi

# rm -r "$tempDir"

touch "${XDG_CONFIG_HOME:-$HOME/.config}/fluxer/theme.css"
if ! [ $? -eq 0 ]; then
	echo "Couldn't create theme.css in ${XDG_CONFIG_HOME:-$HOME/.config}/fluxer/, exiting"
	exit 5
else
	echo "created ${XDG_CONFIG_HOME:-$HOME/.config}/fluxer/theme.css"
fi
cp -sf $PWD/theme-template.css "${XDG_CONFIG_HOME:-$HOME/.config}/fluxer/"

