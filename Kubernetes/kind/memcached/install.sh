#!/usr/bin/env bash

#   export user defined variables
source ../kind_vars.sh
source ../functions.sh --source-only

helm uninstall memcached >/dev/null 2>&1

# https://artifacthub.io/packages/helm/bitnami/memcached
# https://github.com/bitnami/bitnami-docker-memcached
helm install --values values.yaml memcached bitnami/memcached

                   #podNumber  hostPort  nodePort   podName      searchLabel
forwardPortForNode   0          11211     11211    "memcached"   "app.kubernetes.io/name=memcached,app.kubernetes.io/instance=memcached"
forwardPortForNode   1          11212     11211    "memcached"   "app.kubernetes.io/name=memcached,app.kubernetes.io/instance=memcached"
