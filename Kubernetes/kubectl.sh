
kubectl cluster-info --context kind-testKindCluster

# Install dashboard
# http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#/login
kubectl proxy
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta6/aio/deploy/recommended.yaml
# get token
kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}')


kubectl get nodes

kubectl describe node testkindcluster-worker3

kubectl apply -f deployment-script.yaml

kubectl get pod
kubectl get pods -o wide
kubectl get pods --show-labels
kubectl get pods -L app
kubectl get po --all-namespaces
kubectl get po kubia-manual -o yaml
kubectl get ingresses
kubectl get services

kubectl describe pod pod_name

kubectl api-resources

kubectl create -f kubia-manual.yaml

kubectl logs kubia-manual
# SPECIFYING THE CONTAINER NAME WHEN GETTING LOGS OF A MULTI-CONTAINER POD
kubectl logs kubia-manual -c kubia
kubectl logs mypod --previous


kubectl port-forward kubia-manual 8888:8080


kubectl delete pods --all
kubectl delete po -l creation_method=manual
kubectl delete ns custom-namespace
kubectl delete po --all
kubectl delete all --all
kubectl delete rc kubia --cascade=false


kubectl explain pods
kubectl explain pod.spec


kubectl replace --force -f kubia-liveness-probe-initial-delay.yaml


kubectl label pod kubia-dmdck type=special
kubectl label pod kubia-dmdck app=foo --overwrite


kubectl config view


kubectl exec -it kubia-3inly bash
kubectl exec fortune-configmap-volume -c web-server ls /etc/nginx/conf.d
kubectl exec fortune-configmap-volume -c web-server -- nginx -s reload


docker exec --user="root" -it testKindCluster-worker /bin/bash




