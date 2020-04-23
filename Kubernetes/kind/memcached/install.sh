#!/usr/bin/env bash

#   export user defined variables
source ../kind_vars.sh

helm uninstall memcached

#helm install memcached stable/memcached

helm install --values values.yaml memcached stable/memcached






