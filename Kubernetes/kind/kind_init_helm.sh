#!/bin/bash

# add charts repository
helm repo add stable https://kubernetes-charts.storage.googleapis.com

helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
