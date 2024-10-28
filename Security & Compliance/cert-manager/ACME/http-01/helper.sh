#!/usr/bin/env bash
# 启用 POSIX 模式并设置严格的错误处理机制
set -o posix errexit -o pipefail

# 获取集群级别证书的颁发者
kubectl get clusterissuer

# 查看
kubectl describe clusterissuer <pod>

# 单个命名空间证书
kubectl get issuer

# 查询证书
k get certificate -A

# 证书请求列表
k get certificaterequest -A

# 查看ingress
k get ingress -A

# ingress是否分配到了TLS
k describe ingress <pod>

# 查询失败的原因
kubectl get challenges -A
