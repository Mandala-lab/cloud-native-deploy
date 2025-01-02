#!/usr/bin/env bash
# 启用 POSIX 模式并设置严格的错误处理机制
set -o posix errexit -o pipefail

helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
helm upgrade --install \
  kubernetes-dashboard \
  kubernetes-dashboard/kubernetes-dashboard \
  --create-namespace \
  --namespace kubernetes-dashboard

kubectl patch svc kubernetes-dashboard-kong-proxy -n kubernetes-dashboard -p '{"spec":{"type":"NodePort"}}'

# 创建用户
kubectl create serviceaccount dashboard-admin -n kubernetes-dashboard
# 用户授权
kubectl create clusterrolebinding dashboard-admin --clusterrole=cluster-admin --serviceaccount=kubernetes-dashboard:dashboard-admin
# 获取用户Token
kubectl create token dashboard-admin -n kubernetes-dashboard
# 使用输出的token登录Dashboard。

