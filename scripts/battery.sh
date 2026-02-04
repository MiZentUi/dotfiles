#!/bin/bash

low_level=10
crit_level=5

low_flag=1
crit_flag=1

while [ 1 ] 
do
    battery_level=`acpi | grep -oP '(?<=, )\d+(?=%)'`
    if [[ $battery_level -le $low_level && $low_flag -eq 1 ]]
    then
        notify-send "Battery low. Battery level is ${battery_level}%!" -t 60000
	pw-play /usr/share/sounds/freedesktop/stereo/suspend-error.oga
	low_flag=0
    elif [[ $battery_level -le $crit_level && $crit_flag -eq 1 ]] 
    then
        notify-send "Battery critical. Battery level is ${battery_level}%! Hibernating..."
	pw-play /usr/share/sounds/freedesktop/stereo/suspend-error.oga
        sleep 5
        low_flag=1
        crit_flag=0
        systemctl hibernate
    fi

    if [[ $battery_level -gt $low_level ]]
    then
	    low_flag=1
    fi

    if [[ $battery_level -gt $crit_level ]]
    then
	    crit_flag=1
    fi

    if [[ $battery_level -le 1 ]]
    then
        systemctl hibernate
    fi

    sleep 5
done

