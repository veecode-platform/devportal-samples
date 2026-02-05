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

# create namespace (idempotent)
kubectl create namespace platform || true

# create secret (idempotent)
kubectl create secret generic backstage-secrets -n platform \
    "--from-literal=KEYCLOAK_BASE_URL=$KEYCLOAK_BASE_URL" \
    "--from-literal=KEYCLOAK_REALM=$KEYCLOAK_REALM" \
    "--from-literal=KEYCLOAK_CLIENT_ID=$KEYCLOAK_CLIENT_ID" \
    "--from-literal=KEYCLOAK_CLIENT_SECRET=$KEYCLOAK_CLIENT_SECRET" \
    "--from-literal=AUTH_SESSION_SECRET=$AUTH_SESSION_SECRET" \
    --dry-run=client -o yaml | kubectl apply -f -

helm upgrade veecode-devportal veecode-devportal -i \
    --repo "https://veecode-platform.github.io/next-charts" \
    --create-namespace -n platform -f values.yaml
