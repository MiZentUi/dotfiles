#!/usr/bin/sh

set -e

prefix="\e[35m[###]\e[0m"

mkdir -p temp

check_clear () {
    if [ ! -L "$1" ]; then
        echo "clear $1"
        sudo rm -f $1
    fi
}

stowing () {
    echo -e "$prefix stowing"
    
    # home dir
    
    home_stow=(
        zsh
        vim
        fastfetch
        hypr
        wal
        waybar
        wpaperd
        kitty
        rofi
        eww
        mcontrolcenter
    )
    
    stow -v -t ~ ${home_stow[@]}
    
    # etc dir

    shopt -s globstar dotglob

    for file in etc/**/*; do 
        [[ -d "$file" ]] && continue
        check_clear "/$file"
    done
    
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
        acpid
        alsa-utils
        android-file-transfer
        android-tools
        bluetui
        bluez
        bluez-utils
        cliphist
        cups
        fastfetch
        flatpak
        grim
        htop
        inetutils
        mesa
        mesa-utils
        ncdu
        net-tools
        nvidia-open
        nvidia-prime
        nvidia-settings
        nvidia-utils
        nvtop
        ntfs-3g
        openrgb
        openssh
        openssl
        pamixer
        pipewire
        pipewire-pulse
        pulseaudio-alsa
        rsync
        sane
        sane-airscan
        slurp
        snixembed
        stow
        thermald
        tlp
        tree
        vulkan-headers
        vulkan-tools
        vulkan-validation-layers
        weston
        wl-clipboard
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
        uwsm
        
        kitty
        mako
        pavucontrol
        python-pywal
        rofi
        rofi-calc
        waybar
        wpaperd
        
        cava
        gnome-tweaks
        libreoffice-fresh
        nautilus
        nautilus-image-converter
        qbittorrent
        qt5ct
        qt6ct
        vlc
        wine
        
        adwaita-cursors
        adwaita-fonts
        adwaita-icon-theme
        breeze-icons
        nerd-fonts
        noto-fonts
        noto-fonts-cjk
        noto-fonts-emoji
        noto-fonts-extra
        powerline-fonts
    )
    
    software_pkgs_aur=(
        eww
        mcontrolcenter-bin
        sddm-git

        python-pywalfox
        
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
    
    cat $pkgs_flatpak_list | xargs flatpak install -y
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

configuring () {
    systemctl enable sddm
    chsh -s /usr/bin/zsh
    chmod +x scripts/*
}

usage () {
    cat <<EOF
Usage: $(basename "$0") [option]

This script installs dotfiles, packages and themes

Options:
  -s            Stowing only
  -p            Install packages only
  -t            Themes only
  -c            Configuring only
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

while getopts "sptch" opt; do
    case $opt in
        s) stowing ;;
        p) packages ;;
        t) themes ;;
        c) configuring ;;
        h) usage ;;
        \?) echo "Unknown option" >&2; usage ;;
    esac
done
