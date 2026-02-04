#!/bin/bash

wait_time=$((20 * 60))
break_time=20
delim_size=70

message="Eye break"

function action() {
    NID=$(notify-send "$message$(printf "%${delim_size}s" $break_time)" -t $((break_time * 1000)) -p)
    pw-play /usr/share/sounds/freedesktop/stereo/service-login.oga &
    for i in $(seq $(($break_time - 1)) -1 1); do
        sleep 1
	    NID=$(notify-send -p -r $NID "$message$(printf "%${delim_size}s" $i)")
    done
    sleep 1
    notify-send -r $NID "$message$(printf "%${delim_size}s" "done")" -t $((3 * 1000))
    pw-play /usr/share/sounds/freedesktop/stereo/service-logout.oga &
}

if [[ $# -eq 1 && $1 -eq "-d" ]]; then
    action
    exit 0
fi

while true; do
    sleep $wait_time
    action
done
