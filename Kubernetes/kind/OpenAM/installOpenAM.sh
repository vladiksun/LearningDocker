#!/bin/bash

kubectl apply -f openAM-pv-hostpath.yaml
kubectl apply -f openAM-pvc.yaml
kubectl apply -f openAM-service.yaml
kubectl apply -f ingress-nginx-openam_v2.yaml
