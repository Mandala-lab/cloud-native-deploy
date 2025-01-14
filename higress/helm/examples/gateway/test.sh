#!/usr/bin/env bash
# 启用 POSIX 模式并设置严格的错误处理机制
set -o posix errexit -o pipefail

# 需要先安装gateway api
# kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.2.1/experimental-install.yaml
# 这种模式下，需要更新 Higress 的部署参数：
# helm upgrade higress -n higress-system --set global.enableGatewayAPI=true higress.io/higress --reuse-values

# 第一次需要应用. 后续不需要
kubectl apply -f 00-gateway-class.yaml
kubectl apply -f 01-gateway.yaml

# 测试的应用
kubectl apply -f 02-test-demo.yaml
# 测试Gateway功能
kubectl apply -f 03-http-route.yaml

# 访问, gateway.apikv.com 是你的网关域名, 需要加 /foo 来访问测试的Pod的路径才回有输出
curl http://gateway.apikv.com/foo -H 'host: foo.bar.com'
