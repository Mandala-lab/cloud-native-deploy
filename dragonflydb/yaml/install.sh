#!/usr/bin/env bash
# 启用 POSIX 模式并设置严格的错误处理机制
set -o posix errexit -o pipefail

mkdir -p /home/kubernetes/dragonfly
cd /home/kubernetes/dragonfly || exit

# https://www.dragonflydb.io/docs/getting-started/kubernetes-operator

# Install the CRD and Operator
wget https://raw.githubusercontent.com/dragonflydb/dragonfly-operator/main/manifests/dragonfly-operator.yaml
kubectl apply -f dragonfly-operator.yaml

wget https://raw.githubusercontent.com/dragonflydb/dragonfly-operator/main/config/samples/v1alpha1_dragonfly.yaml
kubectl create ns dragonfly
kubectl apply -f v1alpha1_dragonfly.yaml -n dragonfly

kubectl get po,svc -n dragonfly -owide
#kubectl patch svc dragonfly-sample -n dragonfly -p '{"spec":{"type":"NodePort"}}'
kubectl patch svc dragonfly-sample -n dragonfly -p '{"spec":{"type":"LoadBalancer"}}'
kubectl get po,svc -n dragonfly -owide
