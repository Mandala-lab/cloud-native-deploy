#!/usr/bin/env bash
# 启用 POSIX 模式并设置严格的错误处理机制
set -o posix errexit -o pipefail

# test echo
cat > test-echo.yml <<EOF
kind: Pod
apiVersion: v1
metadata:
  name: foo-app
  labels:
    app: foo
spec:
  containers:
  - name: foo-app
    image: higress-registry.cn-hangzhou.cr.aliyuncs.com/higress/http-echo:0.2.4-alpine
    args:
    - "-text=foo"
---
kind: Service
apiVersion: v1
metadata:
  name: foo-service
spec:
  selector:
    app: foo
  ports:
  # Default port used by the image
  - port: 5678
EOF

# ingress 配置
cat > test-gateway.yml <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: foo
spec:
  ingressClassName: higress
  rules:
  - host: foo.bar.com
    http:
      paths:
      - pathType: Prefix
        path: "/foo"
        backend:
          service:
            name: foo-service
            port:
              number: 5678
EOF

kubectl apply -f test-echo.yml
kubectl apply -f test-gateway.yml

kubectl get ingress
kubectl get po -l app=foo
kubectl get service/foo-service
# 测试连通
# 将foo-service的IP临时写到/etc/hosts中
echo "<foo-service-IP> foo.bar.com" | tee -a /etc/hosts
cat /etc/hosts
# 然后测试
curl foo.bar.com/foo
