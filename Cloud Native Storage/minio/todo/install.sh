#!/usr/bin/env bash
# 启用 POSIX 模式并设置严格的错误处理机制
set -o posix errexit -o pipefail

helm repo add minio-operator https://operator.min.io
helm search repo minio-operator

curl -sLo values.yaml https://raw.githubusercontent.com/minio/operator/master/helm/tenant/values.yaml
helm install \
--namespace minio-tenant \
--create-namespace \
--values values.yaml \
tenant-system minio-operator/tenant
