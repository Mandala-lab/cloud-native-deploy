#!/usr/bin/env bash
# 启用 POSIX 模式并设置严格的错误处理机制
set -o posix errexit -o pipefail

mkdir -p /home/kubernetes/higress
cd /home/kubernetes/higress

helm repo add higress.io https://higress.io/helm-charts

# 没有LB的情况, 需要添加higress-core.gateway.hostNetwork，让 Higress 监听本机端口，再通过其他软/硬负载均衡器转发给固定机器 IP:
helm install higress higress.io/higress \
  -n higress-system \
  --create-namespace \
  --render-subchart-notes \
  --set higress-console.service.type=NodePort \
  --set higress-core.controller.resources.requests.cpu=500m \
  --set higress-core.controller.resources.requests.memory=1Gi \
  --set higress-core.gateway.replicas=1 \
  --set higress-core.controller.replicas=1 \
  --set higress-core.gateway.hostNetwork=true

# remove
#helm uninstall higress -n higress-system

# helm install higress . -n higress --create-namespace

# helm uninstall higress -n higress


#cat > higress-console.yaml <<EOF
#apiVersion: networking.k8s.io/v1
#kind: Ingress
#metadata:
#  name: higress-console
#  namespace: higress
#spec:
#  ingressClassName: higress
#  rules:
#    - host: higress.k8s.local
#      http:
#        paths:
#          - path: /
#            pathType: Prefix
#            backend:
#              service:
#                name: higress-console
#                port:
#                  number: 8080
#EOF
#kubectl apply -f higress-console.yaml

# 安装 istio-base higress基于isitio（可选）
mkdir -p cd /home/kubernetes/istio
cd /home/kubernetes/istio

helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo update

helm install istio-base istio/base \
  -n istio-system \
  --create-namespace \
  --set defaultRevision=default

# 更新
helm upgrade higress higress.io/higress \
  -n higress-system \
  --set global.enableIstioAPI=true \
  --reuse-values

# Gateway API CRD（可选）
# 集群里需要提前安装好 Gateway API 的 CRD：https://github.com/kubernetes-sigs/gateway-api/releases

# https://github.com/kubernetes-sigs/gateway-api/releases

mkdir -p /home/kubernetes/gateway-api
cd /home/kubernetes/gateway-api

wget https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.2.0-rc1/experimental-install.yaml
kubectl apply -f experimental-install.yaml

# 更新参数
helm upgrade higress higress.io/higress \
  -n higress-system \
  --reuse-values \
  --set global.enableGatewayAPI=true


# 测试gateway-api:
cd /home/kubernetes/higress
mkdir test
cd test

# test echo
cat > test-echo.yml <<EOF
kind: Pod
apiVersion: v1
metadata:
  name: foo-app
  labels:
    app: foo
spec:
  containers:
  - name: foo-app
    image: higress-registry.cn-hangzhou.cr.aliyuncs.com/higress/http-echo:0.2.4-alpine
    args:
    - "-text=foo"
---
kind: Service
apiVersion: v1
metadata:
  name: foo-service
spec:
  selector:
    app: foo
  ports:
  # Default port used by the image
  - port: 5678
EOF

# ingress 配置
cat > test-gateway.yml <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: foo
spec:
  ingressClassName: higress
  rules:
  - host: foo.bar.com
    http:
      paths:
      - pathType: Prefix
        path: "/foo"
        backend:
          service:
            name: foo-service
            port:
              number: 5678
EOF

# 测试连通

curl http://GatewayIP:PROT/foo -H 'host: foo.bar.com'

# https://github.com/alibaba/higress/blob/main/samples/gateway-api/demo.yaml
cat > demo.yaml <<EOF
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: higress-gateway
spec:
  controllerName: "higress.io/gateway-controller"
---
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: higress-gateway
  namespace: higress-system
spec:
  gatewayClassName: higress-gateway
  listeners:
  - name: default
    hostname: "*.gateway-api.com"
    port: 80
    protocol: HTTP
    allowedRoutes:
      namespaces:
        from: All
---
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: http
  namespace: default
spec:
  parentRefs:
  - name: higress-gateway
    namespace: higress-system
  hostnames: ["www.gateway-api.com"]
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /
    filters:
    - type: RequestHeaderModifier
      requestHeaderModifier:
        add:
        - name: my-added-header
          value: added-value-higress
    backendRefs:
    - name: foo-service
      port: 5678
  - matches:
    - path:
        type: PathPrefix
        value: /by-nacos
    backendRefs:
    - name: service-provider.DEFAULT-GROUP.public.nacos
      group: networking.higress.io
EOF

kubectl apply -f demo.yaml
