#!/usr/bin/env bash
# 启用 POSIX 模式并设置严格的错误处理机制
set -o posix errexit -o pipefail

# https://github.com/kubernetes-sigs/gateway-api/releases

mkdir -p /home/kubernetes/gateway-api
cd /home/kubernetes/gateway-api

#wget https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.2.1/experimental-install.yaml
#kubectl apply -f experimental-install.yaml

wget https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.2.0/config/crd/standard/gateway.networking.k8s.io_gatewayclasses.yaml
wget https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.2.0/config/crd/standard/gateway.networking.k8s.io_gateways.yaml
wget https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.2.0/config/crd/standard/gateway.networking.k8s.io_httproutes.yaml
wget https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.2.0/config/crd/standard/gateway.networking.k8s.io_referencegrants.yaml
wget https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.2.0/config/crd/standard/gateway.networking.k8s.io_grpcroutes.yaml
wget https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.2.0/config/crd/experimental/gateway.networking.k8s.io_tlsroutes.yaml

kubectl apply -f gateway.networking.k8s.io_gatewayclasses.yaml
kubectl apply -f gateway.networking.k8s.io_gateways.yaml
kubectl apply -f gateway.networking.k8s.io_httproutes.yaml
kubectl apply -f gateway.networking.k8s.io_referencegrants.yaml
kubectl apply -f gateway.networking.k8s.io_grpcroutes.yaml
kubectl apply -f gateway.networking.k8s.io_tlsroutes.yaml
