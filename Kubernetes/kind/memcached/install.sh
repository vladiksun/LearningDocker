#!/usr/bin/env bash

#   export user defined variables
source ../kind_vars.sh

PROGNAME=$(basename $0)

error_exit() {

  #	----------------------------------------------------------------
  #	Function for exit due to fatal program error
  #		Accepts 1 argument:
  #			string containing descriptive error message
  #	----------------------------------------------------------------

  echo "${PROGNAME}: ${1:-"Unknown Error"}" 1>&2
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

forwardPortForNode() {
  local pod_number=$1
  local hostPort=$2
  local name_to_check="memcached-$pod_number"
  local ready_marker="1/1"

  printf "\n"
  printf "\n"
  echo "Waiting for Pod $pod_number "

  local name_from_cluster=$(kubectl get pods --field-selector=status.phase=Running,metadata.name="$name_to_check" --ignore-not-found | grep "$name_to_check" | awk '{print $1}')
  local is_ready_marker=$(kubectl get pods --field-selector=status.phase=Running,metadata.name="$name_to_check" --ignore-not-found | grep "$ready_marker" | awk '{print $2}')

  # Ping until available
  while [[ "$name_from_cluster" != "$name_to_check" ]] || [[ "$ready_marker" != "$is_ready_marker" ]]; do
    if [[ "$name_from_cluster" != "$name_to_check" ]] || [[ "$ready_marker" != "$is_ready_marker" ]]; then
      printf "%c" "."
    fi

    name_from_cluster=$(kubectl get pods --field-selector=status.phase=Running,metadata.name="$name_to_check" | grep "$name_to_check" | awk '{print $1}')
    is_ready_marker=$(kubectl get pods --field-selector=status.phase=Running,metadata.name="$name_to_check" | grep "$ready_marker" | awk '{print $2}')
  done

  getOS

  if [ "$machine" == "Linux" ]; then
    error_exit "No Linux impl found"
  elif [ "$machine" == "Cygwin" ]; then
    printf "\n"
    echo "Pod $pod_number is available. Forwarding ports...."
    cygstart mintty --hold always --exec kubectl port-forward $(kubectl get pods --namespace default -l "app.kubernetes.io/name=memcached,app.kubernetes.io/instance=memcached" -o jsonpath="{.items[$pod_number].metadata.name}") $hostPort:11211
  elif [ "$machine" == "MinGw" ]; then
    error_exit "No Mac OS impl found"
  fi

  return $status
}

helm uninstall memcached >/dev/null 2>&1
#helm install memcached stable/memcached
helm install --values values.yaml memcached stable/memcached

forwardPortForNode 0 11211
forwardPortForNode 1 11212
