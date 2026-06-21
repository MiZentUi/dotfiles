#!/bin/sh

display=$1
wallpaper=$2

echo "Display is : $display"
echo "Wallpaper path is: $wallpaper"

# Update Pywal
echo ":: Applying pywal with $wallpaper"
wal -i "$wallpaper" --saturate 0.75

source "$HOME/.cache/wal/colors.sh"

mkdir -p "$HOME/.config/mako"
cp "$HOME/.cache/wal/config.mako" "$HOME/.config/mako/config" 
makoctl reload

killall -SIGUSR2 waybar
walogram -s
