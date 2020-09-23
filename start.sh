#!/bin/sh
docker-compose up -d gdrive-mount;
sleep 10;
docker-compose up -d transmission;
