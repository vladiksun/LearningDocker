kubectl create -f ssd-monitor-daemonset.yaml

kubectl get ds

kubectl get po

kubectl label node testkindcluster-worker disk=ssd

kubectl delete ds ssd-monitor