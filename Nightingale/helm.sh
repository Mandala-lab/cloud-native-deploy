#!/usr/bin/env bash
# 启用 POSIX 模式并设置严格的错误处理机制
set -o posix errexit -o pipefail

# https://github.com/flashcatcloud/n9e-helm
git clone --depth 1 https://github.com/flashcatcloud/n9e-helm.git

helm install nightingale ./n9e-helm -n n9e --create-namespace

# rm
# helm uninstall  nightingale -n n9e
