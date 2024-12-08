#!/usr/bin/env bash
if ! command -v ansible &>/dev/null; then
	echo "Ansible needs to be installed."
	sudo dnf install -y ansible
fi

ansible-playbook playbook.yaml -K --tags fonts,packages
