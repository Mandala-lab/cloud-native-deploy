#!/usr/bin/env bash
# 启用 POSIX 模式并设置严格的错误处理机制
set -o posix errexit -o pipefail


cat > test-foo.yaml <<EOF
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

cat > test-cilium-ingress.yaml <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: foo
spec:
  ingressClassName: cilium
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

k apply -f test-foo.yaml
k apply -f test-cilium-ingress.yaml

k get ingress
-H 'host: foo.bar.com'
