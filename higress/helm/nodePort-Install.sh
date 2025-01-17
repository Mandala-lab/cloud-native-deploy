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
    resources:
      limits:
        cpu: "500m"
        memory: 2048Mi
      requests:
        memory: 2048Mi
    replicas: 1
    hostNetwork: true
    service:
      type: NodePort
    httpPort: 80
    httpsPort: 443
    nodeSelector:
      kubernetes.io/hostname: node10
EOF

helm install higress higress.io/higress \
  -n higress-system \
  --create-namespace \
  --render-subchart-notes \
  --set higress-console.service.type=NodePort \
  -f values.yaml
