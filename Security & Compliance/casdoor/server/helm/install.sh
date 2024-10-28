#!/bin/bash
set -x

# https://casdoor.org/zh/docs/basic/try-with-helm/
# 镜像版本tag: https://hub.docker.com/r/casbin/casdoor-helm-charts/tags
helm pull oci://registry-1.docker.io/casbin/casdoor-helm-charts --version v1.702.0
tar -zxvf casdoor-helm-charts-*.tgz
cd casdoor-helm-charts

# 配置文件: https://casdoor.org/zh/docs/basic/try-with-helm/
# 填写指南: https://casdoor.org/docs/basic/server-installation/#via-ini-file

# 修改values.yaml, 如果使用postgres:
#driverName = postgres
#dataSourceName = "user=root password=msdnmm host=localhost port=5432 sslmode=disable dbname=casdoor"
#dbName = casdoor

# 安装
helm upgrade --install casdoor . \
--create-namespace casdoor \
-n casdoor \
-f values.yaml

# 升级
# helm upgrade casdoor . \
# --reuse-values \
# -n casdoor \
# -f values.yaml

# NodePort
kubectl patch svc casdoor-casdoor-helm-charts -n casdoor -p '{"spec":{"type":"NodePort"}}'

set +x
