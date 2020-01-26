kubectl get ns

kubectl get po --namespace kube-system

kubectl create -f custom-namespace.yaml

kubectl create namespace custom-namespace

kubectl create -f kubia-manual.yaml -n custom-namespace