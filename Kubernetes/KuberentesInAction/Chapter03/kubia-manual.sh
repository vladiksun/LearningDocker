kubectl create -f kubia-manual.yaml

kubectl get po kubia-manual -o yaml

kubectl get po kubia-manual -o json

kubectl get pods

kubectl logs kubia-manual

kubectl logs kubia-manual -c kubia

kubectl port-forward kubia-manual 8888:8080
curl localhost:8888