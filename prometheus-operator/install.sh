#!/usr/bin/env bash
# 启用 POSIX 模式并设置严格的错误处理机制
set -o posix errexit -o pipefail

# https://github.com/prometheus-operator/prometheus-operator

git clone --depth 1 https://github.com/prometheus-operator/prometheus-operator.git
cd prometheus-operator || exit

cp bundle.yaml bundle.yaml.backup

# 使用 sed 命令全局替换 namespace: default 为 namespace: monitoring
sed -i '' 's/namespace: default/namespace: monitoring/g' bundle.yaml

kubectl create -f bundle.yaml
