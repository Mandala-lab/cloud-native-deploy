#!/bin/bash

set -x

helm repo add harbor https://helm.goharbor.io
helm repo list
# 列出最新版本的包
helm search repo harbor -l |  grep harbor/harbor  | head  -4
# 定义版本
export VERSION="1.14.0"

# 拉取到本地
helm pull harbor/harbor $VERSION
ls harbor-$VERSION.tgz

# 解压
tar zxvf harbor-$VERSION.tgz

# 进入到harbor目录
cd harbor || exit
ll

# externalURL修改为对应的Addr
externalURL: 192.168.2.160:30785

helm install harbor ./ --dry-run | grep externalURL

kubectl create namespace harbor
helm install  harbor . -n harbor
#watch kubectl get po,svc -n harbor -owide
kubectl get po,svc -n harbor -owide

set +x
