#   https://kind.sigs.k8s.io/docs/user/quick-start/

CLUSTER_ALIAS='testKindCluster'
DASHBOARD_URL='http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#/login'

kind delete cluster --name $CLUSTER_ALIAS
kind create cluster --name $CLUSTER_ALIAS --config kind-example-config.yaml --loglevel debug --wait 5m
# Install dashboard

kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta6/aio/deploy/recommended.yaml
#kubectl apply -f dashboard-v2.0.0-beta6-skip-login.yaml

kubectl apply -f dashboard-adminuser.yaml
kubectl apply -f dashboard-adminuser-role-binding.yaml

# get token
CLUSTER_SECRET=$(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}')

TOKEN=$(kubectl -n kubernetes-dashboard describe secret $CLUSTER_SECRET | grep 'token:' | awk '{print $2}')

printf "\n"
printf "\n"
printf "\n"
printf "****************************************************************************************************************"
printf "\n"
printf "Dashboard URL is:   $DASHBOARD_URL"
printf "\n"
printf "\n"
printf "Dashboard Login token is :   \n$TOKEN"

# Command to find if the port 8001 is occupaid already
#netstat -atno | grep -w '8001' | awk '{print $5}'
#netstat -atno | findstr :8001

# start proxy to make dashboard available on
# http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#/login
printf "\n"
printf "\n"
printf "Starting proxy to enable Kubernetes dashboard\n"
kubectl proxy


