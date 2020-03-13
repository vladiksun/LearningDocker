#!/bin/bash

# https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/
#KUBECONFIG="$HOME/.kube/config"

TEMPLATE_CONFIG_FILE=kind-example-config-template.yaml
CONFIG_FILE=kind-example-config.yaml

#   https://kind.sigs.k8s.io/docs/user/quick-start/
HTTP_PART='http://'

# desired cluster name; default is "kind"
KIND_CLUSTER_NAME="${KIND_CLUSTER_NAME:-kind}"

KUBERNETES_DASHBOARD_URL='localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#/login'
K8DASH_DASHBOARD_URL='k8dash.example.com'

DASHBOARD_URL=$KUBERNETES_DASHBOARD_URL
INGRESS_TEST_MARKER='foo'

EXTRA_MOUNTS_HOST_PATH='C:\Users\vladislav.bondarchuk\Downloads\DockerMounts'
EXTRA_MOUNTS_CONTAINER_PATH='/DockerMounts'

# docker run -ti --rm python:3-alpine python -c 'import secrets,base64; print(base64.b64encode(base64.b64encode(secrets.token_bytes(16))));'
OAUTH2_PROXY_CLIENT_ID='5f8e7f055d7d7e73e257'
OAUTH2_PROXY_CLIENT_SECRET='6945f97b2924938190965ffc916e76defd446d28'
OAUTH2_PROXY_COOKIE_SECRET='Vj2gkDun8eNmBk2MqReVIg=='

# registry container options
reg_name='kind-registry'
reg_port='5000'