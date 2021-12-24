#!/bin/bash
# run this script to install infinity server onto any node.
set -e;

read -p "Enter your domain name [infinity.local]: " domain
domain=${domain:-infinity.local}
read -p "Enter storage location: " storage
storage=${storage:-$HOME}
read -p "Enter url to download configuration: " directory
read -p "Enter url to download git repo: " repo
repo=${repo:-https://github.com/dantebarba/infinity-server/archive/0.1.tar.gz}

read -p "Enter secrets url: " secrets
secrets=${secrets}

echo 'INFO: RUNNING INSTALL SCRIPT --- PLEASE WAIT';
echo 'INFO: your domain is: '${domain}
echo 'INFO: your storage location is: '${storage}
echo 'INFO: directory structure location: '${directory}
echo 'INFO: repo location: '${repo}

read -p "Please copy your ssh id using ssh-add-id and then press Y (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1;

chmod +x "provision.sh";
bash "provision.sh" $domain $storage $directory $repo $secrets;






