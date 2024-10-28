#!/usr/bin/env bash
# 启用 POSIX 模式并设置严格的错误处理机制
set -o posix errexit -o pipefail

mkdir -pv /home/kubernetes/loki
cd /home/kubernetes/loki || exit

helm repo add grafana https://grafana.github.io/helm-charts
helm search repo grafana/loki
helm pull grafana/loki --untar

# s3 s3://access_key:secret_access_key@custom_endpoint/bucket_name
export MINIO_URL="s3://2BALLOaZiWE8AYhRnIbA:TsNivDuv2NkOFxs9sUWFfRfXZIIjzXz4aLypta8q@myminio-hl.minio-tenant.svc.cluster.local:9000"
cat > minio-values.yaml <<EOF
# Example configuration for Loki with S3 storage
loki:
  schemaConfig:
    configs:
      - from: "2024-04-01"
        store: tsdb
        object_store: s3
        schema: v13
        index:
          prefix: loki_index_
          period: 24h
  ingester:
    chunk_encoding: snappy
  tracing:
    enabled: true
  querier:
    max_concurrent: 1

  storage:
    type: s3
    bucketNames:
      chunks: "chunks"
      ruler: "ruler"
      admin: "admin"
    s3:
      # s3 URL can be used to specify the endpoint, access key, secret key, and bucket name
      #s3: s3://access_key:secret_access_key@custom_endpoint/bucket_name
      s3: ${MINIO_URL}
      # AWS endpoint URL
      #endpoint: <your-endpoint>
      ## AWS region where the S3 bucket is located
      #region: <your-region>
      ## AWS secret access key
      #secretAccessKey: <your-secret-access-key>
      ## AWS access key ID
      #accessKeyId: <your-access-key-id>
      ## AWS signature version (e.g., v2 or v4)
      #signatureVersion: <your-signature-version>
      ## Forces the path style for S3 (true/false)
      #s3ForcePathStyle: false
      ## Allows insecure (HTTP) connections (true/false)
      #insecure: true
      ## HTTP configuration settings
      #http_config: {}

deploymentMode: Distributed

# Disable minio storage
minio:
    enabled: false

ingester:
  replicas: 1
querier:
  replicas: 1
  maxUnavailable: 1
queryFrontend:
  replicas: 1
  maxUnavailable: 1
queryScheduler:
  replicas: 1
distributor:
  replicas: 1
  maxUnavailable: 1
compactor:
  replicas: 1
indexGateway:
  replicas: 1
  maxUnavailable: 1

bloomCompactor:
  replicas: 0
bloomGateway:
  replicas: 0

backend:
  replicas: 0
read:
  replicas: 0
write:
  replicas: 0

singleBinary:
  replicas: 0
EOF

# 用于测试: https://github.com/grafana/loki/blob/main/cmd/loki/loki-local-config.yaml
#wget https://github.com/grafana/loki/raw/main/cmd/loki/loki-local-config.yaml

# 卸载
# helm uninstall loki -n loki
helm upgrade --install loki loki \
--namespace=loki \
--create-namespace \
-f loki/values.yaml \
-f minio-values.yaml

# otel转发到loki
#values.yaml
cat otel-to-loki.yaml <<EOF
loki
  limits_config:
    allow_structured_metadata: true
EOF
