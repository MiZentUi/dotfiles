#!/bin/sh

wallpaper=$2

# mkdir -p ~/.cache/matugen
matugen image $wallpaper --source-color-index 0

echo $(basename $2) > $HOME/.cache/quickshell/hyprquickpaper/current
