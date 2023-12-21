#!/bin/bash

readonly REPO_ROOT=$(git rev-parse --show-toplevel)
source "${REPO_ROOT}/scripts/deployment_library.sh"

eval $(minikube docker-env)

function rebuild_images {

echo "Forcing to rebuild images"

echo "Building streaming server image..."
docker build -t streaming-server ${REPO_ROOT}/apps/streaming-server

echo "Building fibonacci image..."
docker build -t fibonacci ${REPO_ROOT}/apps/fibonacci

echo "Building number-verifier image..."
docker build -t number-verifier ${REPO_ROOT}/apps/number-verifier
}

for arg in "$@"; do
    case "$arg" in
    --rebuild-images)
        rebuild_images
        ;;
    --deploy-efk)
        DEPLOY_EFK=true
        ;;
    --deploy-metrics)
        DEPLOY_METRICS=true
        ;;
    --deploy-streaming-server)
        DEPLOY_STREAMING_SERVER=true
        ;;
    *)
        echo "Unknown option: $arg"
        exit 1
        ;;
    esac
done

# checking if the streaming server image exists, if not build it
if [[ "$(docker image inspect streaming-server 2> /dev/null)" == "[]" ]]; then
    echo "Streaming server image not present locally, building..."
    docker build -t streaming-server ${REPO_ROOT}/apps/streaming-server
fi
# checking if the fibonacci image exists, if not build it
if [[ "$(docker image inspect fibonacci 2> /dev/null)" == "[]" ]]; then
    echo "Fibonacci image not present locally, building..."
    docker build -t fibonacci ${REPO_ROOT}/apps/fibonacci
fi
# checking if the number-verifier image exists, if not build it
if [[ "$(docker image inspect number-verifier 2> /dev/null)" == "[]" ]]; then
    echo "number-verifier image not present locally, building..."
    docker build -t number-verifier ${REPO_ROOT}/apps/number-verifier
fi


if [ "$DEPLOY_STREAMING_SERVER" = true ]; then
    deploy_apps
    deploy_Jaeger
fi
if [ "$DEPLOY_EFK" = true ]; then
    deploy_EFK
fi
if [ "$DEPLOY_METRICS" = true ]; then
    deploy_metrics
fi