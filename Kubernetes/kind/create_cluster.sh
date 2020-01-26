#   https://kind.sigs.k8s.io/docs/user/quick-start/

CLUSTER_ALIAS='testKindCluster'
DASHBOARD_URL='http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#/login'
INGRESS_TEST_MARKER='foo'

# Ubuntu specific
command -v kubectl >/dev/null 2>&1 || { echo >&2 "Kubectl is not installed.  Aborting."; exit 1; }
command -v kind >/dev/null 2>&1 || { echo >&2 "Kind is not installed.  Aborting."; exit 1; }

deleteCluster() {
  kind delete cluster --name $CLUSTER_ALIAS
}

deleteCluster

kind create cluster --name $CLUSTER_ALIAS --config kind-example-config.yaml --loglevel debug --wait 5m

# Install dashboard
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta6/aio/deploy/recommended.yaml
#kubectl apply -f dashboard-v2.0.0-beta6-skip-login.yaml
kubectl apply -f dashboard-adminuser.yaml
kubectl apply -f dashboard-adminuser-role-binding.yaml


# Install Ingress NGINX
  # Apply the mandatory ingress-nginx components
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/nginx-0.27.0/deploy/static/mandatory.yaml
  # and expose the nginx service using NodePort.
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/nginx-0.27.0/deploy/static/provider/baremetal/service-nodeport.yaml
# Apply kind specific patches to forward the hostPorts to the ingress controller, set taint tolerations and schedule it to the custom labelled node.
kubectl patch deployments -n ingress-nginx nginx-ingress-controller -p '{"spec":{"template":{"spec":{"containers":[{"name":"nginx-ingress-controller","ports":[{"containerPort":80,"hostPort":80},{"containerPort":443,"hostPort":443}]}],"nodeSelector":{"ingress-ready":"true"},"tolerations":[{"key":"node-role.kubernetes.io/master","operator":"Equal","effect":"NoSchedule"}]}}}}'
# Create TLS secret to support https
kubectl create secret tls tls-secret --cert=tls.cert --key=tls.key
# Apply test services to test ingress works
# https://kind.sigs.k8s.io/docs/user/ingress/
kubectl apply -f ingress-test-services.yaml

checkIngressWorks() {
  SERVICE_VIA_INGRESS_STATUS=$(curl s -o /dev/null --connect-timeout 3 --max-time 5 localhost/$INGRESS_TEST_MARKER)

  if [ $SERVICE_VIA_INGRESS_STATUS == $INGRESS_TEST_MARKER ]
  then
    printf "\n"
    echo "Ingress is active and OK"
    printf "\n"
  else
    printf "\n"
    echo "ERROR - Ingress is no active and KO"
    printf "\n"
    abort
  fi
}

abort()
{
  deleteCluster
  echo >&2 '
********************************************************
********************** ABORTED *************************
********************************************************
'
  echo "An error occurred. Exiting..." >&2
  exit 1
}

# Must be used after "kubectl proxy"
#checkIngressWorks


# get token
CLUSTER_SECRET=$(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}')

TOKEN=$(kubectl -n kubernetes-dashboard describe secret $CLUSTER_SECRET | grep 'token:' | awk '{print $2}')

printf "\n"
printf "\n"
printf "\n"
printf "****************************************************************************************************************"
printf "\n"
echo -e "Dashboard URL is:   \e[46m$DASHBOARD_URL\e[0m"
printf "\n"
printf "\n"
echo -e "Dashboard Login token is :   \n\n \e[42m$TOKEN\e[0m"
printf "\n"


getOS() {
  unameOut="$(uname -s)"
  case "${unameOut}" in
      Linux*)     machine=Linux;;
      Darwin*)    machine=Mac;;
      CYGWIN*)    machine=Cygwin;;
      MINGW*)     machine=MinGw;;
      *)          machine="UNKNOWN:${unameOut}"
  esac
}

openDashboard() {
  getOS

  if [ "$machine" == "Linux" ]
  then
     xdg-open $DASHBOARD_URL
  elif [ "$machine" == "Cygwin" ]
  then
     cygstart $DASHBOARD_URL
  elif [ "$machine" == "MinGw" ]
  then
     start $DASHBOARD_URL
  fi
}

pingDashboard() {
  STATUS=0
  printf "%s" "Waiting for $DASHBOARD_URL ..."
  printf "\n"
  printf "\n"
  while ! [ $STATUS == 200 ]
  do
      printf "%c" "."
      CURL_STATUS=$(curl -s -o /dev/null -w "%{http_code}\n" $DASHBOARD_URL)

      # get rid off carriage return
      STATUS=${CURL_STATUS//$'\r'}

      if [ $STATUS == 200 ]
      then
          printf "\n"
          echo "$DASHBOARD_URL is up, returned $STATUS"
          echo "Dashboard is available"

          openDashboard
      else
          printf "%c" "."
      fi
  done
}

# spawn background process to ping if dashboard is available
pingDashboard &

# start proxy to make dashboard available on
# http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#/login
printf "\n"
printf "\n"
printf "Starting proxy to enable Kubernetes dashboard\n"
kubectl proxy


