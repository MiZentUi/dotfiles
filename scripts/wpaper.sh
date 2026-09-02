#!/bin/sh

wallpaper=$2

echo $wallpaper > $HOME/.cache/quickshell/hyprquickpaper/.current

# mkdir -p ~/.cache/matugen
matugen image $wallpaper --source-color-index 0
