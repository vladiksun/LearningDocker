#!/usr/bin/env bash

#   export user defined variables
source ../kind_vars.sh

# build image
docker build -t localhost:5000/dev-tools:latest .
docker push localhost:5000/dev-tools:latest

#kubectl apply -f tools.yaml


kubectl run my-shell --rm -i --tty --image ubuntu:18.04 -- bash

kubectl run my-shell --rm -i --tty --image localhost:5000/dev-tools:latest -- bash










