#!/bin/bash
#set -e # https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
# Any subsequent(*) commands which fail will cause the shell script to exit immediately

find ./ -name "*.sh" -exec chmod +x {} \;

# export user defined variables
source ./kind_vars.sh

# Ubuntu specific
command -v kubectl >/dev/null 2>&1 || {
  echo >&2 "Kubectl is not installed.  Aborting."
  exit 1
}
command -v kind >/dev/null 2>&1 || {
  echo >&2 "Kind is not installed.  Aborting."
  exit 1
}
command -v helm >/dev/null 2>&1 || {
  echo >&2 "Helm is not installed.  Aborting. Please refere to https://helm.sh/docs/intro/install/"
  exit 1
}

deleteCluster() {
  source ./kind_delete_cluster.sh
}

deleteCluster
# create registry container unless it already exists
source ./kind_create_local_registry.sh

#create config from template
eval "echo \"$(cat "${TEMPLATE_CONFIG_FILE}")\"" > "${CONFIG_FILE}"

#kind create cluster --name "$KIND_CLUSTER_NAME" --config "${CONFIG_FILE}" --kubeconfig "$KUBECONFIG" --verbosity 5 --wait 5m
kind create cluster --name "$KIND_CLUSTER_NAME" --config "${CONFIG_FILE}" --wait 5m --verbosity 5

# add charts repository
source ./kind_init_helm.sh

#source ./kind_install_cert_manager.sh
#source ./kind_install_oauth2_proxy.sh
source ./kind_install_ingress.sh


# Install dashboard
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta6/aio/deploy/recommended.yaml
# kubectl apply -f kubernetes-dashboard-bypass-login-v2.0.0-beta6.yaml
kubectl apply -f ./dashboard/dashboard-adminuser.yaml
kubectl apply -f ./dashboard/dashboard-adminuser-role-binding.yaml

if [ -n "$K8DASH_DASHBOARD_URL" ]; then
  # Install dashboard K8Dash
  # https://github.com/herbrandson/k8dash
  kubectl apply -f ./dashboard/kubernetes-k8dash.yaml
  # Create the service account in the current namespace (we assume default)
  kubectl create serviceaccount k8dash-sa
  # Give that service account root on the cluster
  kubectl create clusterrolebinding k8dash-sa --clusterrole=cluster-admin --serviceaccount=default:k8dash-sa
fi



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
    xdg-open "$full_url"
  elif [ "$machine" == "Cygwin" ]; then
    cygstart "$full_url"
  elif [ "$machine" == "MinGw" ]; then
    start "$full_url"
  fi
}

printDashboardToken() {
  local full_url="$HTTP_PART$DASHBOARD_URL"

  # get token
  CLUSTER_SECRET=$(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}')

  TOKEN=$(kubectl -n kubernetes-dashboard describe secret "$CLUSTER_SECRET" | grep 'token:' | awk '{print $2}')

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
  local full_url="$HTTP_PART$DASHBOARD_URL"

  declare -A statusArray=([200]=1 [308]=1)

  STATUS=0
  printf "%s" "Waiting for $full_url ..."
  printf "\n"
  printf "\n"

  while ! [[ ${statusArray[$STATUS]} ]]; do
    printf "%c" "."

    local curl_status=$(curl -s -o /dev/null -w "%{http_code}\n" "$full_url")

    # get rid off carriage return
    STATUS=${curl_status//$'\r'/}

    if [[ ${statusArray[$STATUS]} ]]; then
      printf "\n"
      echo "$full_url is up, returned $STATUS"
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
