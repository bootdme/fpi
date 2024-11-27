#!/bin/bash

set -euo pipefail

. ./variables.sh

# Function to remove a file or directory
remove_file_or_directory() {
	local file_or_directory="$1"
	if [ -e "$file_or_directory" ]; then
		if [ -f "$file_or_directory" ]; then
			rm "$file_or_directory"
			printf "%sFile %s has been removed.%s\n" "${tty_green}" "$file_or_directory" "${tty_reset}"
		elif [ -d "$file_or_directory" ]; then
			rm -r "$file_or_directory"
			printf "%sDirectory %s has been removed.%s\n" "${tty_green}" "${file_or_directory}" "${tty_reset}"
		else
			printf "%sError: %s is not a valid file or directory.%s\n" "${tty_red}" "${file_or_directory}" "${tty_reset}"
		fi
	else
		printf "%s%s does not exist.%s\n" "${tty_red}" "${file_or_directory}" "${tty_reset}"
	fi
}

printf "\n%s====================Script starts====================%s\n\n" "${tty_yellow}" "${tty_reset}"

remove_file_or_directory "$HOME/.viminfo"
remove_file_or_directory "$HOME/.vim"

remove_file_or_directory "$HOME/.mozilla"

printf "\n%s====================Script ends====================%s\n\n" "${tty_yellow}" "${tty_reset}"
