#!/bin/bash
set -eux

# install python & pip
apt-get update
apt-get install -y python3 python3-pip

# install ansible locally
pip3 install --user ansible

# pull your playbook and run it
mkdir -p /opt/ansible
cp /home/ubuntu/ansible/* /opt/ansible/
cd /opt/ansible
~/.local/bin/ansible-playbook -i hosts.ini playbook.yml
