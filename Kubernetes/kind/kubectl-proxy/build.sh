# build image
docker build -t localhost:5000/kubectl-proxy:latest .
docker push localhost:5000/kubectl-proxy:latest