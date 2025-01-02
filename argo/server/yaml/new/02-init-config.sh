#!/usr/bin/env bash
# 启用 POSIX 模式并设置严格的错误处理机制
set -o posix errexit -o pipefail

# 获取初始化的密码, 用户名是admin
argocd admin initial-password -n argocd
argocd login \
https://node6.example.com:32049 \
--username admin \
--password msdnmmi,. \
--insecure

# 注册集群以将应用程序部署到该集群(可选, 推荐)
# 将 ServiceAccount （argocd-manager） 安装到该 kubectl 上下文的 kube-system 命名空间中，
# 并将服务帐户绑定到管理员级别的 ClusterRole。Argo CD 使用此服务帐户令牌来执行其管理任务（即部署/监控）。
CLUSTER=$(kubectl config get-contexts -o name)
echo "$CLUSTER"
argocd cluster add "$CLUSTER"
