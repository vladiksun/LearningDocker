#!/usr/bin/env bash

#   export user defined variables
source ../kind_vars.sh

helm install memcached stable/memcached

helm install --values values.yaml memcached stable/memcached

helm upgrade --values values.yaml memcached stable/memcached


helm uninstall memcached

############################
export POD_NAME=$(kubectl get pods --namespace default \
-l "app.kubernetes.io/name=memcached,app.kubernetes.io/instance=memcached" -o jsonpath="{.items[0].metadata.name}")

kubectl port-forward $POD_NAME 11211

#####################

kubectl get pods --field-selector=status.phase=Running,metadata.name=memcached-0
kubectl get pods --field-selector=status.phase=Running,metadata.name=memcached-0 | grep "1/1" | awk '{print $2}'

kubectl port-forward $(kubectl get pods --namespace default -l "app.kubernetes.io/name=memcached,app.kubernetes.io/instance=memcached" -o jsonpath="{.items[0].metadata.name}") 11211:11211
kubectl port-forward $(kubectl get pods --namespace default -l "app.kubernetes.io/name=memcached,app.kubernetes.io/instance=memcached" -o jsonpath="{.items[1].metadata.name}") 11212:11211


#kubectl patch configmap tcp-services -n ingress-nginx --patch '{"data":{"11211":"default/memcached:11211"}}'
#kubectl patch deployment nginx-ingress-controller --patch "$(cat nginx-ingress-controller-patch.yaml)" -n ingress-nginx


#kubectl apply -f memcached.yaml




