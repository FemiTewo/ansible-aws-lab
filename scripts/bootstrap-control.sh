#!/usr/bin/env bash
# Run ON the control node: installs Ansible and git.
set -euo pipefail
sudo apt-get update -y
sudo apt-get install -y software-properties-common git python3-pip
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt-get install -y ansible
ansible --version | head -1
ansible-galaxy collection install -r requirements.yml 2>/dev/null || true
echo "Done. Next: copy your .pem to ~/.ssh/lab.pem and chmod 600 it."
