#!/bin/sh
docker-compose up -d gdrive-move-torrents;
docker-compose up -d gdrive-move-nzb;
docker-compose up -d gdrive-mount;
sleep 15;
docker-compose up -d qbittorrent;
docker-compose up -d nzbget;
docker-compose up -d rclone-sa-autoswap;
docker-compose up -d tracker-annunce;
docker-compose up -d autoremove-torrents;
