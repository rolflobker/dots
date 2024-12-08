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
