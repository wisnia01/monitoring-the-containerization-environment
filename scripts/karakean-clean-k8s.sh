#!/bin/bash

readonly REPO_ROOT=$(git rev-parse --show-toplevel)

for dir in "${REPO_ROOT}/k8s/apps-manifests"/*; do
    for yaml_file in "$dir"/*.yaml; do
        kubectl delete -f "$yaml_file"
    done
done

for yaml_file in "${REPO_ROOT}/k8s/monitoring-manifests/tracing-manifests"/*.yaml; do
    kubectl delete -f "$yaml_file"
done
