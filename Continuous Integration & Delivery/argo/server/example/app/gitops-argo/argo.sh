#!/usr/bin/bash

set -x
# login
# argocd login 192.168.2.155:30618 --insecure --grpc-web

# 定义该项目的命名空间
export PROJECT_NAME="default"

# 获取Git Repo URL
export BRANCH=""
export PROJECT_GIT_URL=""
if command -v git &> /dev/null
then
    echo "Git is installed."
    # 该项目所在的git仓库地址
    BRANCH=$(git rev-parse --abbrev-ref HEAD)
    PROJECT_GIT_URL="$(git config --get remote."${BRANCH}".url)"
    echo "${PROJECT_GIT_URL}"
else
    echo "Git is not installed."
    exit 1
fi

# 创建或使用命名空间
if kubectl get ns "${PROJECT_NAME}" &> /dev/null; then
    echo "Namespace ${PROJECT_NAME} already exists."
else
    echo "Namespace ${PROJECT_NAME} does not exist."
    # 创建该命名空间
    kubectl create ns $PROJECT_NAME
fi

# 创建argpcd app
argocd app create $PROJECT_NAME \
  --repo $PROJECT_REPO \
  --path . \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace $PROJECT_NAME

argocd app create test1 \
--repo http://192.168.2.158:7080/root/full-stack-engineering.git \
--path .argocd-backend.yml \
--dest-namespace test1 \
--dest-server https://kubernetes.default.svc

# 与argo同步一次
argocd app sync $PROJECT_NAME

# 自动同步, 默认每三分钟检查git repo
argocd app set $PROJECT_NAME --sync-policy automated

# 列出
argocd app list

# 获取
kubectl get all -n $PROJECT_NAME
echo 111

set +x
