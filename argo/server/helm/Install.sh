#!/usr/bin/env bash
# 启用 POSIX 模式并设置严格的错误处理机制
set -o posix errexit -o pipefail

# https://github.com/argoproj/argo-helm/tree/main

mkdir -pv /home/kubernetes/argocd
cd /home/kubernetes/argocd

helm repo add argo https://argoproj.github.io/argo-helm
helm upgrade \
--install argo \
argo-cd-6.7.18.tgz \
-f values.yaml \
-n cd \
--create-namespace

cat > values.yaml <<EOF
redis-ha:
  enabled: true

controller:
  replicas: 1

server:
  autoscaling:
    enabled: true
    minReplicas: 2

repoServer:
  autoscaling:
    enabled: true
    minReplicas: 2

applicationSet:
  replicas: 2

server:
  replicas: 2
  ingress:
    enabled: true
    ingressClassName: nginx
    annotations:
      nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
      nginx.ingress.kubernetes.io/backend-protocol: "HTTP"
#    extraTls:
#      - hosts:
#        - argocd.example.com
#        # Based on the ingress controller used secret might be optional
#        secretName: wildcard-tls
EOF
