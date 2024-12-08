#!/usr/bin/bash

for dir in */; do
	package=$(basename "$dir")

	# Use stow -d to remove the stowed symlink
	echo "Reverting stow for $package"
	stow -D "$package"
done
