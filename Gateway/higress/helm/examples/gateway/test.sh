#!/usr/bin/env bash
# 启用 POSIX 模式并设置严格的错误处理机制
set -o posix errexit -o pipefail

cat > gatewayclass.yaml <<EOF
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: higress-gateway
spec:
  controllerName: "higress.io/gateway-controller"
EOF
kubectl apply -f gatewayclass.yaml


cat > gateway.yaml <<EOF
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: higress-gateway
  namespace: higress-system
spec:
  gatewayClassName: higress-gateway
  listeners:
  - name: default-tcp
    protocol: TCP
    port: 9000
    allowedRoutes:
      namespaces:
        from: All
      kinds:
      - kind: TCPRoute
EOF
kubectl apply -f gateway.yaml

cat > tcproute.yaml <<EOF
apiVersion: gateway.networking.k8s.io/v1alpha2
kind: TCPRoute
metadata:
  name: tcp-echo
  namespace: default
spec:
  parentRefs:
  - name: higress-gateway
    namespace: higress-system
    port: 9000
  rules:
  - backendRefs:
    - name: tcp-echo
      port: 9000
EOF
kubectl apply -f tcproute.yaml
