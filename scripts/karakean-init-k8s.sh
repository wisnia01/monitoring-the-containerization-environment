#!/bin/bash

BUILD_IMAGES=0

while getopts b: flag
do
  case "${flag}" in
    b) BUILD_IMAGES=1;;
  esac
done

readonly REPO_ROOT=$(git rev-parse --show-toplevel)

kubectl create namespace monitoring
kubectl create namespace streaming-server

if [[ BUILD_IMAGES == 1 ]]; then
    docker build -t streaming-server:latest "${REPO_ROOT}/apps/streaming-server"
    docker build -t fibonacci:latest "${REPO_ROOT}/apps/fibonacci"
    docker build -t number-verifier:latest "${REPO_ROOT}/apps/number-verifier"
fi

for yaml_file in "${REPO_ROOT}/k8s/monitoring-manifests/tracing-manifests"/*.yaml; do
    kubectl apply -f "$yaml_file"
done

for dir in "${REPO_ROOT}/k8s/apps-manifests"/*; do
    for yaml_file in "$dir"/*.yaml; do
        kubectl apply -f "$yaml_file"
    done
done
