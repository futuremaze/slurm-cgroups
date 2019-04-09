#!/bin/bash -xeu
cd $(pwd $0)

# cgroups のインストール
sudo -E apt-get update -y
sudo -E apt-get install -y python3-pip
sudo -E -H pip3 install ansible

cd $(pwd $0)/ansible
ansible-playbook -c local site.yml