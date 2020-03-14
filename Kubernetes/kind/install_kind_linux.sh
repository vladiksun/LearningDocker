# https://kind.sigs.k8s.io/docs/user/quick-start

KIND_LOCATION=/home/vlad/.local/bin/

curl -Lo ./kind https://github.com/kubernetes-sigs/kind/releases/download/v0.6.1/kind-$(uname)-amd64
chmod +x ./kind
mkdir --parents $KIND_LOCATION
mv ./kind $KIND_LOCATION
kind