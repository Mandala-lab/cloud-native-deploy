#!/usr/bin/env bash
# 启用 POSIX 模式并设置严格的错误处理机制
set -o posix errexit -o pipefail

mkdir -p /home/kubernetes/istio
cd /home/kubernetes/istio

kubectl create namespace istio-ingress
helm install istio-ingress istio/gateway -n istio-ingress --wait

# remove
# helm uninstall istio-ingress -n istio-ingress
