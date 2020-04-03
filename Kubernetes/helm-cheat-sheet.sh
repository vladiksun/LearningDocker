
helm <command> --help


# add charts repository
helm repo add stable https://kubernetes-charts.storage.googleapis.com
helm repo add dev https://example.com/dev-charts
helm repo update
helm repo list
helm repo remove


helm search hub
helm search repo
helm search repo stable


helm show chart stable/mysql

helm ls
helm list
helm list --all

helm install happy-panda stable/mariadb
helm install stable/mariadb --generate-name
helm install foo path/to/foo
helm install foo https://example.com/charts/foo-1.2.3.tgz

# To see what options are configurable on a chart, use helm show values
helm show values stable/mariadb

# You can then override any of these settings in a YAML formatted file, and then pass that file during installation.
echo '{mariadbUser: user0, mariadbDatabase: user0db}' > config.yaml
helm install -f config.yaml stable/mariadb --generate-name
helm install --values config.yaml stable/mariadb --generate-name

# Values that have been --set can be viewed for a given release with
helm get values <release-name>

helm create deis-workflow
# As you edit your chart, you can validate that it is well-formed by running
helm lint
helm package deis-workflow
helm install deis-workflow ./deis-workflow-0.1.0.tgz

helm upgrade -f panda.yaml happy-panda stable/mariadb

helm uninstall happy-panda
helm uninstall smiling-penguin --keep-history

helm status smiling-penguin

helm rollback [RELEASE] [REVISION]
helm rollback
helm history [RELEASE]

# To drop a dependency into your charts/ directory, use the helm pull command
helm pull


# Example
helm install full-coral ./mychart
helm get manifest full-coral
helm uninstall full-coral
helm install --debug --dry-run goodly-guppy ./mychart

