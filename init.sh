#!/bin/bash

. ./variables.sh

printf "\n%s====================Script starts====================%s\n\n" "${tty_yellow}" "${tty_reset}"

lines=(
	'fastestmirror=1'
	'max_parallel_downloads=10'
	'deltarpm=true'
)

for line in "${lines[@]}"; do
	if ! grep -Fxq "$line" "/etc/dnf/dnf.conf"; then
		echo "$line" | sudo tee -a "/etc/dnf/dnf.conf"
	fi
done

localectl status

timedatectl

sudo dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
sudo dnf install -y https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'

sudo dnf groupupdate core
sudo dnf install -y rpmfusion-free-release-tainted
sudo dnf install -y dnf-plugins-core

sudo dnf upgrade --refresh
sudo dnf check
sudo dnf autoremove
sudo fwupdmgr get-devices
sudo fwupdmgr refresh --force
sudo fwupdmgr get-updates
sudo fwupdmgr update

# Install NVIDIA driver
if echo "$(lspci | grep -e VGA)" | grep -q "NVIDIA"; then
	sudo dnf install akmod-nvidia
fi

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

printf "%sRun ./ssh%s\n\n" "${tty_green}" "${tty_reset}"

printf "\n%s====================Script ends====================%s\n\n" "${tty_yellow}" "${tty_reset}"
