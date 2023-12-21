#!/bin/bash

readonly REPO_ROOT=$(git rev-parse --show-toplevel)

function deploy_EFK {
    #Create a namespace
    kubectl apply -f "${REPO_ROOT}/k8s/namespaces/monitoring-logs-ns.yaml"

    #Deploy EFK stack
    EFK_STACK_PATH="${REPO_ROOT}/k8s/monitoring-manifests/EFK-stack-manifests"
    for dir in "${EFK_STACK_PATH}"/*; do
        for yaml_file in "${dir}"/*.yaml; do
            kubectl apply -f "$yaml_file"
        done
    done
}

function deploy_Jaeger {
    kubectl apply -f "${REPO_ROOT}/k8s/namespaces/monitoring-traces-ns.yaml"

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

function deploy_metrics {
    kubectl create namespace monitoring-metrics
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    helm repo update
    helm install metrics prometheus-community/kube-prometheus-stack --namespace monitoring-metrics
    sleep 45
    kubectl port-forward service/metrics-kube-state-metrics 2137:8080 -n monitoring-metrics &
    kubectl port-forward service/metrics-grafana 2138:80 -n monitoring-metrics &
    kubectl port-forward service/metrics-kube-prometheus-st-prometheus 2139:9090 -n monitoring-metrics &
}