#!/usr/bin/env bash
# 启用 POSIX 模式并设置严格的错误处理机制
set -o posix errexit -o pipefail

# 入门: https://opentelemetry.io/docs/kubernetes/helm/operator/
# https://github.com/open-telemetry/opentelemetry-operator/blob/main/README.md

mkdir -pv /home/kubernetes/opentelemetry
cd /home/kubernetes/opentelemetry || exit

# opentelemetry-operator
helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts
helm repo update

helm pull open-telemetry/opentelemetry-operator --untar
cd opentelemetry-operator/

# 仓库: git clone --depth 1 https://www.ghproxy.cn/https://github.com/open-telemetry/opentelemetry-operator-helm-charts.git
# 配置文件参考: https://github.com/open-telemetry/opentelemetry-helm-charts/blob/main/charts/opentelemetry-operator/values.yaml

# helm uninstall opentelemetry-operator
# kubectl delete crd opentelemetrycollectors.opentelemetry.io
# kubectl delete crd opampbridges.opentelemetry.io
# kubectl delete crd instrumentations.opentelemetry.io
helm upgrade --install my-opentelemetry-operator . \
  --create-namespace \
  -n opentelemetry-operator \
  --set "manager.collectorImage.repository=otel/opentelemetry-collector-k8s" \
  --set admissionWebhooks.certManager.enabled=false \
  --set admissionWebhooks.autoGenerateCert.enabled=true
