#!/usr/bin/env bash

#   export user defined variables
source ../kind_vars.sh
source ../functions.sh --source-only

#   create config from template
eval "echo \"$(cat mailslurper-config-statefullset-via-pv-template.yaml)\"" > mailslurper-config-statefullset.yaml
kubectl apply -f mailslurper-config-statefullset.yaml

                   #podNumber  hostPort  nodePort   podName           searchLabel
forwardPortForNode   0          8082      8082    "mailslurper-app"   "app=mailslurper-app"
forwardPortForNode   0          8085      8085    "mailslurper-app"   "app=mailslurper-app"
forwardPortForNode   0          2500      2500    "mailslurper-app"   "app=mailslurper-app"


