#!/bin/bash

# Use this script if you'd like to build image and run a docker container without k8s

docker build -t streaming-server .
docker stop streaming-server-container && docker rm streaming-server-container 2>/dev/null
docker run -d --name streaming-server-container --network my-bridge streaming-server
