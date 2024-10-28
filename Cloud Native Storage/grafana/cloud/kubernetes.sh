#!/usr/bin/env bash
# 启用 POSIX 模式并设置严格的错误处理机制
set -o posix errexit -o pipefail

mkdir -pv /home/kubernetes/grafana
cd /home/kubernetes/grafana

helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

cat > grafana-kubernetes.yaml <<EOF

EOF

# 卸载
# helm uninstall grafana-k8s-monitoring -n observability
helm upgrade --install grafana-k8s-monitoring grafana/k8s-monitoring \
--atomic \
--timeout 300s \
--namespace "observability" \
--create-namespace \
-f grafana-kubernetes.yaml

# 配置 Application Instrumentation
# 部署 Helm Chart 后，您需要配置应用程序插桩，以使用以下地址之一将遥测数据发送到 Grafana Alloy：
# OTLP/gRPC 端点： http://grafana-k8s-monitoring-alloy.observability.svc.cluster.local:4317
# OTLP/HTTP 端点： http://grafana-k8s-monitoring-alloy.observability.svc.cluster.local:4318
