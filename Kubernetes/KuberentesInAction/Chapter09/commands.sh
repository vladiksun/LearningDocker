#!/bin/bash

kubectl create -f kubia-deployment-v1.yaml --record

kubectl rollout status deployment kubia

kubectl patch deployment kubia -p '{"spec": {"minReadySeconds": 10}}'

kubectl set image deployment kubia nodejs=luksa/kubia:v2

kubectl set image deployment kubia nodejs=luksa/kubia:v3

kubectl rollout status deployment kubia

while true; do curl http://130.211.109.222; done

kubectl rollout undo deployment kubia

kubectl rollout history deployment kubia

kubectl rollout undo deployment kubia --to-revision=1

kubectl set image deployment kubia nodejs=luksa/kubia:v4
kubectl rollout pause deployment kubia
kubectl rollout resume deployment kubia