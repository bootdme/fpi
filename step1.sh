#!/bin/bash

. ./variables.sh

printf "\n%s====================Script starts====================%s\n\n" "${tty_yellow}" "${tty_reset}"

# Function to add lines to dnf.conf
add_to_dnf_conf() {
	for line in "$@"; do
		if ! grep -Fxq "$line" "/etc/dnf/dnf.conf"; then
			echo "$line" | sudo tee -a "/etc/dnf/dnf.conf" >/dev/null
		fi
	done
}

# Configure dnf
add_to_dnf_conf 'fastestmirror=1' 'max_parallel_downloads=10' 'deltarpm=true'

localectl status
timedatectl

# Install RPM Fusion
sudo dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
sudo dnf install -y https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# Add Microsoft repo
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo tee /etc/yum.repos.d/vscode.repo >/dev/null <<EOF
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF

# Update and install necessary packages
sudo dnf groupupdate core -y
sudo dnf install -y rpmfusion-free-release-tainted dnf-plugins-core

# System upgrade and maintenance
sudo dnf upgrade --refresh -y
sudo dnf check
sudo dnf autoremove -y

# Firmware updates
sudo fwupdmgr get-devices
sudo fwupdmgr refresh --force
sudo fwupdmgr get-updates
sudo fwupdmgr update

# Install NVIDIA driver if available
if lspci | grep -q "NVIDIA"; then
	sudo dnf install -y akmod-nvidia
fi

# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Add nu to /etc/shells if not already present
sudo sh -c 'if ! grep -q "$HOME/.cargo/bin/nu" "/etc/shells"; then echo "$HOME/.cargo/bin/nu" >> /etc/shells; fi'

# Add Brave Browser repo
sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc

# Add Mullvad repo
sudo dnf config-manager --add-repo https://repository.mullvad.net/rpm/stable/mullvad.repo

# Download and install Carapace
CARAPACE_URL="https://github.com/carapace-sh/carapace-bin/releases/download/v1.0.6/carapace-bin_1.0.6_linux_amd64.rpm"
CARAPACE_PATH=~/Downloads/carapace-bin_1.0.6_linux_amd64.rpm
curl -L -o "$CARAPACE_PATH" "$CARAPACE_URL"
sudo dnf install -y "$CARAPACE_PATH"

# For dotfiles
sudo dnf install python3-pip
pip3 install distro

# Nushell error fix for symlink
if [ ! -d "$HOME/.config/nushell" ]; then
	mkdir -p "$HOME/.config/nushell"
fi

printf "%sRun ./step2.sh%s\n\n" "${tty_green}" "${tty_reset}"

printf "\n%s====================Script ends====================%s\n\n" "${tty_yellow}" "${tty_reset}"
