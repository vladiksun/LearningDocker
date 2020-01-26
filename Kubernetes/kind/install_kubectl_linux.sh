KUBECTL_LOCATION=/home/vlad/.local/bin/

curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
chmod +x ./kubectl
mkdir --parents $KUBECTL_LOCATION
mv ./kubectl $KUBECTL_LOCATION

kubectl version