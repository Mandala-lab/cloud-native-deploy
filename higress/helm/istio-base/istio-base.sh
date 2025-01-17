#!/usr/bin/env bash
# 启用 POSIX 模式并设置严格的错误处理机制
set -o posix errexit -o pipefail

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
  --reuse-values \
  --set global.enableIstioAPI=true
