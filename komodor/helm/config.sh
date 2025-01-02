#!/usr/bin/env bash
# 启用 POSIX 模式并设置严格的错误处理机制
set -o posix errexit -o pipefail

mkdir -p /home/kubernetes/komdor
cd /home/kubernetes/komdor

helm repo add komodorio https://helm-charts.komodor.io
helm repo update

helm install komodor-agent komodorio/komodor-agent \
  --set apiKey=2505a1b5-ae67-4bbb-a79a-b7d0ab1ac305 \
  --set clusterName=cloud \
  --timeout=90s \
  --create-namespace \
  -n komdor

#open https://app.komodor.com/main/services

# remove
helm uninstall komodor-agent
