#!/bin/bash

set -x

# TODO 未完成

mkdir -pv /home/kubernetes/loki
cd /home/kubernetes/loki || exit

helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
cat > loki-values.yuml <<EOF
deploymentMode: SingleBinary
loki:
  commonConfig:
    replication_factor: 1
  storage:
    type: 'filesystem'
  schemaConfig:
    configs:
    - from: "2024-01-01"
      store: tsdb
      index:
        prefix: loki_index_
        period: 24h
      object_store: filesystem # we're storing on filesystem so there's no real persistence here.
      schema: v13
singleBinary:
  replicas: 1
  persistence:
    size: 1Gi
read:
  replicas: 0
backend:
  replicas: 0
write:
  replicas: 0
EOF

# 用于测试: https://github.com/grafana/loki/blob/main/cmd/loki/loki-local-config.yaml
wget https://github.com/grafana/loki/raw/main/cmd/loki/loki-local-config.yaml

helm search repo grafana/loki
helm pull grafana/loki --untar
cd loki || exit

# 卸载
# helm uninstall loki -n loki
helm upgrade --install loki . \
--namespace=loki \
--create-namespace \
-f values.yaml \
-f loki-values.yuml

set +x
