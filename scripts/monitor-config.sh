#!/bin/bash
declare -ra resolutions=("1280x768" "1920x1080")
declare -r external_config=~/.config/devices/monitor_config.txt
declare -r currmode_config=~/.config/devices/current_mode.txt
declare -a displays=($(xrandr | grep " connected" | awk '{ print $1 }'))

declare -r external_res=$([[ -f "$external_config" ]] &&
	echo "$(<"$external_config")" || echo "--auto")

declare -r currmode=$([[ -f "$currmode_config" ]] &&
	echo "$(<"$currmode_config")" || echo "")

get_target_res() {
	local target=""
	if [[ "$1" == "auto" ]]; then
		target="--auto"
	else
		for res in "${resolutions[@]}"; do
			[[ "$1" == "$res" ]] && target="--mode $res"
		done
	fi
	echo "$target"
}

set_currmode() {
	mkdir -p "$(dirname "$currmode_config")"
	echo $1 >"$currmode_config"
}

case "$1" in
	primary)
		declare comm="xrandr --output ${displays[0]} --auto"
		for disp in ${displays[@]:1}; do
			comm="$comm --output $disp --off"
		done
		;;
	secondary)
		declare comm="xrandr"
		declare -ri last=$((${#displays[@]} - 1))
		for disp in ${displays[@]:0:$last}; do
			comm="$comm --output $disp --off"
		done
		comm="$comm --output ${displays[$last]} $external_res"
		;;
	extend|extended)
		declare comm="xrandr --output ${displays[0]} --auto"
		declare prev=${displays[0]}
		for disp in ${displays[@]:1}; do
			comm="$comm --output $disp $external_res --right-of $prev"
			prev=$disp
		done
		;;
	set-external)
		declare target="$(get_target_res "$2")"
		while [[ -z "$target" ]]; do
			echo -e "Select external resolution:\n\tauto"
			for res in "${resolutions[@]}"; do
				echo -e "\t$res"
			done
			echo -n "> "
			read target
			target="$(get_target_res "$target")"
		done

		mkdir -p "$(dirname "$external_config")"
		echo "$target" >"$external_config"
		[[ -n "$currmode" ]] && $0 "$currmode"
		exit 0
		;;
	*)
		echo -n "Usage: monitor-config <primary|secondary|extend|set-external [auto"
		for res in "${resolutions[@]}"; do
			echo -n "|$res"
		done
		echo "]>"
		exit 1
esac

set_currmode "$1"
$comm
herbstclient reload
exit 0
