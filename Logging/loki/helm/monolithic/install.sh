#!/usr/bin/env bash
# 启用 POSIX 模式并设置严格的错误处理机制
set -o posix errexit -o pipefail

# https://grafana.com/docs/loki/latest/setup/install/helm/install-monolithic/

cat > values.yaml <EOF
deploymentMode: SingleBinary
loki:
  auth_enabled: false
  commonConfig:
    replication_factor: 1
  storage:
    type: 'filesystem'
  schemaConfig:
    configs:
    - from: "2024-01-01"
      store: tsdb
      index:
        prefix: loki_index_
        period: 24h
      object_store: filesystem # we're storing on filesystem so there's no real persistence here.
      schema: v13
singleBinary:
  replicas: 1
read:
  replicas: 0
backend:
  replicas: 0
write:
  replicas: 0
EOF

# 关闭验证, 仅适合开发使用
# https://grafana.com/docs/loki/latest/operations/authentication/
cat > disable-auth.yml <<EOF
loki:
  auth_enabled: false
EOF


helm install loki grafana/loki \
--create-namespace loki \
-n loki \
-f values.yaml \
-f disable-auth.yml


cat > otel-loki.yml <<EOF
apiVersion: opentelemetry.io/v1beta1
kind: OpenTelemetryCollector
metadata:
  name: otel-loki
  namespace: observability
spec:
  config:
    # 接收器
    # 在启动otel-collector的服务器上所要接收的遥测数据
    # 例如: otlp, kafka, opencensus, zipkin
    receivers:
      otlp:
        protocols:
          grpc:
            endpoint: 0.0.0.0:4317
          http:
            endpoint: 0.0.0.0:4318
    processors:
      batch: {}
    # 导出器
    # 要导出到的后端服务URL地址, 注意要带schema协议
    # 例如Jaeger, Prometheus, Loki
    exporters:
      # 监听http链路,发送到jaeger
      otlp:
        endpoint: http://simple-prod-collector.observability.svc.cluster.local:4317
        tls:
          # 是否使用不安全的连接, 即HTTP明文传输
          insecure: true
          # TLS证书:
          #cert_file: cert.pem
          #key_file: cert-key.pem
      otlphttp:
        endpoint: http://simple-prod-collector.observability.svc.cluster.local:4318
        tls:
          # 是否使用不安全的连接, 即HTTP明文传输
          insecure: true
          # TLS证书:
          #cert_file: cert.pem
          #key_file: cert-key.pem
      otlphttp/logs:
        endpoint: http://loki-gateway.loki.svc.cluster.local
        tls:
          # 是否使用不安全的连接, 即HTTP明文传输
          insecure: true
          # TLS证书:
          #cert_file: cert.pem
          #key_file: cert-key.pem

    # 服务
    # https://opentelemetry.io/zh/docs/collector/configuration/#service
    # 该 service 部分用于根据接收器、处理器、导出器和扩展部分中的配置配置在收集器中启用的组件。
    # 如果配置了组件(receivers,processors,exporters)，但未在 service 字段中声明，则不会启用该组件
    service:
      pipelines:
        traces:
          receivers: [otlp]
          processors: [ batch ]
          exporters: [otlp,otlphttp]
        logs:
          receivers: [otlp]
          processors: [ batch ]
          exporters: [otlp,otlphttp/logs]

EOF

kubectl apply -f otel-loki.yml
