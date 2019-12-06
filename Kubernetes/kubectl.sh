
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

kubectl get pods

kubectl api-resources

kubectl delete pods --all

kubectl get services


