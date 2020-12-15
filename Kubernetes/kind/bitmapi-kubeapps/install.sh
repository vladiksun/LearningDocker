#!/bin/bash

# https://github.com/kubeapps/kubeapps/releases

kubectl create namespace kubeapps
helm install kubeapps --namespace kubeapps bitnami/kubeapps