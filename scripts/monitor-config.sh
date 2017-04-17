#!/bin/bash
declare -r lckfile=~/.config/devices/.monitor-config.lck
declare hcreload=true

get_connected() {
	echo "$(xrandr | grep ' connected' | awk '{ print $1 }')"
}

get_active() {
	echo "$(xrandr --listactivemonitors | grep '/' | awk '{ print $4 }')"
}

do_reload() {
	if ${hcreload}; then
		touch "${lckfile}"
		herbstclient reload
	fi
}

set_primary() {
	local -r active=$(get_active)
	local -r disp0="$(echo $(get_connected) | awk '{print $1 }')"
	local -r disp1="$(echo ${active} | awk '{ print $NF }')"
	if [[ "${active}" != "${disp0}" ]]; then
		xrandr --output ${disp0} --auto --output ${disp1} --off
		do_reload
	fi
	return 0
}

set_secondary() {
	local -r connected=$(get_connected)
	local -r disp0="$(echo ${connected} | awk '{ print $1 }')"
	local -r disp1="$(echo ${connected} | awk '{ print $2 }')"
	if [[ $(echo ${connected} | wc -w ) -ne 2 ]]; then
		echo "Second display not connected."
		return 1
	elif [[ "$(get_active)" != "${disp1}" ]]; then
		xrandr --output ${disp0} --off --output ${disp1} --auto
		do_reload
		return 0
	fi
}

set_extend() {
	local -r connected=$(get_connected)
	local -r disp0="$(echo ${connected} | awk '{ print $1 }')"
	local -r disp1="$(echo ${connected} | awk '{ print $2 }')"
	if [[ $(echo ${connected} | wc -w ) -ne 2 ]]; then
		echo "Second display not connected."
		return 1
	elif [[ "$(get_active)" != "${connected}" ]]; then
			xrandr --output ${disp0} --auto --output ${disp1} --auto \
					--right-of ${disp0} --auto
		do_reload
		return 0
	fi
}

display_help() {
	echo "Usage: monitor-config <detect|primary|secondary|extend>"
}

# Trap monitor-config call from herbstclient reload
if [[ -f "${lckfile}" ]]; then
	rm -f "${lckfile}"
	exit 0
fi

# Parse options
while [[ $# -gt 0 ]]; do
	case "$1" in
	--no-reload)
		hcreload=false
		;;
	*)
		break
		;;
	esac
	shift 1
done

# Execute command
declare -i rtn=0
case "$1" in
	detect)
		[[ $(echo $(get_connected) | wc -w) -gt 1 ]] \
			&& set_extend || set_primary
		rtn=$?
		;;
	primary)
		set_primary
		rtn=$?
		;;
	secondary)
		set_secondary
		rtn=$?
		;;
	extend|extended)
		set_extend
		rtn=$?
		;;
	*)
		display_help
		rtn=1
		;;
esac
exit $rtn
