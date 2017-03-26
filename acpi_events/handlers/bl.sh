#!/bin/bash
declare -r brightness="/sys/class/backlight/intel_backlight/brightness"
declare -ri min=1
declare -ri max=$(<"/sys/class/backlight/intel_backlight/max_brightness")
declare -ri step=104

case $1 in
	-)
		declare -ri new=$(($(<$brightness) - $step))
		echo $([[ $new -gt $min ]] && echo $new || echo $min) >"$brightness"
		;;
	+)
		declare -ri new=$(($(<$brightness) + $step))
		echo $([[ $new -lt $max ]] && echo $new || echo $max) >"$brightness"
		;;
esac
