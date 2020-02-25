#!/bin/bash

TEMPLATE_CONFIG_FILE=kind-example-config-template.yaml
CONFIG_FILE=kind-example-config.yaml

#   https://kind.sigs.k8s.io/docs/user/quick-start/
HTTP_PART='http://'
CLUSTER_ALIAS='testKindCluster'

KUBERNETES_DASHBOARD_URL='localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#/login'
K8DASH_DASHBOARD_URL='k8dash.example.com'

DASHBOARD_URL=$KUBERNETES_DASHBOARD_URL
INGRESS_TEST_MARKER='foo'

EXTRA_MOUNTS_HOST_PATH='C:\Users\vladislav.bondarchuk\Downloads\DockerMounts'
EXTRA_MOUNTS_CONTAINER_PATH='/DockerMounts'