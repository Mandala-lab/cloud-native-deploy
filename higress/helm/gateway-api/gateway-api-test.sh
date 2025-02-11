#!/usr/bin/env bash
# 启用 POSIX 模式并设置严格的错误处理机制
set -o posix errexit -o pipefail

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

