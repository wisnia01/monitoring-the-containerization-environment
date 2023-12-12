#!/bin/bash

helm uninstall metrics -n monitoring-metrics
kill $(lsof -t -i:2137)
kill $(lsof -t -i:2138)
kill $(lsof -t -i:2139)
kubectl delete namespace monitoring-metrics
