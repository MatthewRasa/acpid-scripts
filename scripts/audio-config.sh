#!/bin/bash
declare -r conf_path=~/.config/devices/sound_

if [[ $(ls ${conf_path}* | wc -l) -eq 0 ]]; then
	echo "No 'sound_' config files found under $(dirname "$conf_path")."
	exit 1
fi

conf=
case "$1" in
	detect)
		[[ $(echo "$(xrandr | grep ' connected' | awk '{ print $1 }')" | wc -w) \
			-gt 1 ]] && conf=secondary || conf=primary
		;;
	primary)
		conf=primary
		;;
	secondary)
		conf=secondary
		;;
	*)
		echo "Usage: audio-config <detect|primary|secondary>"
		exit 1
esac

cp "$conf_path$conf" ~/.asoundrc
alsactl restore >/dev/null 2>&1
exit 0
