#!/usr/bin/env bash
# 启用 POSIX 模式并设置严格的错误处理机制
set -o posix errexit -o pipefail

export DOMAIN="gateway.lookeke.cn"

cat > ${DOMAIN}.yaml<<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: whoami
  labels:
    app: containous
    name: whoami
spec:
  replicas: 2
  selector:
    matchLabels:
      app: containous
      task: whoami
  template:
    metadata:
      labels:
        app: containous
        task: whoami
    spec:
      containers:
        - name: containouswhoami
          #image: ccr.ccs.tencentyun.com/lisa/lib:nginx-http3
          #image: nginx:stable-alpine3.19-otel
          image: tinychen777/nginx-quic:latest
          resources:
          ports:
            - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: whoami
spec:
  ports:
    - name: http
      port: 80
  selector:
    app: containous
    task: whoami
  type: ClusterIP
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ${DOMAIN}
spec:
  ingressClassName: higress
  tls:
    - hosts:
        - "${DOMAIN}"
      secretName: ${DOMAIN}-letsencrypt-tls
  rules:
    - host: ${DOMAIN}
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: whoami
                port:
                  number: 80
#apiVersion: networking.k8s.io/v1
#kind: Ingress
#metadata:
#  name: whoami-ingress
#  annotations:
#    kubernetes.io/ingress.class: higress
#    nginx.ingress.kubernetes.io/rewrite-target: /
#spec:
#  tls:
#    - hosts:
#        - "${DOMAIN}"
#      secretName: wildcard-letsencrypt-tls
#  rules:
#    - host: ${DOMAIN}
#      http:
#        paths:
#          - path: /
#            pathType: Prefix
#            backend:
#              service:
#                name: whoami
#                port:
#                  number: 80
EOF

kubectl apply -f ${DOMAIN}.yaml
