#!/bin/bash
declare -r acpidir="acpi_events"
declare -r udevdir="udev_rules"
declare -r scriptdir="scripts"
declare -r acpiroot="/etc/acpi"
declare -r udevroot="/etc/udev/rules.d"
declare -r scriptroot="/usr/local/bin"

if [[ "$EUID" -ne 0 ]]; then
		echo "Script must be run as root."
		exit 1
fi

# Add acpi events
cp -r $acpidir/* "$acpiroot"

# Add udev rules
cp $udevdir/* "$udevroot"

# Copy scripts to /usr/local/bin
for script in $(ls $scriptdir/*); do
		cp "$script" "$scriptroot/$(echo "$(basename $script)" | sed 's/\.sh//g')"
done
