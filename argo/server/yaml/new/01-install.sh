#!/usr/bin/env bash
# 启用 POSIX 模式并设置严格的错误处理机制
set -o posix errexit -o pipefail

mkdir -p /home/kubernetes/argocd
cd /home/kubernetes/argocd

kubectl create namespace argocd

# 入门: https://argo-cd.readthedocs.io/en/stable/getting_started/
# argo crd清单: https://github.com/argoproj/argo-cd/tree/master/manifests
#kubectl apply -k "https://github.com/argoproj/argo-cd/manifests/crds\?ref\=stable"
#kubectl apply -k "https://mirror.ghproxy.com/https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml"
#kubectl apply -k "https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml"

# argo cd 非高可用清单: https://github.com/argoproj/argo-cd/tree/master/manifests
wget https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl apply -f install.yaml -n argocd

# argo cd 高可用:
#kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v2.12.4/manifests/ha/install.yaml

# LoadBalancer
#kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

# 修改为NodePort
kubectl patch svc argocd-server -n argocd -p '{"spec":{"type":"NodePort"}}'

# Ingress: https://argo-cd.readthedocs.io/en/stable/operator-manual/ingress/
