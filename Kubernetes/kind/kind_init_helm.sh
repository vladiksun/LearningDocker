#!/bin/bash

# add charts repository
helm repo add stable https://charts.helm.sh/stable

helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
