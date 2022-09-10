#!/bin/bash
set -e;

domain=$1
storage=$2
directory=$3
repo=$4
secrets=$5

echo 'INFO: Removing SSH password authentication';
sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config;
echo 'INFO: installing requiered dependencies';
apt-get update;
apt-get -y install nano vnstat cron curl htop fail2ban git ncdu;
echo 'INFO: Installing docker';
apt-get -y install \
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
apt-get -y install docker-ce docker-ce-cli containerd.io;
adduser dockeruser;
echo 'INFO: Installing Docker-compose';
curl -L "https://github.com/docker/compose/releases/download/1.28.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose;
chmod +x /usr/local/bin/docker-compose;

echo 'INFO: cloning repository';
git clone "$repo" && export git_repo=$(basename "$repo" .git);

echo 'INFO: downloading secrets';
wget --no-check-certificate -c "$secrets" -O $git_repo

echo 'INFO: creating directory structure'
wget --no-check-certificate -c "$directory" -O - | tar -xz -C $storage;

echo 'INFO: Adding env-vars';
touch /etc/environment;

echo "DOMAIN_URL=$domain" >> /etc/environment;
echo "PGID=1000" >> /etc/environment;
echo "PUID=1000" >> /etc/environment;
echo "DOCKER_TZ=America/Argentina/Buenos_Aires" >> /etc/environment;
echo "STORAGE_LOCATION=${storage}/infinity-node/" >> /etc/environment;

for env in $( cat /etc/environment ); do export $(echo $env | sed -e 's/"//g'); done;

echo 'INFO: Configuring DNS';
touch /etc/resolv.conf;
> /etc/resolv.conf;

echo "nameserver 1.1.1.1" >> /etc/resolv.conf;
echo "nameserver 1.0.0.1" >> /etc/resolv.conf;

echo 'INFO: creating watchdir';
mkdir /mnt/gdrive;

echo 'INFO: applying permissions';
chown -R dockeruser:dockeruser $STORAGE_LOCATION /mnt/gdrive;

echo 'INFO: pulling images from docker hub';
cd $HOME/$git_repo && docker-compose pull;

echo 'INFO: installing watch crontab';
# crontab -l | { cat; echo "* * * * * touch /mnt/gdrive"; } | crontab -;
crontab -l | { cat; echo "@weekly $HOME/infinity-server/ccleaner.sh >> /var/log/ccleaner.log 2>&1"; } | crontab -;
crontab -l | { cat; echo "@reboot $HOME/infinity-server/ccleaner.sh >> /var/log/ccleaner.log 2>&1"; } | crontab -;

echo 'INFO: starting services';
chmod +x start.sh && bash start.sh;

echo 'INFO: Services started successfully';
ip=$(ip route get 1 | awk '{print $1;exit}');
echo 'Access your qbittorrent instance at '${ip}':8080 with username admin and password adminadmin then change its password';
echo 'Access your nzb instance at '${ip}':6789 with username nzbget and password nzbget then change its password';
exit 0;