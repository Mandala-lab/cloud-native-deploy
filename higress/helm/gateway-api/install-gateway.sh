#!/usr/bin/env bash
# 启用 POSIX 模式并设置严格的错误处理机制
set -o posix errexit -o pipefail

# Gateway API CRD（可选）
# 集群里需要提前安装好 Gateway API 的 CRD：https://github.com/kubernetes-sigs/gateway-api/releases

# https://github.com/kubernetes-sigs/gateway-api/releases

mkdir -p /home/kubernetes/gateway-api
cd /home/kubernetes/gateway-api

wget https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.2.1/experimental-install.yaml
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
