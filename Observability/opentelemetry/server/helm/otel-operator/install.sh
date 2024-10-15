#!/usr/bin/env bash
# 启用 POSIX 模式并设置严格的错误处理机制
set -o posix errexit -o pipefail

# 安装: https://opentelemetry.io/docs/kubernetes/helm/operator/
helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts
helm pull open-telemetry/opentelemetry-operator

tar -zxvf opentelemetry-operator-*.tgz
cd opentelemetry-operator

helm install opentelemetry-operator . \
  --set "manager.collectorImage.repository=otel/opentelemetry-collector-k8s" \
  --set admissionWebhooks.certManager.enabled=false \
  --set admissionWebhooks.autoGenerateCert.enabled=true \
  -n opentelemetry-operator \
  --create-namespace

# https://opentelemetry.io/docs/kubernetes/operator/

