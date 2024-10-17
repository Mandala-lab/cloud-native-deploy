#!/bin/bash

set -x

# 安装 cert-manager
mkdir -p /home/kubernetes/cert-manager
cd /home/kubernetes/cert-manager
wget https://github.com/cert-manager/cert-manager/releases/download/v1.16.1/cert-manager.yaml
kubectl apply -f cert-manager.yaml

set +x
