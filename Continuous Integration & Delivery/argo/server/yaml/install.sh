#!/bin/bash

set -x
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# https://github.com/argoproj/argo-cd/releases
VERSION="v2.10.0"
OS="linux"
ARCH="amd64"
wget https://github.com/argoproj/argo-cd/releases/download/${VERSION}/argocd-${OS}-${ARCH}
chmod +x ./argocd-${OS}-${ARCH}
mv ./argocd-${OS}-${ARCH} /usr/local/bin/argocd

# 使用 CLI 登录
argocd admin initial-password -n argocd
# hv0uqcQpbwGhsiwN
PASSWORLD="hv0uqcQpbwGhsiwN"

# 登录, port为argocd-server的80端口
# 默认的账号是admin
argocd login 192.168.2.100:30618

# 更改密码
# 第一次要求输入原密码
# 第二次和第三次是重新新的密码
argocd account update-password

set +x
