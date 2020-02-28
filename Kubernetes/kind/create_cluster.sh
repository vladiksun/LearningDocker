#!/bin/bash
#set -e # https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
# Any subsequent(*) commands which fail will cause the shell script to exit immediately

find ./ -name "*.sh" -exec chmod +x {} \;

# export user defined variables
source ./vars.sh

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
  kind delete cluster --name "$CLUSTER_ALIAS"
}

deleteCluster


#create config from template
eval "echo \"$(cat "${TEMPLATE_CONFIG_FILE}")\"" > "${CONFIG_FILE}"

#kind create cluster --name "$CLUSTER_ALIAS" --config "${CONFIG_FILE}" --kubeconfig "$KUBECONFIG" --verbosity 5 --wait 5m
kind create cluster --name "$CLUSTER_ALIAS" --config "${CONFIG_FILE}" --wait 5m --verbosity 5

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

# Installing and Configuring Cert-Manager
# In this step, we’ll install cert-manager into our cluster. cert-manager is a Kubernetes service that provisions TLS certificates
# from Let’s Encrypt and other certificate authorities and manages their lifecycles. Certificates can be requested and configured by annotating
# Ingress Resources with the cert-manager.io/issuer annotation, appending a tls section to the Ingress spec,
# and configuring one or more Issuers or ClusterIssuers to specify your preferred certificate authority
kubectl create namespace cert-manager
kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v0.13.1/cert-manager.yaml
kubectl create -f ./oauth2-proxy/staging_issuer.yaml
kubectl describe certificate
kubectl create -f ./oauth2-proxy/prod_issuer.yaml

kubectl -n default create secret generic oauth2-proxy-creds \
--from-literal=cookie-secret="$OAUTH2_PROXY_COOKIE_SECRET" \
--from-literal=client-id="$OAUTH2_PROXY_CLIENT_ID" \
--from-literal=client-secret="$OAUTH2_PROXY_CLIENT_SECRET"

helm repo add stable https://kubernetes-charts.storage.googleapis.com

helm repo update \
&& helm upgrade oauth2-proxy --install stable/oauth2-proxy \
--reuse-values \
--values ./oauth2-proxy/oauth2-proxy-values.yaml
kubectl apply -f ./oauth2-proxy/oauth2-proxy-ingress.yaml


# Install dashboard
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta6/aio/deploy/recommended.yaml
# kubectl apply -f kubernetes-dashboard-bypass-login-v2.0.0-beta6.yaml
kubectl apply -f ./dashboard/dashboard-adminuser.yaml
kubectl apply -f ./dashboard/dashboard-adminuser-role-binding.yaml

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

  if [ "$SERVICE_VIA_INGRESS_STATUS" == "$INGRESS_TEST_MARKER" ]; then
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
