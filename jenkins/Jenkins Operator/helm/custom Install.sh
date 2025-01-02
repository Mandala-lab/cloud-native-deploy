#!/usr/bin/env bash
set -o errexit -o pipefail

# https://www.cuiliangblog.cn/detail/section/127410630
# https://mp.weixin.qq.com/s/rO5dJPZ913i3Vt85J5oQ9A

k create ns jenkins

helm repo add jenkins https://charts.jenkins.io
helm repo update

helm fetch jenkins/jenkins --untar

# 修改以下配置:
# 镜像: controller.image.tag
# 镜像: controller.image.tagLabel
# 硬件资源: resources.requests.cpu
# 硬件资源: resources.requests.memory
# 硬件资源: resources.limits.cpu
# 硬件资源: resources.limits.memory
# 对外开放类型: controller.serviceType: LoadBalancer/ClusterIP/NodePort/Ingress
# 存储类storageClass: persistence.storageClass
# 数据持久化空间的存储大小: persistence.size

export OS="linux"
export ARCH="amd64"
#export VERSION="jenkins/jenkins:2.419-alpine-jdk17"
export VERSION="ccr.ccs.tencentyun.com/rccc/jenkins:v2"
export IMAGE_NAME="jenkins"
docker run \
-d \
-u root \
--name ${IMAGE_NAME} \
--restart=always \
-p 8086:8080 \
-p 50000:50000 \
-v /data/jenkins/data:/var/jenkins_home \
-v /var/run/docker.sock:/var/run/docker.sock \
${VERSION}

# Kubectl
rm -rf kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/${OS}/${ARCH}/kubectl"
./kubectl version
docker cp ./kubectl ${IMAGE_NAME}:/bin/kubectl
sudo docker exec -it ${IMAGE_NAME} chmod +x /bin/kubectl
sudo docker exec -it ${IMAGE_NAME} /bin/kubectl version

# Go
export GO_VERSION="go1.22.2"
docker exec -it ${IMAGE_NAME} apk add bash
rm -rf go1.22.2.linux-amd64.tar.gz
docker exec -it ${IMAGE_NAME} wget https://golang.google.cn/dl/${GO_VERSION}.${OS}-${ARCH}.tar.gz
docker cp ${GO_VERSION}.${OS}-${ARCH}.tar.gz ${IMAGE_NAME}:/${GO_VERSION}.${OS}-${ARCH}.tar.gz
docker exec -it ${IMAGE_NAME} tar -C /usr/local -xzf /${GO_VERSION}.${OS}-${ARCH}.tar.gz
docker exec -it ${IMAGE_NAME} rm -rf /${GO_VERSION}.${OS}-${ARCH}.tar.gz
docker exec -it ${IMAGE_NAME} /bin/bash -c "echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc"
docker exec -it ${IMAGE_NAME} /bin/bash -c "source ~/.bashrc"
docker exec -it ${IMAGE_NAME} /bin/bash -c "go version"

# Node
docker exec -it ${IMAGE_NAME} apk add nodejs
docker exec -it ${IMAGE_NAME} apk add npm
docker exec -it ${IMAGE_NAME} npm install -g pnpm
docker exec -it ${IMAGE_NAME} pnpm -v

# Push Images in Harbor
docker commit ${IMAGE_NAME} 192.168.2.152:30003/jenkins/jenkins:v1
docker push 192.168.2.152:30003/jenkins/jenkins:v1

helm install jenkins -f templates/values2.yaml . -n jenkins
# 查看密码, 账号是admin
printf $(kubectl get secret --namespace jenkins jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode);echo

# 插件推荐
# Chinese
# Gitlab
# Git Parameter
# Extended Choice Parameter
# Docker

# Kubernetes
# Pipeline

# active choices
# kubernetes Continuous Deploy
# http request
# build user vars
# description setter
# Describe With Params
# Build Name and Description Setter
# Pipeline Stage View

# 如果是拉取的SSH类型的git仓库
# 则需要在Jenkins Pod容器添加对应的主机的仓库
git ls-remote -h -- ssh://git@192.168.2.158:2222/root/full-stack-engineering.git HEAD


