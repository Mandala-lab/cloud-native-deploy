#!/usr/bin/env bash
# 启用 POSIX 模式并设置严格的错误处理机制
set -o posix errexit -o pipefail

# 安装: https://github.com/minio/operator/tree/v6.0.4/helm/operator
# 配置: https://www.minio.org.cn/docs/minio/kubernetes/upstream/reference/operator-chart-values.html

helm search repo minio/tenant
helm pull minio/tenant
tar -zxvf tenant-*.tgz
cd tenant

# 修改values.yaml, 推荐修改pools.servers与pools.size
# vi values.yaml

helm install --namespace minio-tenant \
  --create-namespace tenant . \
  -f values.yaml

kubectl get po -n minio-tenant -owide
kubectl get svc -n minio-tenant
# NodePort
kubectl patch svc myminio-console -n minio-tenant -p '{"spec":{"type":"NodePort"}}'
# LoadBalancer
#kubectl patch svc myminio-console -n minio-tenant -p '{"spec":{"type":"LoadBalancer"}}'
