#!/bin/bash

. ./variables.sh

set -euo pipefail

printf "\n%s====================Script starts====================%s\n\n" "${tty_yellow}" "${tty_reset}"

# https://medium.com/risan/upgrade-your-ssh-key-to-ed25519-c6e8d60d3c54
if [ ! -d ~/.ssh ] || [ ! -f ~/.ssh/id_ed25519 ]; then
	printf "%sCreating SSH key pair for GitHub...%s\n\n" "${tty_green}" "${tty_reset}"

	read -rp "${tty_green}Please enter the email you use for GitHub: ${tty_reset}" EMAIL

	ssh-keygen -o -a 100 -t ed25519 -f ~/.ssh/id_ed25519 -C "$EMAIL"
	eval "$(ssh-agent -s)"

	cat <<EOT >>~/.ssh/config
Host *
    AddKeysToAgent yes
    IgnoreUnknown UseKeychain
    UseKeychain yes
    IdentityFile ~/.ssh/id_ed25519
EOT

	ssh-add ~/.ssh/id_ed25519
fi

read -rp "${tty_green}Please enter your Github Personal token: ${tty_reset}" GITHUB_TOKEN

curl -H "Authorization: token $GITHUB_TOKEN" -X POST -d "{\"title\":\"FedoraKey\",\"key\":\"$(cat ~/.ssh/id_ed25519.pub)\"}" https://api.github.com/user/keys

printf "%sRun ./packages.sh%s\n\n" "${tty_green}" "${tty_reset}"

printf "\n%s====================Script ends====================%s\n\n" "${tty_yellow}" "${tty_reset}"
