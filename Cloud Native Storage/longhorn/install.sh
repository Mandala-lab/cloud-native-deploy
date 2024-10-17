#!/usr/bin/env bash
# 启用 POSIX 模式并设置严格的错误处理机制
set -o posix errexit -o pipefail

mkdir -pv /home/kubernetes/longhorn
cd /home/kubernetes/longhorn

wget https://raw.githubusercontent.com/longhorn/longhorn/v1.6.0/deploy/longhorn.yaml
kubectl apply -f longhorn.yaml

kubectl patch svc longhorn-frontend -n longhorn-system -p '{"spec":{"type":"NodePort"}}'
