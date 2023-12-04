#!/bin/bash

# cleaning what might be left from previous runs
./clean-k8s.sh 2>/dev/null

# checking if the streaming server image exists, if not build it
if [[ "$(docker image inspect streaming-server 2> /dev/null)" == "[]" ]]; then
  echo "Streaming server image not present locally, building..."
  (cd ../streaming-server ; docker build -t streaming-server .)
fi

# checking if the fibonacci image exists, if not build it
if [[ "$(docker image inspect fibonacci 2> /dev/null)" == "[]" ]]; then
  echo "Fibonacci image not present locally, building..."
  (cd ../fibonacci ; docker build -t fibonacci .)
fi

kubectl create -f ./streaming-server-deployment.yaml
kubectl create -f ./fibonacci-deployment.yaml
kubectl create -f ./streaming-server-service.yaml
kubectl create -f ./fibonacci-service.yaml