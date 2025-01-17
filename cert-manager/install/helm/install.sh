#!/usr/bin/env bash
# 启用 POSIX 模式并设置严格的错误处理机制
set -o posix errexit -o pipefail

mkdir -p /home/kubernetes/cert-manager
cd /home/kubernetes/cert-manager

helm repo add jetstack https://charts.jetstack.io
helm repo update

# 生成 values.yaml

helm show values jetstack/cert-manager > values.yaml

#修改 values.yaml
cat > cert-manager-values.yaml <<EOF
installCRDs: true
prometheus:
  enabled: false
webhook:
  timeoutSeconds: 10
EOF

# 安装
helm install cert-manager jetstack/cert-manager \
  -n cert-manager \
  --create-namespace \
  -f cert-manager-values.yaml

# 等待完成
kubectl wait --for=condition=Ready pods --all -n cert-manager
