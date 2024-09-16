#!/bin/bash

. ./variables.sh

set -euo pipefail

printf "\n%s====================Script starts====================%s\n\n" "${tty_yellow}" "${tty_reset}"

printf "%sInstalling other packages...%s\n" "${tty_green}" "${tty_reset}"

# Add nu to /etc/shells if not already present
sudo sh -c 'if ! grep -q "$HOME/.cargo/bin/nu" "/etc/shells"; then echo "/home/bootdme/.cargo/bin/nu" >> /etc/shells; fi'

# Brave Browser
sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc

sudo dnf config-manager --add-repo https://repository.mullvad.net/rpm/stable/mullvad.repo

printf "%sRun ./dots.sh%s\n" "${tty_green}" "${tty_reset}"

printf "\n%s====================Script ends====================%s\n\n" "${tty_yellow}" "${tty_reset}"
