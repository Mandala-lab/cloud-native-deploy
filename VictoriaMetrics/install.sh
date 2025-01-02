#!/usr/bin/env bash
# 启用 POSIX 模式并设置严格的错误处理机制
set -o posix errexit -o pipefail

# https://docs.victoriametrics.com/
# https://github.com/VictoriaMetrics/helm-charts#list-of-charts
mkdir /home/kubernetes/victoria-metrics
cd /home/kubernetes/victoria-metrics

kubectl create ns victoriametrics
helm show values oci://ghcr.io/victoriametrics/helm-charts/victoria-metrics-agent > values.yaml
helm install victoriametrics oci://ghcr.io/victoriametrics/helm-charts/victoria-metrics-cluster -f values.yaml -n victoriametrics
kubectl get po -n victoriametrics
