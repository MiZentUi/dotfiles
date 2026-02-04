#!/usr/bin/sh

set -e

prefix="\e[35m[###]\e[0m"

mkdir -p temp

stowing () {
    echo -e "$prefix stowing"
    
    # home dir
    
    home_stow=(
        zsh
        vim
        fastfetch
        hypr
        waybar
        wpaperd
        kitty
        rofi
        mako
        eww
        mcontrolcenter
    )
    
    stow -v -t ~ ${home_stow[@]}
    
    # etc dir
    if [ ! -L "/etc/pacman.conf" ]; then
        sudo rm -f /etc/pacman.conf
    fi
    
    if [ ! -L "/etc/default/grub" ]; then
        sudo rm -f /etc/default/grub
    fi
    
    sudo stow -v -t /etc etc
    
    # scripts
    sudo stow -v -t /usr/local/bin scripts
    
    # sddm
    sudo stow -v --ignore="theme.txt" -t /etc sddm
}

packages () {
    echo -e "$prefix package installation"
    
    pkgs_list=./packages.txt
    pkgs_aur_list=./packages-aur.txt
    pkgs_flatpak_list=./packages-flatpak.txt
    
    base_pkgs=(
        linux
        linux-headers
        linux-firmware
        base
        base-devel
        sof-firmware
        efibootmgr
        os-prober
        grub
        sudo
        grep
        zsh
        vim
        curl
        git
        make
        man-db
        networkmanager
        
        acpi
        alsa-utils
        android-file-transfer
        android-tools
        bluetui
        bluez
        cliphist
        cups
        fastfetch
        flatpak
        grim
        htop
        mesa
        ncdu
        net-tools
        networkmanager-openvpn
        nvidia-open
        nvidia-prime
        nvidia-settings
        nvidia-utils
        nvtop
        openrgb
        openssh
        openssl
        openvpn
        pipewire
        pipewire-pulse
        pulseaudio-alsa
        rsync
        slurp
        stow
        thermald
        tlp
        tree
        vulkan-headers
        vulkan-tools
        xdg-desktop-portal
        xdg-desktop-portal-gnome
        xdg-desktop-portal-gtk
        xdg-desktop-portal-hyprland
        zip
    )
    
    base_pkgs_aur=(
        aic94xx-firmware
        ast-firmware
        msi-ec-dkms-git
        oh-my-zsh-git
        upd72020x-fw
        wd719x-firmware
    )
    
    software_pkgs=(
        hyprland
        hyprcursor
        hypridle
        hyprlock
        hyprpaper
        hyprpicker
        hyprpolkitagent
        hyprsunset
        
        kitty
        mako
        pavucontrol
        rofi
        waybar
        
        cava
        libreoffice-fresh
        nautilus
        qbittorrent
        vlc
        wine
        
        adwaita-cursors
        adwaita-fonts
        adwaita-icon-theme
        breeze-icons
        nerd-fonts
        noto-fonts
        powerline-fonts
    )
    
    software_pkgs_aur=(
        eww
        mcontrolcenter-bin
        sddm-git
        
        nerd-fonts-noto-sans-mono
        rose-pine-cursor
        rose-pine-hyprcursor
        sddm-sugar-candy-git
    )
    
    echo -e "$prefix pacman packages"
    
    sudo pacman -Syu --noconfirm --needed ${base_pkgs[@]} ${software_pkgs[@]} - < $pkgs_list
    
    echo -e "$prefix yay installation"
    
    (git -C temp/yay pull || git clone https://aur.archlinux.org/yay.git temp/yay && cd temp/yay && makepkg -si --noconfirm --needed)
    
    echo -e "$prefix AUR packages"
    
    yay -Syu --sudoloop --noconfirm --needed ${base_pkgs_aur[@]} ${software_pkgs_aur[@]} - < $pkgs_aur_list
    
    echo -e "$prefix Flatpak packages"
    
    cat $pkgs_flatpak_list | xargs flatpak install
}

themes () {
    # GRUB theme
    
    echo -e "$prefix grub theme installation"
    
    git -C temp/grub2-themes pull || git clone https://github.com/vinceliuice/grub2-themes.git temp/grub2-themes
    sudo ./temp/grub2-themes/install.sh -t vimix -b
    
    
    # SDDM theme
    
    echo -e "$prefix sddm theme configuration"
    
    sudo cp -f sddm/theme.conf /usr/share/sddm/themes/sugar-candy/
    sudo cp -f images/stars_1.jpg /usr/share/sddm/themes/sugar-candy/Backgrounds/background.jpg
}

usage () {
    cat <<EOF
Usage: $(basename "$0") [option]

This script installs dotfiles, packages and themes

Options:
  -s            Stowing only
  -p            Install packages only
  -h            Display this help message
EOF
    exit
}


if [ $# -eq 0 ]; then
    stowing
    packages
    themes
    stowing
    echo -e "$prefix done"
    exit 0
fi

while getopts "sph" opt; do
    case $opt in
        s) stowing ;;
        p) packages ;;
        t) themes ;;
        h) usage ;;
        \?) echo "Unknown option" >&2; usage ;;
    esac
done
