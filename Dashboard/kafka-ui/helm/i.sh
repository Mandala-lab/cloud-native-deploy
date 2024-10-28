#!/usr/bin/env bash
# 启用 POSIX 模式并设置严格的错误处理机制
set -o posix errexit -o pipefail

mkdir -p /home/kubernetes/kafka/ui
cd /home/kubernetes/kafka/ui

helm repo add kafka-ui https://provectus.github.io/kafka-ui-charts
helm pull kafka-ui/kafka-ui --untar
cd kafka-ui || exit

#
cat > kafka-ui-values.yml <<EOF
replicaCount: 1

yamlApplicationConfig:
  kafka:
    clusters:
      - name: kubernetes-strimzi-kafka
        bootstrapServers: my-cluster-kafka-brokers.kafka.svc.cluster.local:9092
  auth:
    type: disabled
  management:
    health:
      ldap:
        enabled: false
EOF

# 使用自定义的配置覆盖原有的配置文件
helm upgrade --install kafka-ui . \
-f values.yaml \
-f kafka-ui-values.yml \
--create-namespace \
-n kafka

# 卸载
# helm uninstall kafka-ui -n kafka
