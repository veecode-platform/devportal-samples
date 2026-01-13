#!/bin/bash

# test if vkdr is installed
if ! command -v vkdr &> /dev/null; then
    echo "vkdr could not be found"
    exit 1
fi

# test if vkdr is running
STATUS=$(vkdr infra status --json --silent | jq -r ".status")
if [ "READY" != "$STATUS" ]; then
    echo "vkdr is not ready, starting it..."
    vkdr infra start --traefik
else
    echo "vkdr is ready"
fi

helm upgrade veecode-devportal veecode-devportal -i \
    --repo "https://veecode-platform.github.io/next-charts" \
    --create-namespace -n platform -f values.yaml
