#!/usr/bin/env bash
# 启用 POSIX 模式并设置严格的错误处理机制
set -o posix errexit -o pipefail

mkdir -p /home/kubernetes/jaeger
cd /home/kubernetes/jaeger

# 安装operator
kubectl create ns observability
# https://github.com/jaegertracing/jaeger-operator/releases
VERSION="v1.62.0"
wget https://github.com/jaegertracing/jaeger-operator/releases/download/${VERSION}/jaeger-operator.yaml
kubectl apply -f jaeger-operator.yaml

# 通过operator crd创建jaeger实例
cat > jaeger.yml <<EOF
apiVersion: jaegertracing.io/v1
kind: Jaeger
metadata:
  name: jaeger
spec:
  strategy: production
  collector:
    maxReplicas: 1
    resources:
      limits:
        cpu: 200m
        memory: 256Mi
EOF

kubectl apply -f jaeger.yml -n observability

# 启用UI的NodePort类型的转发
#kubectl patch svc jaeger-query -n observability -p '{"spec":{"type":"NodePort"}}'
kubectl patch svc jaeger-query -n observability -p '{"spec":{"type":"LoadBalancer"}}'
