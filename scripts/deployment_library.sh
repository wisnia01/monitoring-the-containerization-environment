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

function deploy_Jaeger {
    for yaml_file in "${REPO_ROOT}/k8s/monitoring-manifests/tracing-manifests"/*.yaml; do
        kubectl apply -f "$yaml_file"
    done
}

function deploy_apps {
    #Create a namespace
    kubectl apply -f "${REPO_ROOT}/k8s/namespaces/streaming-server-ns.yaml"

    #Deploy apps
    for dir in "${REPO_ROOT}/k8s/apps-manifests"/*; do
        for yaml_file in "$dir"/*.yaml; do
            kubectl apply -f "$yaml_file"
        done
    done

    #Deploy metric server for HPA
    kubectl apply -f "${REPO_ROOT}/k8s/metric-server-manifests/components.yaml"

    #Create HPA 
    kubectl autoscale deployment streaming-server-deployment --cpu-percent=50 --min=1 --max=10 -n streaming-server
}