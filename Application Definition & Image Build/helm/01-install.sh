#!/usr/bin/env bash
# 启用 POSIX 模式并设置严格的错误处理机制
set -o posix errexit -o pipefail

#https://blog.csdn.net/lwlfox/article/details/104880227

mkdir -pv /home/kubernetes/helm
cd /home/kubernetes/helm

wget https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get-helm-3
./get-helm-3

# 自动补全
cat >> ~/.bashrc <<EOF
source <(helm completion bash)
EOF

source ~/.bashrc
