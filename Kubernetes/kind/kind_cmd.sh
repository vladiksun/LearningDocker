#   https://kind.sigs.k8s.io/docs/user/quick-start/

kind create cluster --name testKindCluster --config kind-example-config.yaml --loglevel debug --wait 5m

kind get clusters

kubectl cluster-info --context kind-testKindCluster


kind delete cluster
kind delete cluster --name testKindCluster

kind export logs --name testKindCluster

docker system prune



http://127.0.0.1:8001/api/v1/namespaces/default/services/http:mailslurper-service:/proxy/#/

###################### Load image to kind example ####################
kind load docker-image camunda-excamad:local


kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: camunda-excamad-test
spec:
  containers:
  - name: camunda-excamad-test
    image: camunda-excamad:local
EOF

