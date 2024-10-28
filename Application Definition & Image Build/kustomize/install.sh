#!/usr/bin/env bash
# 启用 POSIX 模式并设置严格的错误处理机制
set -o posix errexit -o pipefail

mkdir -pv /home/kubernetes/kustomize
cd /home/kubernetes/kustomize || exit

# https://github.com/kubernetes-sigs/kustomize/releases/
VERSION="v5.5.0"
OS="linux"
ARCH="amd64"
wget -O kustomize https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv5.5.0/kustomize_${VERSION}_${OS}_${ARCH}.tar.gz

chmod +x ./kustomize
cp ./kustomize /usr/local/bin/
