#!/bin/bash

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
kubectl apply -f ./ingress/ingress-test-services.yaml
kubectl apply -f ./ingress/ingress-nginx.yaml


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

# Must be used after "kubectl proxy"
#checkIngressWorks
