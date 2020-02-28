#!/bin/bash

helm registry login -u blars registry:443
helm chart save charts/nginx/ registry:443/bitnami/nginx:5.1.7
helm chart push registry:443/bitnami/nginx:5.1.7
helm chart pull registry:443/bitnami/nginx:5.1.7
helm chart export registry:443/bitnami/nginx:5.1.7
helm uninstall nginxtacos || true
helm install --kube-context kind-kind nginxtacos nginx
