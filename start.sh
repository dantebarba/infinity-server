#!/bin/sh
docker-compose up -d gdrive-move;
docker-compose up -d gdrive-mount;
sleep 5;
docker-compose up -d deluge;
#ocker-compose up -d autoremove-torrents;
