#!/bin/bash

set -x

helm repo add harbor https://helm.goharbor.io
helm repo list

export NODE_IP="192.168.2.152"
export NODE_PORT="30003"

helm upgrade --install harbor harbor/harbor --namespace harbor --create-namespace \
  --set expose.type=nodePort \
  --set expose.tls.auto.commonName=$NODE_IP \
  --set externalURL="https://$NODE_IP:$NODE_PORT"

# 信任 Harbor 服务器证书：如果遇到证书验证问题，需要将 Harbor 服务器的证书添加到 Docker 客户端的信任列表中。
# 首先，获取 Harbor 服务器的证书文件，然后将其添加到 Docker 客户端的信任列表中。

# 获取证书
openssl s_client -showcerts -connect $NODE_IP:$NODE_PORT </dev/null 2>/dev/null | openssl x509 -outform PEM > harbor-cert.pem

# 将证书添加到 Docker 客户端的信任列表
mkdir -p /etc/docker/certs.d/$NODE_IP:$NODE_PORT
cp harbor-cert.pem /etc/docker/certs.d/$NODE_IP:$NODE_PORT/ca.crt

# 复制ca.crt到docker客户端所在机器
scp ca.crt root@$NODE_IP:/etc/docker/certs.d/$NODE_IP:$NODE_PORT/

# 尝试登录
docker login -u admin -p Harbor12345 https://$NODE_IP:$NODE_PORT

# 如果是自签名的证书, 必须在全部节点安装证书!
# 如果是自签名的证书, 必须在全部节点安装证书!
# 如果是自签名的证书, 必须在全部节点安装证书!
export CONTAINERD_CONFIG_FILE_PATH="/etc/containerd/config.toml"
sed -i '/\[plugins\."io\.containerd\.grpc\.v1\.cri"\.registry\]/!b;n;s/config_path = .*/config_path = "\/etc\/containerd\/certs.d"/' /etc/containerd/config.toml
cat -n /etc/containerd/config.toml | grep -A 1 "\[plugins\.\"io\.containerd\.grpc\.v1\.cri\"\.registry\]"

set +x
