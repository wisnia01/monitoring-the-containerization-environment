#!/bin/bash

readonly REPO_ROOT=$(git rev-parse --show-toplevel)

kubectl apply -f "${REPO_ROOT}/k8s/monitoring/monitoring-ns.yaml"

#Deploy EFK stack
EFK_STACK_PATH="${REPO_ROOT}/k8s/monitoring/EFK-stack-manifests"
for dir in "${EFK_STACK_PATH}"/*; do
    for yaml_file in "${dir}"/*.yaml; do
        kubectl apply -f "$yaml_file"
    done
done