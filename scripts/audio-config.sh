declare -r config=~/.config/devices
declare -r primary="sound_primary"
declare -r secondary="sound_secondary"

if [[ ! -f "$config/$primary" || ! -f "$config/$secondary" ]]; then
	echo "Must create $config/[$primary|$secondary] files."
	exit 1
fi

case "$1" in
	primary)
		cp "$config/$primary" ~/.asoundrc
		;;
	secondary)
		cp "$config/$secondary" ~/.asoundrc
		;;
	*)
		echo "Usage: audio-config <primary|secondary>"
		exit 1
esac

alsactl restore >/dev/null 2>&1
exit 0
