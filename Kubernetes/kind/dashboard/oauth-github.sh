#!/usr/bin/env bash

# https://blog.heptio.com/on-securing-the-kubernetes-dashboard-16b09b1b7aca

# https://github.com/settings/developers

kubectl create secret generic dashboard-proxy-secret \
  -o yaml --dry-run \
  -n kube-system \
  --from-literal=client-id=5f8e7f055d7d7e73e257 \
  --from-literal=client-secret=6945f97b2924938190965ffc916e76defd446d28 \
  --from-literal=cookie=$(openssl rand 16 -hex) > dashboard-proxy-secret.yaml





