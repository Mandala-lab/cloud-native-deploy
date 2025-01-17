#!/usr/bin/env bash
# 启用 POSIX 模式并设置严格的错误处理机制
set -o posix errexit -o pipefail

# 安装: https://github.com/minio/operator/tree/v6.0.4/helm/operator
# 配置: https://min.io/docs/minio/kubernetes/upstream/operations/installation.html

mkdir -pv /home/kubernetes/minio
cd /home/kubernetes/minio

# 添加仓库
helm repo add minio https://operator.min.io/
helm search repo minio/operator
helm pull minio/operator

# 解压
tar -zxvf operator-*.tgz

# 按需修改, 不需要修改也可启动
# vi values.yaml

helm install \
  --namespace minio-operator \
  --create-namespace \
  minio-operator ./operator \
  -f ./operator/values.yaml
