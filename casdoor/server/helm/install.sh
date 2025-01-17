#!/bin/bash
set -x

# https://casdoor.org/zh/docs/basic/try-with-helm/
# 镜像版本tag: https://hub.docker.com/r/casbin/casdoor-helm-charts/tags

mkdir -p /home/kubernetes/casdoor
cd /home/kubernetes/casdoor || exit

#helm pull oci://registry-1.docker.io/casbin/casdoor-helm-charts --version v1.702.0
helm pull oci://registry-1.docker.io/casbin/casdoor-helm-charts --version v1.799.0
tar -zxvf casdoor-helm-charts-*.tgz
kubectl create ns casdoor

# 配置文件: https://casdoor.org/zh/docs/basic/try-with-helm/
# 填写指南: https://casdoor.org/docs/basic/server-installation/#via-ini-file

# 修改values.yaml, 如果使用postgres:
#driverName = postgres
#dataSourceName = "user=root password=msdnmm host=localhost port=5432 sslmode=disable dbname=casdoor"
#dbName = casdoor

# 配置页面: https://casdoor.org/docs/basic/try-with-helm
# 外部数据库的配置: https://github.com/casdoor/casdoor-helm/blob/master/charts/casdoor/values.yaml
#wget -O config.yaml https://raw.githubusercontent.com/casdoor/casdoor-helm/master/charts/casdoor/values.yaml

user="postgres"
host="postgres-postgresql.postgres.svc.cluster.local"
password="postgres"
driver="postgres"
port=5432
databaseName="casdoor"
ssl_mode="disable"
#service_type="NodePort"
service_type="LoadBalancer"

# 安装
helm upgrade --install casdoor ./casdoor-helm-charts \
  -n casdoor \
  --set database.user=${user} \
  --set database.host=${host} \
  --set database.password=${password} \
  --set database.driver=${driver} \
  --set database.port=${port} \
  --set database.sslMode=${ssl_mode} \
  --set database.databaseName=${databaseName} \
  --set service.type=${service_type}

# 升级
# helm upgrade casdoor . \
# --reuse-values \
# -n casdoor \
# -f values.yaml

# NodePort
kubectl patch svc casdoor-casdoor-helm-charts -n casdoor -p '{"spec":{"type":"NodePort"}}'

set +x
