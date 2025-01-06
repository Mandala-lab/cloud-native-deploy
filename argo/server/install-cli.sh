#!/usr/bin/env bash
# 启用 POSIX 模式并设置严格的错误处理机制
set -o posix errexit -o pipefail

# argocd cli
# https://github.com/argoproj/argo-cd/releases
VERSION="v2.13.3"
OS="linux"
ARCH=amd64
wget https://github.com/argoproj/argo-cd/releases/download/$VERSION/argocd-$OS-$ARCH
chmod +x ./argocd-linux-amd64
mv ./argocd-linux-amd64 /usr/local/bin/argocd
