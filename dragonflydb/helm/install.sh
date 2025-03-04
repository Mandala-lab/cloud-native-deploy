#!/usr/bin/env bash
# 启用 POSIX 模式并设置严格的错误处理机制
set -o posix errexit -o pipefail

# https://github.com/dragonflydb/dragonfly/tree/main/contrib/charts/dragonfly

# VERSION=v1.26.1
#helm upgrade --install dragonfly oci://ghcr.io/dragonflydb/dragonfly/helm/dragonfly--version $VERSION

VERSION=v1.27.1
helm pull oci://ghcr.io/dragonflydb/dragonfly/helm/dragonfly --version $VERSION

tar -zxvf dragonfly-$VERSION.tgz

kubectl create ns dragonfly || true
# 设置密码 secret
# 如果不需要密码, 把dragonfly-values.yaml的passwordFromSecret下的enable: true改成enable: false
# passwordFromSecret:
#  enable: false
DFLY_PASSOWRD=msdnmm
kubectl create secret generic dragonfly-password-secret \
  --from-literal=password=$DFLY_PASSOWRD -n dragonfly

cat > dragonfly-values.yaml <<EOF
replicaCount: 1

image:
  # -- Container Image Registry to pull the image from
  repository: docker.dragonflydb.io/dragonflydb/dragonfly
service:
  # -- Service type to provision. Can be NodePort, ClusterIP or LoadBalancer
  type: NodePort
  port: 6379
serviceMonitor:
  # -- If true, a ServiceMonitor CRD is created for a prometheus operator
  enabled: false
  # -- namespace in which to deploy the ServiceMonitor CR. defaults to the application namespace
  namespace: ""
  # -- additional labels to apply to the metrics
  labels: {}
  # -- additional annotations to apply to the metrics
  annotations: {}
  # -- scrape interval
  interval: 10s
  # -- scrape timeout
  scrapeTimeout: 10s
resources:
  # -- The requested resources for the containers
  requests: {}
  #   cpu: 100m
  #   memory: 128Mi
  # -- The resource limits for the containers
  limits: {}
  #   cpu: 100m
  #   memory: 128Mi

# If enabled will set DFLY_PASSOWRD environment variable with the specified existing secret value
# Note that if enabled and the secret does not exist pods will not start
passwordFromSecret:
  # 如果不需要密码, 把enable: true改成enable: false
  enable: true
  existingSecret:
    name: "dragonfly-password-secret"
    key: "password"

tls:
  # -- enable TLS
  enabled: false
  # -- use cert-manager to automatically create the certificate
  createCerts: false
  # -- duration or ttl of the validity of the created certificate
  duration: 87600h0m0s
  issuer:
    # -- cert-manager issuer kind. Usually Issuer or ClusterIssuer
    kind: ClusterIssuer
    # -- name of the referenced issuer
    name: selfsigned
  # -- use TLS certificates from existing secret
  existing_secret: ""
  # -- TLS certificate
  cert: ""
  # cert: |
  #   -----BEGIN CERTIFICATE-----
  #   MIIDazCCAlOgAwIBAgIUfV3ygaaVW3+yzK5Dq6Aw6TsZ494wDQYJKoZIhvcNAQEL
  #   ...
  #   BQAwRTELMAkGA1UEBhMCQVUxEzARBgNVBAgMClNvbWUtU3RhdGUxITAfBgNVBAoM
  #   zJAL4hNw4Tr6E52fqdmX
  #   -----END CERTIFICATE-----
  # -- TLS private key
  key: ""
  # key: |
  #   -----BEGIN RSA PRIVATE KEY-----
  #   MIIEpAIBAAKCAQEAxeD5iQGQpCUlksFvjzzAxPTw6DMJd3MpifV+HoBY4LiTyDer
  #   ...
  #   HLunol88AeTOcKfD6hBYGvcRfu5NV29jJxZCOBfbFQXjnNlnrhRCag==
  #   -----END RSA PRIVATE KEY-----

storage:
  # -- If /data should persist. This will provision a StatefulSet instead.
  enabled: false
  # -- Global StorageClass for Persistent Volume(s)
  storageClassName: ""
  # -- Volume size to request for the PVC
  requests: 128Mi
EOF

# 尝试运行, 看看定义的values有没有问题
helm install dragonfly ./dragonfly \
  -f dragonfly-values.yaml \
  --version $VERSION \
  --dry-run

# 正式安装
helm uninstall dragonfly -n dragonfly || true
helm install dragonfly ./dragonfly \
  -f dragonfly-values.yaml \
  --version $VERSION \
  --create-namespace \
  -n dragonfly
