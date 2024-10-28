#!/usr/bin/env bash
# 启用 POSIX 模式并设置严格的错误处理机制
set -o posix errexit -o pipefail

# 安装argocd实例
export ns="argocd"
kubectl create ns $ns
kubectl create -f ./argocd-deploy.yaml -n $ns
# 如果需要再argocd-cm添加任何参数, 请编辑argocd.deploy.yaml的spec.extraConfig, 例如
# spec:
#   extraConfig:
#     accounts.admin: "apiKey, login"

# 获取密码
echo "将default-argocd替换成你的argocd的名称"
pwd=$(kubectl -n $ns get secret argocd-cluster -o jsonpath='{.data.admin\.password}' | base64 -d)
# bCGuMlvgYtd5UnRN9qZWhsDFI1PQ8B0H
