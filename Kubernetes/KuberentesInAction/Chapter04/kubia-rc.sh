kubectl create -f kubia-rc.yaml

kubectl get rc

kubectl describe rc kubia

kubectl label pod kubia-dmdck type=special

kubectl get pods --show-labels

kubectl edit rc kubia

kubectl scale rc kubia --replicas=10

kubectl delete rc kubia --cascade=false
