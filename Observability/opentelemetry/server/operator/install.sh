#!/usr/bin/env bash
# 启用 POSIX 模式并设置严格的错误处理机制
set -o posix errexit -o pipefail

declare path="/home/kurnetes/opentelemetry"
mkdir -p $path
cd $path ||exit

# 安装operator
# https://github.com/open-telemetry/opentelemetry-operator
wget https://github.com/open-telemetry/opentelemetry-operator/releases/latest/download/opentelemetry-operator.yaml
kubectl apply -f opentelemetry-operator.yaml

# 强制删除
# kubectl delete crd/opentelemetrycollectors.opentelemetry.io --grace-period=0 --force
# 如果不行, 尝试下行代码:
# kubectl patch crd/opentelemetrycollectors.opentelemetry.io -p '{"metadata":{"finalizers":[]}}' --type=merge

# 安装opentelemetry控制器实例

declare otel_collector_name="opentelemetry"
declare otel_collector_namespace="observability"
declare receivers_otel_grpc_url="localhost:4317"
declare receivers_otel_http_url="localhost:4318"
declare export_trace_url="http://localhost:4318"

while [[ $# -gt 0 ]]; do
  case $1 in
   --export_trace_url=*)
      export_trace_url="${1#*=}"
      ;;
    --otel_collector_name=*)
      otel_collector_name="${1#*=}"
      ;;
    --receivers_otel_grpc_url=*)
      receivers_otel_grpc_url="${1#*=}"
      ;;
    --receivers_otel_http_url=*)
      receivers_otel_http_url="${1#*=}"
      ;;
    *)
      echo "未知的命令行选项参数: $1"
      exit 1
      ;;
  esac
  shift
done

otel_collector_name="opentelemetry"
otel_collector_namespace="observability"
receivers_otel_grpc_url="0.0.0.0:4317"
receivers_otel_http_url="0.0.0.0:4318"
export_http_trace_url="http://node6.api-r.com:32087"
export_grpc_trace_url="http://node6.api-r.com:30397"

if kubectl get ns ${otel_collector_namespace}; then
  echo "skip"
else
  kubectl create ns ${otel_collector_namespace}
fi

kubectl delete -f opentelemetry-collector.yml -n ${otel_collector_namespace} || true
# v1beta1: https://github.com/open-telemetry/opentelemetry-operator/blob/main/docs/crd-changelog.md
cat > opentelemetry-collector.yml <<EOF
apiVersion: opentelemetry.io/v1beta1
kind: OpenTelemetryCollector
metadata:
  name: ${otel_collector_name}
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

    # 处理器
    # 将收集到的遥测数据进行处理
    # 例如: 过滤, 更新, 添加指标, 重试、批处理、加密甚至敏感数据筛选
    processors:
      memory_limiter:
        check_interval: 1s
        limit_percentage: 75
        spike_limit_percentage: 15
      batch:
        send_batch_size: 10000
        timeout: 10s

    # 导出器
    # 要导出到的后端服务URL地址, 注意要带schema协议
    # 例如Jaeger, Prometheus, Loki
    exporters:
      # 监听http链路,发送到jaeger
      otlphttp:
        endpoint: ${export_http_trace_url}
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
          processors: [memory_limiter, batch]
          exporters: [otlphttp]
EOF
kubectl apply -f opentelemetry-collector.yml -n "${otel_collector_namespace}"

kubectl get po -n "${otel_collector_namespace}"
kubectl patch svc ${otel_collector_name}-collector -n "${otel_collector_namespace}" -p '{"spec":{"type":"NodePort"}}'
kubectl get svc -n "${otel_collector_namespace}"
