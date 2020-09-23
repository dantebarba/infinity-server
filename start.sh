#!/bin/sh
docker-compose up -d gdrive-mount;
sleep 5;
docker-compose up -d transmission;
