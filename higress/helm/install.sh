#!/usr/bin/env bash
# 启用 POSIX 模式并设置严格的错误处理机制
set -o posix errexit -o pipefail

mkdir -p /home/kubernetes/higress
cd /home/kubernetes/higress

helm repo add higress.io https://higress.io/helm-charts

# 没有LB的情况, 需要添加higress-core.gateway.hostNetwork，让 Higress 监听本机端口，再通过其他软/硬负载均衡器转发给固定机器 IP:

helm uninstall higress -n higress-system || true
cat > values.yaml <<EOF
higress-core:
  gateway:
    replicas: 1
    resources:
      limits:
        cpu: "2"
        memory: "2048Mi"
      requests:
        cpu: "2000m"  # 确保 requests.cpu <= limits.cpu
        memory: "1024Mi"

  controller:
    replicas: 1
    resources:
      limits:
        cpu: "1"
        memory: "1024Mi"
      requests:
        cpu: "1000m"  # 确保 requests.cpu <= limits.cpu
        memory: "512Mi"
EOF
helm install higress higress.io/higress \
  -n higress-system \
  --create-namespace \
  --render-subchart-notes \
  -f values.yaml
