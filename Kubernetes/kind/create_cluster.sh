#!/bin/bash
#set -e # https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
# Any subsequent(*) commands which fail will cause the shell script to exit immediately

#   https://kind.sigs.k8s.io/docs/user/quick-start/
HTTP_PART='http://'
CLUSTER_ALIAS='testKindCluster'

KUBERNETES_DASHBOARD_URL='localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#/login'
K8DASH_DASHBOARD_URL='k8dash.example.com'

DASHBOARD_URL=$KUBERNETES_DASHBOARD_URL
INGRESS_TEST_MARKER='foo'

# Ubuntu specific
command -v kubectl >/dev/null 2>&1 || {
  echo >&2 "Kubectl is not installed.  Aborting."
  exit 1
}
command -v kind >/dev/null 2>&1 || {
  echo >&2 "Kind is not installed.  Aborting."
  exit 1
}

deleteCluster() {
  kind delete cluster --name $CLUSTER_ALIAS
}

deleteCluster

kind create cluster --name $CLUSTER_ALIAS --config kind-example-config.yaml --loglevel debug --wait 5m

# Install Ingress NGINX
# Apply the mandatory ingress-nginx components
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/nginx-0.28.0/deploy/static/mandatory.yaml
# and expose the nginx service using NodePort.
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/nginx-0.28.0/deploy/static/provider/baremetal/service-nodeport.yaml
# Apply kind specific patches to forward the hostPorts to the ingress controller, set taint tolerations and schedule it to the custom labelled node.
kubectl patch deployments -n ingress-nginx nginx-ingress-controller -p '{"spec":{"template":{"spec":{"containers":[{"name":"nginx-ingress-controller","ports":[{"containerPort":80,"hostPort":80},{"containerPort":443,"hostPort":443}]}],"nodeSelector":{"ingress-ready":"true"},"tolerations":[{"key":"node-role.kubernetes.io/master","operator":"Equal","effect":"NoSchedule"}]}}}}'
# Create TLS secret to support https
kubectl create secret tls tls-secret --cert=tls.cert --key=tls.key

# Apply test services to test ingress works
# https://kind.sigs.k8s.io/docs/user/ingress/
kubectl apply -f ingress-test-services.yaml
kubectl apply -f ingress-nginx.yaml

# Install dashboard
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta6/aio/deploy/recommended.yaml
# kubectl apply -f kubernetes-dashboard-bypass-login-v2.0.0-beta6.yaml
kubectl apply -f dashboard-adminuser.yaml
kubectl apply -f dashboard-adminuser-role-binding.yaml

if [ -n "$K8DASH_DASHBOARD_URL" ]; then
  # Install dashboard K8Dash
  # https://github.com/herbrandson/k8dash
  kubectl apply -f kubernetes-k8dash.yaml
  # Create the service account in the current namespace (we assume default)
  kubectl create serviceaccount k8dash-sa
  # Give that service account root on the cluster
  kubectl create clusterrolebinding k8dash-sa --clusterrole=cluster-admin --serviceaccount=default:k8dash-sa
fi

checkIngressWorks() {
  SERVICE_VIA_INGRESS_STATUS=$(curl s -o /dev/null --connect-timeout 3 --max-time 5 localhost/$INGRESS_TEST_MARKER)

  if [ $SERVICE_VIA_INGRESS_STATUS == $INGRESS_TEST_MARKER ]; then
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

abort() {
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

getOS() {
  unameOut="$(uname -s)"
  case "${unameOut}" in
  Linux*) machine=Linux ;;
  Darwin*) machine=Mac ;;
  CYGWIN*) machine=Cygwin ;;
  MINGW*) machine=MinGw ;;
  *) machine="UNKNOWN:${unameOut}" ;;
  esac
}

openDashboard() {
  getOS

  local full_url="$HTTP_PART$DASHBOARD_URL"

  if [ "$machine" == "Linux" ]; then
    xdg-open $full_url
  elif [ "$machine" == "Cygwin" ]; then
    cygstart $full_url
  elif [ "$machine" == "MinGw" ]; then
    start $full_url
  fi
}

printDashboardToken() {
  local full_url="$HTTP_PART$DASHBOARD_URL"

  # get token
  CLUSTER_SECRET=$(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}')

  TOKEN=$(kubectl -n kubernetes-dashboard describe secret $CLUSTER_SECRET | grep 'token:' | awk '{print $2}')

  printf "\n"
  printf "\n"
  printf "\n"
  printf "****************************************************************************************************************\n"
  echo -e "Kubernetes Dashboard URL is:   \e[92m$full_url \e[0m"
  printf "\n"
  echo -e "Kubernetes Dashboard Login token is : \n\e[96m$TOKEN \e[0m"
  printf "\n"
  printf "****************************************************************************************************************\n"

  if [ -n "$K8DASH_DASHBOARD_URL" ]; then
    printf "****************************************************************************************************************\n"
    printf "\e[92m Alternative Dashboard: $HTTP_PART$K8DASH_DASHBOARD_URL \e[0m \n"
    printf "\e[92m Get token by following the rules at https://github.com/herbrandson/k8dash \e[0m \n"
    printf "****************************************************************************************************************\n"
  fi
}

pingDashboard() {
  declare -A statusArray=([200]=1 [308]=1)

  STATUS=0
  printf "%s" "Waiting for $DASHBOARD_URL ..."
  printf "\n"
  printf "\n"

  while ! [[ ${statusArray[$STATUS]} ]]; do
    printf "%c" "."
    CURL_STATUS=$(curl -s -o /dev/null -w "%{http_code}\n" $DASHBOARD_URL)

    # get rid off carriage return
    STATUS=${CURL_STATUS//$'\r'/}

    if [[ ${statusArray[$STATUS]} ]]; then
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
printDashboardToken

if [ $DASHBOARD_URL == $KUBERNETES_DASHBOARD_URL ]; then
  pingDashboard &
  # start proxy to make dashboard available on
  # http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#/login
  printf "\n"
  printf "\n"
  printf "Starting proxy to enable Kubernetes dashboard\n"
  kubectl proxy
else
  pingDashboard
fi
