#!/bin/sh

function toggle_audio () {
	mute_status=$(amixer sget Master | awk '/Left:/ {print $6}')

	if [ $mute_status = "[off]" ];
	then
		brightnessctl --device 'platform::mute' set 1
	fi

	if [ $mute_status = "[on]" ];
	then
		brightnessctl --device 'platform::mute' set 0
	fi
}

function toggle_mic () {
	mute_status=$(amixer sget Capture | awk '/Left:/ {print $6}')

	if [ $mute_status = "[off]" ];
	then
		brightnessctl --device 'platform::micmute' set 1
	fi

	if [ $mute_status = "[on]" ];
	then
		brightnessctl --device 'platform::micmute' set 0
	fi
}

if [ $1 == "audio" ]; then
	toggle_audio
elif [ $1 == "mic" ]; then
	toggle_mic
else
	while :
	do
		toggle_audio
		toggle_mic
		sleep 1
	done
fi
