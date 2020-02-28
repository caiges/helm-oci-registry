#!/bin/bash

# Login to the registry.
helm registry login -u blars registry:443

# Save the local chart to Helm's local cache.
helm chart save charts/nginx/ registry:443/bitnami/nginx:5.1.7

# Push the cached chart to the image registry.
helm chart push registry:443/bitnami/nginx:5.1.7

# Pull chart from registry to local image store.
helm chart pull registry:443/bitnami/nginx:5.1.7

# Export chart from local imgae store to local directory.
helm chart export registry:443/bitnami/nginx:5.1.7

# Uninstall chart if deployed.
helm uninstall nginxtacos || true

# Install chart to Kind cluster.
helm install --kube-context kind-kind nginxtacos nginx
