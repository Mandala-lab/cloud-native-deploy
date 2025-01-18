#!/usr/bin/env bash
# 启用 POSIX 模式并设置严格的错误处理机制
set -o posix errexit -o pipefail

# 状态: 未完成, grafana无法连接loki

helm repo add grafana https://grafana.github.io/helm-charts
helm pull grafana/loki-stack
tar -zxvf loki-stack-*.tgz

# # loki-stack的配置
cat > loki-stack-values.yaml <<EOF
loki:
  enabled: true
  isDefault: true
  persistence:
    enabled: true
    accessModes:
      - ReadWriteOnce
    size: 7Gi
  url: http://{{(include "loki.serviceName" .)}}:{{ .Values.loki.service.port }}
  readinessProbe:
    httpGet:
      path: /ready
      port: http-metrics
    initialDelaySeconds: 45
  livenessProbe:
    httpGet:
      path: /ready
      port: http-metrics
    initialDelaySeconds: 45
  datasource:
    jsonData: "{}"
    uid: ""
promtail:
  enabled: true
  config:
    logLevel: info
    serverPort: 3101
    clients:
      - url: http://{{ .Release.Name }}:3100/loki/api/v1/push
grafana:
  enabled: true
EOF

# grafana的配置
cat > loki-stack-grafana-values.yaml <<EOF
grafana:
  service:
    enabled: true
    type: LoadBalancer
    port: 80
    targetPort: 3000
  # Administrator credentials when not using an existing secret (see below)
  adminUser: admin
  adminPassword: msdnmm,.
EOF

helm uninstall loki -n loki-stack || true
helm install loki ./loki-stack/ -n loki-stack \
  --create-namespace \
  -f loki-stack-values.yaml \
  -f loki-stack-grafana-values.yaml

# 获取Grafana的WebUI密码:
# kubectl get secret --namespace loki-stack loki-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
