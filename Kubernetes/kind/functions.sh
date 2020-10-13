#!/usr/bin/env bash

error_exit() {
  #	----------------------------------------------------------------
  #	Function for exit due to fatal program error
  #		Accepts 1 argument:
  #			string containing descriptive error message
  #	----------------------------------------------------------------
  PROGNAME=$(basename $0)
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

forwardPortForNode() {
  local podNumber=$1
  local hostPort=$2
  local nodePort=$3
  local podName=$4
  local searchLabel=$5

  local name_to_check="$podName-$podNumber"
  local ready_marker="1/1"

  printf "\n"
  printf "\n"
  echo "Waiting for Pod $podNumber "

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

  port_forward_cmd=$(kubectl port-forward "$(kubectl get pods --namespace default -l "$searchLabel" -o jsonpath="{.items[$podNumber].metadata.name}")" "$hostPort:$nodePort")
  getOS

  if [ "$machine" == "Linux" ]; then
    gnome-terminal -x sh -c "$port_forward_cmd; bash"
  elif [ "$machine" == "Cygwin" ]; then
    printf "\n"
    echo "Pod $podNumber is available. Forwarding ports...."
    #TODO - check port_forward_cmd above
    cygstart mintty --hold always --exec kubectl port-forward $(kubectl get pods --namespace default -l $searchLabel -o jsonpath="{.items[$pod_number].metadata.name}") $hostPort:$nodePort
  elif [ "$machine" == "MinGw" ]; then
    error_exit "No Mac OS impl found"
  fi
}


if [ "${1}" != "--source-only" ]; then
    main "${@}"
fi
