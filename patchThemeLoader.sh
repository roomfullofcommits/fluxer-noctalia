#! /bin/bash

echo
if ! which asar > /dev/null 2>&1; then
	echo "asar not found, please install asar"
	echo "Exiting"
	exit 1
fi

pathMessage="Fluxer install path:"

while true; do
	
	which fluxer > /dev/null 2>&1
	foundStable=$? 
	which fluxer-canary > /dev/null 2>&1
	foundCanary=$?

	binName=0
	if [ $foundStable -eq 0 ]; then
		echo "found fluxer stable at $(which fluxer)"
		binName=fluxer
	fi
	if [ $foundCanary -eq 0 ]; then
                echo "found fluxer canary at $(which fluxer-canary)"
		binName=fluxer-canary
	fi

	echo
	
	if [ $foundStable -eq 0 ] && [ $foundCanary -eq 0 ]; then while true; do
		echo "Which one do you want to install the noctalia integration for?"
		echo "1 - fluxer stable"
		echo "2 - fluxer canary"
		read -e input && echo

		if ! [[ -z "$input" ]]; then
			if [ $input -eq 1 ]; then binName=fluxer; break
			elif [ $input -eq 2 ]; then binName=fluxer-canary; break
			else echo "wrong input"; fi
		fi
	done; fi

	fluxerDir="$(dirname $(readlink -f $(which $binName)))"
	appAsarPath="$(find "$fluxerDir" -name '*.asar')"
	if ! [[ -z "$appAsarPath" ]] && test -e "$appAsarPath"; then
		echo "Found app.asar at $appAsarPath" && echo
		pathMessage="Fluxer install path [$fluxerDir]:"
	else
		echo "Warning: Didn't find Fluxer install path automatically" && echo
	fi

	echo $pathMessage
	read -e input && echo

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
	sudo cp "$appAsarPath" "$appAsarPath.bak"
	if ! [ $? -eq 0 ]; then
		echo "Copy failed, try running this script with sudo"
		echo "Exiting"
		exit 3
	fi
fi

sudo cp "$appAsarPath.bak" "$appAsarPath"
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

indexJsPath="$tempDir/dist/main/MainApp.js"
if ! test -e "$indexJsPath"; then
	indexJsPath="$tempDir/src-electron/dist/main/window.js"
fi
if ! test -e "$indexJsPath"; then
	echo "Couldn't find index.js, exiting"
	exit 4
fi

echo // THEME_LOADER_MAGIC >> "$indexJsPath"
cat themeLoader.js >> "$indexJsPath"

sudo asar p "$tempDir" "$appAsarPath"

if grep --silent THEME_LOADER_MAGIC "$appAsarPath"; then
	echo "Patch successful!"
else
	echo "Patch failed"
fi

#rm -r "$tempDir"

configFolder=0
if [ $binName = fluxer ]; then configFolder=fluxer
else configFolder=fluxercanary; fi

touch "${XDG_CONFIG_HOME:-$HOME/.config}/$configFolder/theme.css"
if ! [ $? -eq 0 ]; then
	echo "Couldn't create theme.css in ${XDG_CONFIG_HOME:-$HOME/.config}/$configFolder/, exiting"
	exit 5
else
	echo "created ${XDG_CONFIG_HOME:-$HOME/.config}/$configFolder/theme.css"
fi
cp -sf $PWD/theme-template.css "${XDG_CONFIG_HOME:-$HOME/.config}/$configFolder/"

