#!/usr/bin/env bash
# 启用 POSIX 模式并设置严格的错误处理机制
set -o posix errexit -o pipefail

# 配置国内代理源
# https://blog.csdn.net/lwlfox/article/details/104880227
helm repo remove stable

helm repo add stable http://mirror.azure.cn/kubernetes/charts/

