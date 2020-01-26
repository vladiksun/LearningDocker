kubectl create -f kubia-liveness-probe.yaml

kubectl create -f kubia-liveness-probe-initial-delay.yaml

kubectl replace --force -f kubia-liveness-probe-initial-delay.yaml

kubectl get po kubia-liveness

kubectl describe po kubia-liveness