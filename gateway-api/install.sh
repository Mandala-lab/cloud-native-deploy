#!/usr/bin/env bash
# 启用 POSIX 模式并设置严格的错误处理机制
set -o posix errexit -o pipefail

# https://github.com/kubernetes-sigs/gateway-api/releases

mkdir -p /home/kubernetes/gateway-api
cd /home/kubernetes/gateway-api

wget https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.2.1/experimental-install.yaml
kubectl apply -f experimental-install.yaml
