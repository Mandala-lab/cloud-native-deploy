#!/usr/bin/env bash
# 启用 POSIX 模式并设置严格的错误处理机制
set -o posix errexit -o pipefail

mkdir -p /home/kubernetes/consul
cd /home/kubernetes/consul

helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update
helm search repo hashicorp/consul

helm pull hashicorp/consul
tar -zxvf consul-*.tgz
cd consul/

helm install consul . \
  --create-namespace \
  -f values.yaml \
  --namespace consul
