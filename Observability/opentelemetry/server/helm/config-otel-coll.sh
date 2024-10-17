#!/usr/bin/env bash
# 启用 POSIX 模式并设置严格的错误处理机制
set -o posix errexit -o pipefail

# opentelemetry-collector
otel_collector_name="otel"
otel_collector_namespace="observability"
receivers_otel_grpc_url="0.0.0.0:4317"
receivers_otel_http_url="0.0.0.0:4318"
export_otel_http_url="http://45.207.192.136:30253"
export_otel_grpc_url="http://45.207.192.136:32299"
#cat > opentelemetry-collector.yaml <<EOF
#apiVersion: opentelemetry.io/v1beta1
#kind: OpenTelemetryCollector
#metadata:
#  name: ${otel_collector_name}
#  namespace: ${otel_collector_namespace}
#spec:
#  config:
#    # 接收器
#    # 在启动otel-collector的服务器上所要接收的遥测数据
#    # 例如: otlp, kafka, opencensus, zipkin
#    receivers:
#      otlp:
#        protocols:
#          grpc:
#            endpoint: ${receivers_otel_grpc_url}
#          http:
#            endpoint: ${receivers_otel_http_url}
#
#    # 处理器
#    # 将收集到的遥测数据进行处理
#    # 例如: 过滤, 更新, 添加指标, 重试、批处理、加密甚至敏感数据筛选
#    processors:
#      memory_limiter:
#        check_interval: 1s
#        limit_percentage: 75
#        spike_limit_percentage: 15
#      batch:
#        send_batch_size: 10000
#        timeout: 10s
#
#    # 导出器
#    # 要导出到的后端服务URL地址, 注意要带schema协议
#    # 例如Jaeger, Prometheus, Loki
#    exporters:
#      # 监听http链路,发送到jaeger
#      otlphttp:
#        endpoint: ${export_http_trace_url}
#        tls:
#          # 是否使用不安全的连接, 即HTTP明文传输
#          insecure: true
#          # TLS证书:
#          #cert_file: cert.pem
#          #key_file: cert-key.pem
#
#    # 服务
#    # https://opentelemetry.io/zh/docs/collector/configuration/#service
#    # 该 service 部分用于根据接收器、处理器、导出器和扩展部分中的配置配置在收集器中启用的组件。
#    # 如果配置了组件(receivers,processors,exporters)，但未在 service 字段中声明，则不会启用该组件
#    service:
#      pipelines:
#        traces:
#          receivers: [otlp]
#          processors: [memory_limiter, batch]
#          exporters: [otlphttp]
#
#EOF

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
          grpc: {}
            #endpoint: ${receivers_otel_grpc_url}
          http: {}
            #endpoint: ${receivers_otel_http_url}

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
kubectl patch -n $otel_collector_namespace svc otel-collector -p '{"spec":{"type":"NodePort"}}'
