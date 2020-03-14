#!/bin/bash

# Example configs
# https://github.com/OpenIdentityPlatform/OpenAM/wiki/How-To-Run-OpenAM-in-Kubernetes
# https://github.com/ForgeRock/forgeops/blob/master/helm/openam/templates/openam-deployment.yaml



# If you only define the readiness probe without setting minReadySeconds
# properly, new pods are considered available immediately when the first invo-
# cation of the readiness probe succeeds. If the readiness probe starts failing
# shortly after, the bad version is rolled out across all pods. Therefore, you
# should set minReadySeconds appropriately


# export user defined variables
source ../kind_vars.sh

#create config from template
eval "echo \"$(cat openam-config-template.yaml)\"" > openam.yaml

kubectl apply -f openam.yaml

#kubectl rollout status deployment openam-app

