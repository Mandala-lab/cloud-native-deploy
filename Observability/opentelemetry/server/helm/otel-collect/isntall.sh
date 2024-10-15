#!/usr/bin/env bash
# 启用 POSIX 模式并设置严格的错误处理机制
set -o posix errexit -o pipefail

# https://github.com/open-telemetry/opentelemetry-helm-charts/tree/main/charts/opentelemetry-collector
helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts

helm pull open-telemetry/opentelemetry-collector
tar -zxvf opentelemetry-collector-*.tgz
cd opentelemetry-collector
# 修改values.yaml
# vi values.yaml

# 其中 mode 值需要设置为 daemonset、deployment 或 statefulset 之一。

helm install opentelemetry-collector . \
  --set mode=daemonset \
  --set image.repository="otel/opentelemetry-collector-k8s" \
  --set command.name="otelcol-k8s" \
  -n opentelemetry-collector \
  --create-namespace
