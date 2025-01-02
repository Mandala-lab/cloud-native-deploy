#!/bin/bash

set -x
VERSION="1.20.2"
wget https://github.com/istio/istio/releases/download/1.20.2/istio-${VERSION}-linux-amd64.tar.gz

cd istio-$VERSION || exit

export PATH=$PWD/bin:$PATH

istioctl install --set profile=demo -y

kubectl label namespace default istio-injection=enabled

kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml

kubectl get svc, po

# 使用kubectl命令和JSONPath查询default命名空间中所有Pod的状态
# 如果所有Pod的状态都为Running，则执行下一步操作
# 否则等待一段时间后重新检查
# 检查default命名空间中所有Pod的状态
while [[ $(kubectl get pods -n default -o=jsonpath='{range .items[*]}{.status.phase}{"\n"}{end}' | grep -v Running) ]]; do
  echo "等待所有Pod状态为Running..."
  sleep 5
done
# 执行下一步操作
echo "所有Pod状态为Running，执行下一步操作"

kubectl exec "$(kubectl get pod -l app=ratings -o jsonpath='{.items[0].metadata.name}')" -c ratings -- curl -sS productpage:9080/productpage | grep -o "<title>.*</title>"

kubectl apply -f samples/bookinfo/networking/bookinfo-gateway.yaml

istioctl analyze

export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].port}')
export SECURE_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].port}')

export GATEWAY_URL=$INGRESS_HOST:$INGRESS_PORT

echo "$GATEWAY_URL"

echo "http://$GATEWAY_URL/productpage"

set +x
