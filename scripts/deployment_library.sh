#!/bin/bash

readonly REPO_ROOT=$(git rev-parse --show-toplevel)

function deploy_EFK {
    #Create a namespace
    kubectl apply -f "${REPO_ROOT}/k8s/namespaces/monitoring-ns.yaml"

    #Deploy EFK stack
    EFK_STACK_PATH="${REPO_ROOT}/k8s/monitoring-manifests/EFK-stack-manifests"
    for dir in "${EFK_STACK_PATH}"/*; do
        for yaml_file in "${dir}"/*.yaml; do
            kubectl apply -f "$yaml_file"
        done
    done
}

function deploy_streaming_server {
    #Create a namespace
    kubectl apply -f "${REPO_ROOT}/k8s/namespaces/streaming-server-ns.yaml"

    #Deploy server and fibonacci
    STREAMING_SERVER_PATH="${REPO_ROOT}/k8s/streaming-server-manifests"
    for yaml_file in "${STREAMING_SERVER_PATH}"/*.yaml; do
        kubectl apply -f "$yaml_file"
    done
    #Deploy metric server for HPA
    kubectl apply -f "${REPO_ROOT}/k8s/metric-server-manifests/components.yaml"

    #Create HPA 
    kubectl autoscale deployment streaming-server-deployment --cpu-percent=50 --min=1 --max=10 -n streaming-server
}