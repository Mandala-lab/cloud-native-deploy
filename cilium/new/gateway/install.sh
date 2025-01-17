#!/usr/bin/env bash
# 启用 POSIX 模式并设置严格的错误处理机制
set -o posix errexit -o pipefail

cilium upgrade \
   --namespace kube-system \
   --reuse-values \
   --set egressGateway.enabled=true \
   --set bpf.masquerade=true \
   --set kubeProxyReplacement=true \
   --set ciliumEndpointSlice.enabled=false

kubectl rollout restart ds cilium -n kube-system
kubectl rollout restart deploy cilium-operator -n kube-system
