#!/bin/bash

# https://github.com/kubeapps/kubeapps/releases

kubectl create namespace kubeapps
helm install kubeapps --namespace kubeapps bitnami/kubeapps

kubectl port-forward --namespace kubeapps service/kubeapps 8080:80