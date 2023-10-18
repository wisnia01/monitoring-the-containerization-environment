#!/bin/bash

# cleaning what might be left from previous runs
./clean-k8s.sh 2>/dev/null

# checking if the streaming server image exists, if not build it
if [[ "$(docker image inspect streaming-server:0.1.0 2> /dev/null)" == "[]" ]]; then
  echo "Image not present locally, building..."
  eval $(minikube docker-env)
  (cd ../streaming-server ; docker build -t streaming-server:0.1.0 .)
fi

kubectl create -f ./streaming-server-deployment.yaml
kubectl create -f ./streaming-server-service.yaml

minikube addons enable ingress
minikube tunnel