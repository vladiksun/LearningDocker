#!/bin/bash

kubectl -n default create secret generic oauth2-proxy-creds \
--from-literal=cookie-secret="$OAUTH2_PROXY_COOKIE_SECRET" \
--from-literal=client-id="$OAUTH2_PROXY_CLIENT_ID" \
--from-literal=client-secret="$OAUTH2_PROXY_CLIENT_SECRET"

helm repo add stable https://kubernetes-charts.storage.googleapis.com

helm repo update \
&& helm upgrade oauth2-proxy --install stable/oauth2-proxy \
--reuse-values \
--values ./oauth2-proxy/oauth2-proxy-values.yaml
kubectl apply -f ./oauth2-proxy/oauth2-proxy-ingress.yaml