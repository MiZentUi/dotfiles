#!/usr/bin/env bash

dir="$HOME/.config/rofi/clipboard"
theme='style'

/usr/local/bin/cliphist-rofi-img.sh | \
rofi \
    -dmenu \
    -theme ${dir}/${theme}.rasi \
    -display-columns 2 | \
cliphist decode | \
wl-copy