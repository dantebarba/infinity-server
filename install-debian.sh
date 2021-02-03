#!/bin/bash
# run this script to install infinity server onto any node.

set -e;

read -p "Enter your domain name [infinity.local]: " domain
domain=${domain:-infinity.local}
read -p "Enter storage location: " storage
storage=${storage:-/root/storage}
read -p "Enter url to download configuration: " directory
read -p "Enter url to download git repo: " repo
repo=${project:-https://github.com/dantebarba/infinity-server/archive/0.1.tar.gz}

echo 'INFO: RUNNING INSTALL SCRIPT --- PLEASE WAIT';
echo 'INFO: your domain is: '${domain}
echo 'INFO: your storage location is: '${storage}
echo 'INFO: directory structure location: '${directory}
echo 'INFO: repo location: '${repo}

read -p "Please copy your ssh id using ssh-add-id and then press Y (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1;
echo 'INFO: Removing SSH password authentication';
sed -i 's/PasswordAuthentication yes/#PasswordAuthentication yes/g';
echo 'INFO: installing requiered dependencies';
apt-get update;
apt-get nano vnstat cron curl htop fail2ban git;
echo 'INFO: Installing docker';
apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common;
curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/debian \
   $(lsb_release -cs) \
   stable";
apt-get update;
apt-get install docker-ce docker-ce-cli containerd.io;
adduser dockeruser;
echo 'INFO: Installing Docker-compose';
curl -L "https://github.com/docker/compose/releases/download/1.28.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose;
chmod +x /usr/local/bin/docker-compose;

echo 'INFO: downloading repository';
wget --no-check-certificate -c $repo -O - | tar -xz;

echo 'INFO: Adding env-vars';
touch /etc/environment;
"DOMAIN_URL=$domain
PGID=1000
PUID=1000
DOCKER_TZ=America/Argentina/Buenos_Aires
STORAGE_LOCATION=$storage" > /etc/environment;
for env in $( cat /etc/environment ); do export $(echo $env | sed -e 's/"//g'); done;

echo 'INFO: Configuring DNS';
touch /etc/resolv.conf;
"nameserver 1.1.1.1
nameserver 1.0.0.1" > /etc/resolv.conf;

echo 'INFO: creating directory structure'
wget --no-check-certificate -c $directory -O - | tar -xz;

echo 'INFO: creating watchdir';
mkdir /mnt/gdrive;

echo 'INFO: applying permissions';
chown -R dockeruser:dockeruser $STORAGE_LOCATION /mnt/gdrive;

echo 'INFO: pulling images from docker hub';
cd $HOME/infinity-server && docker-compose pull;

echo 'INFO: starting services';
chmod +x start.sh && bash start.sh;

echo 'INFO: Services started successfully';
ip=ip=$(ip route get 1 | awk '{print $1;exit}');
echo 'Access your qbittorrent instance at '${ip}':8080 with username admin and password adminadmin then change its password';
echo 'Access your nzb instance at '${ip}':6789 with username nzbget and password nzbget then change its password';
exit 0;






