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

# Add nu to /etc/shells if not already present
sudo sh -c 'if ! grep -q "$HOME/.cargo/bin/nu" "/etc/shells"; then echo "/home/bootdme/.cargo/bin/nu" >> /etc/shells; fi'

# Brave Browser
sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc

sudo dnf config-manager --add-repo https://repository.mullvad.net/rpm/stable/mullvad.repo

# Carpace download and install
curl -L -o ~/Downloads/carapace-bin_1.0.6_linux_amd64.rpm https://github.com/carapace-sh/carapace-bin/releases/download/v1.0.6/carapace-bin_1.0.6_linux_amd64.rpm
sudo dnf install ~/Downloads/carapace-bin_1.0.6_linux_amd64.rpm

printf "%sRun ./ssh%s\n\n" "${tty_green}" "${tty_reset}"

printf "\n%s====================Script ends====================%s\n\n" "${tty_yellow}" "${tty_reset}"
