#!/bin/bash


kubectl create namespace monitoring-metrics
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install metrics prometheus-community/kube-prometheus-stack --namespace monitoring-metrics
sleep 45
kubectl port-forward service/metrics-kube-state-metrics 2137:8080 -n monitoring-metrics &
kubectl port-forward service/metrics-grafana 2138:80 -n monitoring-metrics &
kubectl port-forward service/metrics-kube-prometheus-st-prometheus 2139:9090 -n monitoring-metrics &
