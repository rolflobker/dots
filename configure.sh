#!/usr/bin/env bash
if ! command -v ansible &>/dev/null; then
	echo "Ansible needs to be installed."
	sudo dnf install -y ansible
fi

if [ ! -d "/usr/lib64/python3.13/site-packages/libdnf5/" ]; then
	echo "Missing python3-libdnf5, installing..."
	sudo dnf install -y "python3-libdnf5"
fi

ansible-playbook playbook.yaml -K --tags fonts,packages

# Stow all dotfiles folders

EXCLUDED_DIRS=("roles")
BACKUP_DIR="$HOME/.backups"
mkdir -p "$BACKUP_DIR"

stow_package() {
	package_dir=$1
	package=$(basename "$package_dir")
	target_dir="$HOME/$package"

	# Skip excluded directories
	if [[ " ${EXCLUDED_DIRS[@]} " =~ " ${package} " ]]; then
		echo "Skipping $package (excluded directory)"
		return
	fi

	# Check if the target directory already exists
	if [ -e "$target_dir" ]; then
		# If it exists as a symlink, check if it's already stowed
		if [ -L "$target_dir" ]; then
			# Check if the symlink points to the correct location (stowed)
			target_link=$(readlink "$target_dir")
			if [[ "$target_link" == "$HOME/$package" ]]; then
				echo "Ignoring already stowed symlink for $package"
				return
			else
				# If symlink points somewhere else, back it up
				echo "Symlink for $package points to $target_link, backing up"
				mv "$target_dir" "$BACKUP_DIR/"
			fi
		else
			# If it's a regular directory, back it up
			echo "$target_dir already exists as a directory, backing up"
			mv "$target_dir" "$BACKUP_DIR/"
		fi
	fi

	# Run stow (assuming we are in the parent directory of packages)
	echo "Stowing $package"
	stow --target="$HOME" "$package_dir"
}

# Loop through all subdirectories and run stow
for dir in */; do
	# Check if the directory is not excluded
	if [[ ! " ${EXCLUDED_DIRS[@]} " =~ " $(basename "$dir") " ]]; then
		# Run stow on the directory
		stow_package "$dir"
	else
		echo "Skipping $dir (excluded)"
	fi
done
