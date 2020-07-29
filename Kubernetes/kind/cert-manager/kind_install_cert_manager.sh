#!/bin/bash

# https://cert-manager.io/docs/installation/kubernetes/

# Installing and Configuring Cert-Manager
# In this step, we’ll install cert-manager into our cluster. cert-manager is a Kubernetes service that provisions TLS certificates
# from Let’s Encrypt and other certificate authorities and manages their lifecycles. Certificates can be requested and configured by annotating
# Ingress Resources with the cert-manager.io/issuer annotation, appending a tls section to the Ingress spec,
# and configuring one or more Issuers or ClusterIssuers to specify your preferred certificate authority
kubectl create namespace cert-manager
helm repo add jetstack https://charts.jetstack.io
helm repo update

helm install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --version v0.16.0 \
  # --set installCRDs=true


#kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v0.13.1/cert-manager.yaml
#kubectl create -f ./cert-manager/staging_issuer.yaml
#kubectl describe certificate
#kubectl create -f ./cert-manager/prod_issuer.yaml
