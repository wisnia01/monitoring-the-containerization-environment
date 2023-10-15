#!/bin/bash

# Use this script if you'd like to build image and run a docker container without k8s

docker build -t streaming-server .
docker stop streaming-server-container && docker rm streaming-server-container 2>/dev/null
docker run -d -p 8080:8080 --name streaming-server-container streaming-server
