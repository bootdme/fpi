#!/bin/bash

. ./variables.sh

set -euo pipefail

printf "\n%s====================Script starts====================%s\n\n" "${tty_yellow}" "${tty_reset}"

printf "%sInstalling dots and dependencies...%s\n" "${tty_green}" "${tty_reset}"

sudo dnf install python3-pip

# Install distro for dotbot
pip3 install distro

# Download dotfiles
git clone https://github.com/bootdme/dotfiles.git ~/dotfiles

# Nushell error fix for symlink
if [ ! -d "$HOME/.config/nushell" ]; then
	mkdir -p "$HOME/.config/nushell"
fi

printf "%sGo into ~/dotfiles and ./install%s\n" "${tty_green}" "${tty_reset}"
printf "%s WARNING: dotbot-ifplatform fails on first install, so ./install again for it to work.%s\n" "${tty_yellow}" "${tty_reset}"
printf "%sOnce complete, proceed to gpg.sh%s\n" "${tty_green}" "${tty_reset}"

printf "\n%s====================Script ends====================%s\n\n" "${tty_yellow}" "${tty_reset}"
