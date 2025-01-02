#!/usr/bin/env bash
# 启用 POSIX 模式并设置严格的错误处理机制
set -o posix errexit -o pipefail

# 配置: https://opentelemetry.io/docs/collector/configuration/

# opentelemetry-collector
otel_collector_name="otel"
otel_collector_namespace="observability"
receivers_otel_grpc_url="0.0.0.0:4317"
receivers_otel_http_url="0.0.0.0:4318"
#export_otel_http_url="http://node9.api-r.com:30253"
#export_otel_grpc_url="http://node9.api-r.com:32299"
export_otel_grpc_url="simple-prod-collector.${otel_collector_namespace}.svc.cluster.local:4317"
export_otel_http_url="simple-prod-collector.${otel_collector_namespace}.svc.cluster.local:4318"

cat > opentelemetry-collector.yaml <<EOF
apiVersion: opentelemetry.io/v1beta1
kind: OpenTelemetryCollector
metadata:
  name: ${otel_collector_name}
  namespace: ${otel_collector_namespace}
spec:
  config:
    # 接收器
    # 在启动otel-collector的服务器上所要接收的遥测数据
    # 例如: otlp, kafka, opencensus, zipkin
    receivers:
      otlp:
        protocols:
          grpc:
            endpoint: ${receivers_otel_grpc_url}
          http:
            endpoint: ${receivers_otel_http_url}
    processors:
      batch: {}
    # 导出器
    # 要导出到的后端服务URL地址, 注意要带schema协议
    # 例如Jaeger, Prometheus, Loki
    exporters:
      # 监听http链路,发送到jaeger
      otlp:
        endpoint: ${export_otel_grpc_url}
        tls:
          # 是否使用不安全的连接, 即HTTP明文传输
          insecure: true
          # TLS证书:
          #cert_file: cert.pem
          #key_file: cert-key.pem
      otlphttp:
        endpoint: ${export_otel_http_url}
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
          processors: []
          exporters: [otlp,otlphttp]

EOF

kubectl delete -f opentelemetry-collector.yaml || true
kubectl apply -f opentelemetry-collector.yaml
sleep 1
kubectl patch -n $otel_collector_namespace svc otel-collector -p '{"spec":{"type":"NodePort"}}'
