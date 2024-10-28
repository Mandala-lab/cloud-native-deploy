#!/usr/bin/env bash
# 启用 POSIX 模式并设置严格的错误处理机制
set -o posix errexit -o pipefail

# https://openkruise.io/zh/rollouts/installation

# 首先，如果您还没有添加 openkruise Charts库，请执行以下命令。
helm repo add openkruise https://openkruise.github.io/charts/

# [可选]
helm repo update

helm search repo kruise-rollout

# 安装最新版本。
helm install kruise-rollout openkruise/kruise-rollout

# 国内镜像
#helm install kruise --set image.repository=openkruise-registry.cn-shanghai.cr.aliyuncs.com/openkruise/kruise-rollout

# 卸载
#helm uninstall kruise-rollout
