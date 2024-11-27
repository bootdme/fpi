#!/bin/bash

source variables.sh

set -euo pipefail

printf "\n%s==================== Script starts ====================%s\n\n" "${tty_yellow}" "${tty_reset}"

create_ssh_key() {
	local email=$1
	local service=$2
	local name=$3
	local key_file=~/.ssh/id_ed25519_${service}_${name}

	if [ -f "$key_file" ]; then
		printf "%sSSH key pair for %s (%s) already exists as %s.%s\n\n" \
			"${tty_yellow}" "$service" "$email" "$name" "${tty_reset}"
		return 1
	else
		printf "%sCreating SSH key pair for %s (%s) named %s...%s\n\n" \
			"${tty_green}" "$service" "$email" "$name" "${tty_reset}"

		ssh-keygen -o -a 100 -t ed25519 -f "$key_file" -C "$email"
		eval "$(ssh-agent -s)"

		cat <<EOT >>~/.ssh/config
Host $name
    HostName $service.com
    User git
    AddKeysToAgent yes
    UseKeychain yes
    IdentityFile $key_file
EOT

		ssh-add "$key_file"
		return 0
	fi
}

upload_to_github() {
	local email=$1
	local name=$2
	local token=$3
	local key_file=~/.ssh/id_ed25519_github_${name}

	curl -H "Authorization: token $token" -X POST -d "{\"title\":\"FedoraKey_${name}\",\"key\":\"$(cat $key_file.pub)\"}" https://api.github.com/user/keys

	printf "%sSSH key was successfully added to GitHub%s\n" "${tty_green}" "${tty_reset}"
}

upload_to_gitlab() {
	local email=$1
	local name=$2
	local token=$3
	local key_file=~/.ssh/id_ed25519_gitlab_${name}

	curl --silent --header "PRIVATE-TOKEN: $token" -X POST -d "title=FedoraKey_${name}&key=$(cat $key_file.pub)" https://gitlab.com/api/v4/user/keys

	printf "\n%sSSH key was successfully added to GitLab%s\n" "${tty_green}" "${tty_reset}"
}

setup_github() {
	local key_exists=1
	while [ $key_exists -ne 0 ]; do
		read -rp "${tty_green}Please enter the email you use for GitHub: ${tty_reset}" GITHUB_EMAIL
		read -rp "${tty_green}Please enter a name for this GitHub key (e.g., work, personal): ${tty_reset}" GITHUB_NAME
		create_ssh_key "$GITHUB_EMAIL" "github" "$GITHUB_NAME"
		key_exists=$?
	done
	read -rp "${tty_green}Please enter your GitHub Personal token: ${tty_reset}" GITHUB_TOKEN
	upload_to_github "$GITHUB_EMAIL" "$GITHUB_NAME" "$GITHUB_TOKEN"
}

setup_gitlab() {
	local key_exists=1
	while [ $key_exists -ne 0 ]; do
		read -rp "${tty_green}Please enter the email you use for GitLab: ${tty_reset}" GITLAB_EMAIL
		read -rp "${tty_green}Please enter a name for this GitLab key (e.g., work, personal): ${tty_reset}" GITLAB_NAME
		create_ssh_key "$GITLAB_EMAIL" "gitlab" "$GITLAB_NAME"
		key_exists=$?
	done
	read -rp "${tty_green}Please enter your GitLab Personal Access token: ${tty_reset}" GITLAB_TOKEN
	upload_to_gitlab "$GITLAB_EMAIL" "$GITLAB_NAME" "$GITLAB_TOKEN"
}

while true; do
	printf "%sWhere would you like to upload your SSH key?%s\n" "${tty_green}" "${tty_reset}"
	printf "1) GitHub\n"
	printf "2) GitLab\n"
	printf "3) Exit\n"
	read -rp "${tty_green}Please enter the number corresponding to your choice: ${tty_reset}" CHOICE

	case $CHOICE in
	1)
		setup_github
		;;
	2)
		setup_gitlab
		;;
	3)
		printf "%sExiting...%s\n" "${tty_yellow}" "${tty_reset}"
		break
		;;
	*)
		printf "%sInvalid option selected. Please choose 1, 2, or 3.%s\n\n" "${tty_red}" "${tty_reset}"
		;;
	esac
done

printf "%sRun ./step3.sh%s\n" "${tty_green}" "${tty_reset}"

printf "\n%s==================== Script ends ====================%s\n\n" "${tty_yellow}" "${tty_reset}"
