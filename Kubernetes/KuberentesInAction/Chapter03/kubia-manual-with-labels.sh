kubectl create -f kubia-manual-with-labels.yaml

kubectl get po --show-labels

kubectl get po -L creation_method,env

kubectl label po kubia-manual creation_method=manual

kubectl label po kubia-manual-v2 env=debug --overwrite

kubectl get po -l creation_method=manual

kubectl get po -l env

kubectl get po -l '!env'

kubectl get po -l creation_method!=manual

kubectl get po -l 'env in (prod,devel)'

kubectl get po -l 'env notin (prod,devel)'