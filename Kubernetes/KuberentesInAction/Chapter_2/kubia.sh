
kubectl run kubia --image=luksa/kubia --port=8080 --generator=run/v1

kubectl expose rc kubia --type=LoadBalancer --name kubia-http

# When using Minikube, you can get the IP and port through which you
# can access the service by running
# This does not work for KIND
!!!! minikube service kubia-http

# Access via proxy
# http://localhost:8001/api/v1/namespaces/default/services/http:kubia-http:/proxy/

kubectl get replicationcontrollers

kubectl scale rc kubia --replicas=3