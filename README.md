## Quick Start ##

* Create cluster: 
    - allow all Cloud APIs for nodes
    - enable VPC native

```bash
kubectl create namespace laravel5
kubectl create secret --namespace=laravel5 docker-registry regcred --docker-server=registry.gitlab.com --docker-username=[MY_PROFILE] --docker-password=[MY_PASSWORD] --docker-email=[MY_EMAIL]
kubectl apply -f kubernetes/kubernetes-yaml/rbac-tiller.yaml
helm init --tiller-namespace laravel5 --service-account tiller
export TILLER_NAMESPACE=laravel5
helm install stable/nginx-ingress --wait --name nginx-ingress --namespace laravel5 --set rbac.create=true,controller.service.externalTrafficPolicy=Local,controller.service.loadBalancerIP="104.155.181.89"
INGRESS_IP=$(kubectl get svc --namespace laravel5 --selector=app=nginx-ingress,component=controller -o jsonpath='{.items[0].status.loadBalancer.ingress[0].ip}');echo ${INGRESS_IP}
helm install stable/cert-manager --version 0.2.10 --name cert-manager --namespace laravel5 --set ingressShim.extraArgs='{--default-issuer-name=letsencrypt-prod,--default-issuer-kind=ClusterIssuer}','extraArgs={--v=4}'
kubectl apply -f kubernetes/kubernetes-yaml/acme-prod-cluster-issuer.yaml
docker build . -t ${MY_PHP_REPO} -f docker/php-fpm/Dockerfile; docker push ${MY_PHP_REPO}
docker build . -t ${MY_NGINX_REPO} -f docker/nginx/Dockerfile; docker push ${MY_NGINX_REPO}
REWRITE URL BASED ON INGRESS IP HERE: kubernetes/helm/laravel5/laravel5-env.env AND HERE: kubernetes/helm/laravel5/values.yaml
helm upgrade --install --wait --timeout 400 --set phpfpmImage.repository=${MY_PHP_REPO},nginxImage.repository=${MY_NGINX_REPO} --namespace laravel5 laravel5 kubernetes/helm/laravel5
```
