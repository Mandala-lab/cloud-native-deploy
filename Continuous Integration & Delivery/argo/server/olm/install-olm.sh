#!/usr/bin/env bash
# 启用 POSIX 模式并设置严格的错误处理机制
set -o posix errexit -o pipefail

# OLM
OLM_version=v0.28.0
#curl -sL https://github.com/operator-framework/operator-lifecycle-manager/releases/download/${OLM_version}/install.sh | bash -s ${OLM_version}
wget https://github.com/operator-framework/operator-lifecycle-manager/releases/download/${OLM_version}/install.sh
./install.sh ${OLM_version}

# 安装操作员, 此 Operator 将安装在 “operators” 命名空间中，并可从集群中的所有命名空间中使用
kubectl create -f https://operatorhub.io/install/argocd-operator.yaml
kubectl get csv -n operators
