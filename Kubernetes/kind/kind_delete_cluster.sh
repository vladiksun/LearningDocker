#!/bin/bash

# export user defined variables
source ./kind_vars.sh

deleteCluster() {
  kind delete cluster --name "$KIND_CLUSTER_NAME"
}

deleteCluster
