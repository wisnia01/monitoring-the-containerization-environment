#!/bin/bash

kubectl delete -f ../streaming-server-deployment.yaml
kubectl delete -f ../fibonacci-deployment.yaml
kubectl delete -f ../streaming-server-service.yaml
kubectl delete -f ../fibonacci-service.yaml