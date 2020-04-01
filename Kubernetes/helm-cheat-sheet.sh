# add charts repository
helm repo add stable https://kubernetes-charts.storage.googleapis.com
helm repo add dev https://example.com/dev-charts
helm repo update
helm repo list
helm repo remove


helm search repo stable

helm show chart stable/mysql

helm ls
helm list
helm list --all

helm uninstall smiling-penguin --keep-history
helm status smiling-penguin

helm rollback

helm search hub
helm search repo

helm install happy-panda stable/mariadb

helm install stable/mariadb --generate-name

helm show values stable/mariadb

echo '{mariadbUser: user0, mariadbDatabase: user0db}' > config.yaml
helm install -f config.yaml stable/mariadb --generate-name


helm create deis-workflow
helm lint
helm package deis-workflow
helm install deis-workflow ./deis-workflow-0.1.0.tgz