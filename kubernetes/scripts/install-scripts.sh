helm install stable/mysql --namespace default --name mysql

kubectl create secret generic --namespace default laravel5-env --from-file=/Users/Eamon/PhpstormProjects/laravel5-5-example/.env

kubectl apply -f /Users/Eamon/PhpstormProjects/laravel5-5-example/kubernetes/kubernetes-yaml/mysql-pvc.yaml

kubectl apply -f /Users/Eamon/PhpstormProjects/laravel5-5-example/kubernetes/kubernetes-yaml/mysql-pv.yaml

helm install stable/mysql --namespace default --name mysql --set persistence.existingClaim="mysql-mysql"

helm install --namespace default --name laravel5 kubernetes/laravel5

helm install --namespace default --name laravel5 kubernetes/laravel5 --set phpfpmImage.tag=orig

kubectl patch deployment --namespace default laravel5-phpfpm --patch '{"spec": {"template": {"spec": {"containers": [{"name": "laravel5-phpfpm","image": "quay.io/eamonkeane/laravel:no-artisan"}]}}}}'
