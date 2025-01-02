package main

import (
	"context"
	semconv "go.opentelemetry.io/otel/semconv/v1.25.0"
	"log"
	"time"

	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/exporters/otlp/otlptrace"
	"go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracegrpc"
	"go.opentelemetry.io/otel/sdk/resource"
	sdktrace "go.opentelemetry.io/otel/sdk/trace"
)

func initTracer() func(context.Context) error {
	// 创建 OTLP gRPC 导出器
	exporter, err := otlptrace.New(
		context.Background(),
		otlptracegrpc.NewClient(
			otlptracegrpc.WithInsecure(),
			// otlptracegrpc.WithEndpoint("node5.apikv.com:30288"), // 修改为你的 OTEL Collector 地址和端口
			otlptracegrpc.WithEndpoint("node10.apikv.com:32163"), // 修改为你的 OTEL Collector 地址和端口
		),
	)
	if err != nil {
		log.Fatalf("Failed to create trace exporter: %v", err)
	}

	// 创建资源
	resources := resource.NewWithAttributes(
		semconv.SchemaURL,
		semconv.ServiceNameKey.String("my-service2"),
	)

	// 创建 TracerProvider
	tp := sdktrace.NewTracerProvider(
		sdktrace.WithBatcher(exporter),
		sdktrace.WithResource(resources),
	)

	// 设置全局 TracerProvider
	otel.SetTracerProvider(tp)

	// 返回关闭函数
	return tp.Shutdown
}

func main() {
	// 初始化 TracerProvider 并获取关闭函数
	shutdown := initTracer()
	defer func() {
		if err := shutdown(context.Background()); err != nil {
			log.Fatalf("Failed to shut down tracer provider: %v", err)
		}
	}()

	log.Println("Starting tracer provider")

	// 获取 Tracer
	tracer := otel.Tracer("example-tracer")

	// 创建一个 Span
	ctx := context.Background()
	_, span := tracer.Start(ctx, "main-span")
	defer span.End()

	// 模拟一些工作
	time.Sleep(time.Second)

	// 创建子 Span
	ctx, childSpan := tracer.Start(ctx, "child-span")
	defer childSpan.End()

	// 模拟一些工作
	time.Sleep(time.Second)
	log.Println("End tracer provider")
}
