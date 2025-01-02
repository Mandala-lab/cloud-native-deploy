#!/usr/bin/env bash
# 启用 POSIX 模式并设置严格的错误处理机制
set -o posix errexit -o pipefail

helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

kubectl create ns monitoring

helm search repo grafana/grafana

helm install grafana grafana/grafana \
--namespace monitoring \
--create-namespace


kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo

kubectl patch svc/grafana -n monitoring -p '{"spec":{"type":"NodePort"}}'

# http://simple-prod-collector.observability.svc.cluster.local:14268/api/traces
