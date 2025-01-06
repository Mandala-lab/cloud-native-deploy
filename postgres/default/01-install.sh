#!/usr/bin/env bash
# 启用 POSIX 模式并设置严格的错误处理机制
set -o posix errexit -o pipefail

mkdir -p /home/kubernetes/postgres
cd /home/kubernetes/postgres

#helm install postgres oci://registry-1.docker.io/bitnamicharts/postgresql

VERSION="16.3.5"
# https://artifacthub.io/packages/helm/bitnami/postgresql?modal=install
wget https://charts.bitnami.com/bitnami/postgresql-${VERSION}.tgz

#helm pull ingress-nginx/ingress-nginx --untar --untar-dir /path/to/directory

tar -zxvf postgresql-${VERSION}.tgz

# 参数配置:
# https://github.com/bitnami/containers/tree/main/bitnami/postgresql
# https://github.com/bitnami/charts/tree/main/bitnami/postgresql#parameters

helm install postgres ./postgresql \
  -n postgres \
  --create-namespace \
  --set global.postgresql.auth.username="postgres" \
  --set global.postgresql.auth.password="postgres" \
  --set global.postgresql.auth.database="postgres" \
  --set persistence.existingClaim=postgresql-pvc-claim \
  --set volumePermissions.enabled=true \
  --set global.postgresql.service.ports.postgresql="5432" \
  --set primary.service.type=NodePort
