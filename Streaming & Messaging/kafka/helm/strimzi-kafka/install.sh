#!/usr/bin/env bash
# 启用 POSIX 模式并设置严格的错误处理机制
set -o posix errexit -o pipefail
# https://docs.kafka-ui.provectus.io/configuration/helm-charts/quick-start

helm repo add kafka-ui https://provectus.github.io/kafka-ui-charts
helm repo update
helm pull kafka-ui/kafka-ui
cd kafka-ui || exit

# 将kafka-cluster-broker-endpoints:9092替换
cat > helm-kafuka-ui-values.yml <<EOF
ApplicationConfig:
  kafka:
    clusters:
      - name: yaml
        bootstrapServers:  my-cluster-kafka-brokers.kafka.svc.cluster.local:9092
  auth:
    type: disabled
  management:
    health:
      ldap:
        enabled: false
EOF

helm install kafka-ui . -f helm-kafuka-ui-values.yml
