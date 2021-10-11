#!/bin/bash

# https://github.com/vlnraf
# Author: vlnraf

# Arch aur

error(){ 
    clear; printf "ERROR:\\n%s\\n" "$1" >&2; exit 1;
}

install_aur()
    {
        cd /tmp/
        curl -LO https://aur.archlinux.org/cgit/aur.git/snapshot/yay.tar.gz
        tar xvzf yay.tar.gz
        cd yay
        makepkg -sci
    }

install_xmonad(){
    sudo pacman -S xmonad xmonad-contrib
}

# Dotfiles with git bare
install_dots()
    {
        cd ~
        mkdir -p ~/.config
        chmod 700 ~/.config
        git clone --bare https://github.com/vlnraf/dotfiles $HOME/.dotfiles
        git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME checkout --force
        git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME config --local status.showUntrackedFiles no
    }

# Key apps to install
install_key_app(){
    cd ~/Dotfile-installer
    sudo pacman -Sy --needed - < pkglist.txt
    
    yay -S --noconfirm --needed nerd-fonts-mononoki ttf-font-awesome ttf-font-awesome-4 ttf-twemoji-color
    cd ~
}

install_oh_my_zsh(){
    cd ~
    sudo pacman -S zsh
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

choose_video_driver(){
    # choose video driver
    echo "1) xf86-video-intel 	2) xf86-video-amdgpu 3) nvidia 4) Skip"
    read -r -p "Choose you video card driver(default 1)(will not re-install): " vid

    case $vid in 
    [1])
        DRI='xf86-video-intel'
        ;;

    [2])
        DRI='xf86-video-amdgpu'
        ;;

    [3])
        DRI='nvidia nvidia-settings nvidia-utils'
        ;;

    [4])
        DRI=""
        ;;
    [*])
        DRI='xf86-video-intel'
        ;;
    esac

    # install xorg if not installed
    sudo pacman -S --noconfirm --needed rofi feh xorg xorg-xinit xorg-xinput $DRI

}


if [ "$(id -u)" = 0 ]; then
    echo "##################################################################"
    echo "This script MUST NOT be run as root user since it makes changes"
    echo "to the \$HOME directory of the \$USER executing this script."
    echo "The \$HOME directory of the root user is, of course, '/root'."
    echo "We don't want to mess around in there. So run this script as a"
    echo "normal user. You will be asked for a sudo password when necessary."
    echo "##################################################################"
    exit 1
fi

sudo pacman --noconfirm --needed -Sy dialog || error "Error installing dialog"

welcome() { \
    dialog --colors --title "\Z7\ZbInstalling my dotfiles!" --msgbox "\Z4This is a script that will install the dotfiles to have a window manager like the one you have seen in the Github repository.  It's really just an installation script for those that want to try out my XMonad desktop.  We will install the XMonad tiling window manager, the Xmobar panel, the Alacritty terminal, Neovim and many other essential programs needed to make my dotfiles work correctly.\\n\\n-Raffaele Villani" 16 60

    dialog --colors --title "\Z7\ZbStay near your computer!" --yes-label "Continue" --no-label "Exit" --yesno "\Z4This script is not allowed to be run as root, but you will be asked to enter your sudo password at various points during this installation. This is to give PACMAN the necessary permissions to install the software.  So stay near the computer." 8 60
}

welcome || error "User choose to exit"

takecare() { \
    dialog --colors --title "\Z7\ZbInstalling my dotfiles!" --msgbox "\Z4WARNING! The installation script is not a professional installer. There are almost certainly errors in it; therefore, it is strongly recommended that you not install this on production machines. It is recommended that you try this out in either a virtual machine or on a test machine." 16 60

    dialog --colors --title "\Z7\ZbAre You Sure You Want To Do This?" --yes-label "Begin Installation" --no-label "Exit" --yesno "\Z4Shall we begin installing?" 8 60 || { clear; exit 1; }
}

takecare || error "User choose to exit."

clear

set -e

# echo "Installer for Raffaele Dotfiles" && sleep 2

echo "Doing a system update, cause something can go wrong if the system is not updated to the latest version"
sudo pacman --noconfirm -Syu

# install base-devel if not installed
sudo pacman -S --noconfirm --needed base-devel wget git

choose_video_driver

echo "Installing Window Manager Xmonad"
install_xmonad

echo "Installing aur package"
install_aur

echo "Installing all the apps to run the system properly"
install_key_app

echo "Installing dotfiles"
install_dots

loginmanager() { \
    dialog --colors --title "\Z5\ZbInstallation Complete!" \
    --msgbox "\Z2Now logout of your current desktop environment \
                or window manager and choose XMonad from your login manager. \
                ENJOY!" 10 60
}

loginmanager && echo "Installation Complete"
