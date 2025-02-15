# 微服务-可观测性-链路追踪

本文介绍可观测性在Golang的实践, 使用与Golang语言的相关的技术栈组成

## 声明

1. 本文全部内容均由本人收集材料/编写, 没有使用任何AI工具生成/编写
2. 转载需标注本文链接

## 名词解释

1. metrics: 指标, 某些人可能称为"度量指标",
2. traces: 链路追踪
3. logging: 日志
4. telemetry: 遥测
5. otel: OpenTelemetry 的缩写形式
6. otel-collector: 关于如何接收、处理和导出遥测数据的与供应商无关的实现。可部署为代理或网关的单个二进制文件。也称为
   OpenTelemetry 收集器。
7. OTLP: OpenTelemetry 协议的缩写
8. Jaeger: 分布式链路追踪组件
9. receivers, 接收器, 收集器组件, 收集器用于定义遥测数据接收方式的术语。接收器可以是基于推式或拉式
10. processors, 处理器组件
11. exporters, 导出器组件, 提供向使用者发出遥测数据的功能。导出器可以是基于推送或拉取的
12. extensions, 扩展器组件
13. service, 服务组件, 应用程序的组件。通常部署一个服务的多个实例以实现高可用性和可伸缩性。一个服务可以部署在多个位置
14. 分布式追踪: 跟踪单个请求（称为跟踪）的进度，因为它由组成应用程序的服务处理。分布式跟踪跨越了流程、网络和安全边界
15. 侵入式可观测性: 在源代码中创建遥测数据, 有破坏代码的含义, 所以叫侵入式可观测性, 某些人称为"插桩"
16. 供应商: 后端可观测性组件, 例如: opencensus, zipkin

## 介绍

本文是可观测性的Traces的应用

可观测性由大多数人普遍认可和定义的三部分组成:

1. Metrics
2. Traces
3. Logging

讲解Golang微服务中的Trace的实践与应用, 使用OpenTelemetry可观测性微服务中间件与Jaeger分布式链路追踪服务器组件,
分为几个步骤:

1. 在服务器中安装OpenTelemetry可观测性微服务中间件与配置需要采集的遥测数据并导出遥测数据到jaeger
2. 在服务器中安装Jaeger链路追踪服务器
3. 在Golang客户端使用otel发送HTTP/gRPC的遥测数据到otel-collector服务端

otel-collector运作原理:
![img](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/1d052983d25043cd9b1be8aefa16cee9~tplv-k3u1fbpfcp-image.image#?w=984\&h=698\&s=133622\&e=svg\&b=ffffff)

本文使用的流程是:

1. go客户端使用opentelemetry的官方库otel对源代码中的函数进行标记(metadata, baggage, attribute, span, label)等创建遥测数据
2. 一旦有用户访问了这些函数, 那么客户端将生成的遥测数据发送到otel-collector中间件中接收这些供应商协议(例如: otlp, kafka,
   opencensus, zipkin), 然后对遥测数据进行处理(例如: 过滤, 更新, 添加指标), 在此期间, 也可以添加与遥测数据不相关的任务(
   例如，可以添加用于收集器运行状况监控、服务发现或数据转发等的扩展), 再导出到后端

## 安装opentelemetry可观测性微服务中间件

OpenTelemetry支持多种部署方式, 本篇讲解微服务, 不使用传统的二进制, 操作系统包管理器等此类安装,
使用微服务的两个热门基础设施: Kubernetes与Docker来部署

端口的含义:

1. 4317: 负责接收grpc传输的遥测数据
2. 4318: 负责接收http/json类型的遥测数据

### Kubernetes

Kubernetes的部署有yaml和helm和kubernetes operator部署方式,
yaml仅适合快速开发的目的, 并不适合生产, 推荐使用helm或者kubernetes operator方式部署, 本文使用operator部署方式

一键安装脚本, 支持sh的服务器即可运行:

```shell
chmod +x ./operator/install.sh
./operator/install.sh
```

##### 要求

1. 正常运行的Kubernetes集群
2. 拥有创建命名空间, 部署资源的RBAC权限的用户

### Docker

一键安装脚本, 支持bash的服务器即可运行

#### 要求

1. Docker
2. docker-compose
3. 拥有创建目录, 使用Docker权限的用户

```shell
#!/usr/bin/env bash
# 启用 POSIX 模式并设置严格的错误处理机制
set -o posix errexit -o pipefail

docker pull otel/opentelemetry-collector-contrib:latest

rm -rf /home/docker/opentelemetry/*
rm -rf /home/docker/opentelemetry/data/*
rm -rf /home/docker/opentelemetry/conf/*

docker-compose -f /home/docker/opentelemetry/opentelemetry-collector-compose.yml down || true

mkdir -pv /home/docker/opentelemetry
mkdir -pv /home/docker/opentelemetry/data
mkdir -pv /home/docker/opentelemetry/conf

chmod 600 /home/docker/opentelemetry
chmod 600 /home/docker/opentelemetry/data
chmod 600 /home/docker/opentelemetry/conf

cd /home/docker/opentelemetry || exit

# https://opentelemetry.io/zh/docs/collector/configuration
cat > /home/docker/opentelemetry/conf/otel-collector.yaml <<EOF
# 接收器
# 在启动otel-collector的服务器上所要接收的遥测数据
# 例如: otlp, kafka, opencensus, zipkin
receivers:
  # 收集otlp协议
  otlp:
    protocols:
      # 在本机启动grpc收集器, 收集使用gRPC传输的遥测数据
      grpc:
      #   endpoint: localhost:4317
      # 在本机启动http收集器, 收集json类型的遥测数据
      http:
      #   endpoint: localhost:4318

# 处理器
# 将收集到的遥测数据进行处理
# 例如: 过滤, 更新, 添加指标
processors:
  probabilistic_sampler:
    hash_seed: 22
    sampling_percentage: 100
  batch:
    timeout: 100ms

# 导出器
# 要导出到的后端服务URL
# 例如Jaeger, Prometheus, Loki
exporters:
  otlp/jaeger:
    #endpoint: 159.75.231.54:4317
    endpoint: 8.141.10.44:4317
    tls:
      # 是否使用不安全的连接, 即HTTP明文传输
      insecure: true
      # TLS证书:
      #cert_file: cert.pem
      #key_file: cert-key.pem

#  扩展器
# 扩展器是可选组件，用于扩展收集器的功能，以完成与处理遥测数据不直接相关的任务。
# 例如，您可以添加用于收集器运行状况监控、服务发现或数据转发等的扩展。
extensions:
  health_check:
  pprof:
  zpages:
  memory_ballast:
    size_mib: 512

# 服务
# https://opentelemetry.io/zh/docs/collector/configuration/#service
# 该 service 部分用于根据接收器、处理器、导出器和扩展部分中的配置配置在收集器中启用的组件。
# 如果配置了组件，但未在 service 该部分中定义，则不会启用该组件
service:
  extensions: [ health_check, pprof, zpages, memory_ballast ]
  pipelines:
    traces:
      receivers: [ otlp ]
      processors: [ probabilistic_sampler, batch ]
      exporters: [ otlp/jaeger ]
#    metrics:
#      receivers: [ ]
#      processors: [ ]
#      #exporters: [ ]
#      exporters: [ ]
#    logs:
#      receivers: [ ]
#      processors: [ ]
#      #exporters: [ ]
#      exporters: [ ]

EOF

cat > /home/docker/opentelemetry/opentelemetry-collector-compose.yml <<EOF
services:
  otel-collector:
    command:
      - --config
      - /otel-config.yaml
    #image: otel/opentelemetry-collector-contrib:0.102.1
    image: otel/opentelemetry-collector-contrib:latest
    container_name: otel-collector
    volumes:
      - /home/docker/opentelemetry/conf/otel-collector.yaml:/otel-config.yaml
    ports:
      - 0.0.0.0:1888:1888 # pprof extension
      - 0.0.0.0:8888:8888 # Prometheus metrics exposed by the Collector
      - 0.0.0.0:8889:8889 # Prometheus exporter metrics
      - 0.0.0.0:13133:13133 # health_check extension
      - 0.0.0.0:4317:4317 # OTLP gRPC receiver
      - 0.0.0.0:4318:4318 # OTLP http receiver
      - 0.0.0.0:55679:55679 # zpages extension
EOF

docker-compose -f /home/docker/opentelemetry/opentelemetry-collector-compose.yml up -d
docker-compose -f /home/docker/opentelemetry/opentelemetry-collector-compose.yml logs -f

```

## 客户端

### `go-gin`的http库示例

**由于代码篇幅很长, 这里仅展示go-gin这个国内热门HTTP库,
更多示例的源码在GitHub仓库: [opentelemetry examples](https://github.com/sunmery/opentelemetry)**

将`url := "http://192.168.2.152:4317"` 替换为实际的URL, 如果是Docker部署, 那么只需要替换host ip, 如果是Kubernetes
NodePort 类型就需要更改4317所对应的端口

```go
package main

import (
	"helper"
	"os"
	"time"

	"github.com/gin-gonic/gin"
	"go.opentelemetry.io/contrib/instrumentation/github.com/gin-gonic/gin/otelgin"
	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/attribute"
	"go.opentelemetry.io/otel/exporters/jaeger"
	"go.opentelemetry.io/otel/propagation"
	"go.opentelemetry.io/otel/sdk/resource"
	"go.opentelemetry.io/otel/sdk/trace"
	semconv "go.opentelemetry.io/otel/semconv/v1.18.0"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
	"gorm.io/gorm/schema"
	"gorm.io/plugin/opentelemetry/tracing"
)

const (
	traceName = "mxshop-otel-gin"
)

type BaseModel struct {
	ID        int32          `gorm:"primary_key;comment:ID"`
	CreatedAt time.Time      `gorm:"column:add_time;comment:创建时间"`
	UpdatedAt time.Time      `gorm:"column:update_time;comment:更新时间"`
	DeletedAt gorm.DeletedAt `gorm:"comment:删除时间"`
	IsDeleted bool           `gorm:"comment:是否删除"`
}
type User struct {
	BaseModel
	Mobile   string     `gorm:"index:idx_mobile;unique;type:varchar(11);not null;comment:手机号"`
	Password string     `gorm:"type:varchar(100);not null;comment:密码"`
	NickName string     `gorm:"type:varchar(20);comment:账号名称"`
	Birthday *time.Time `gorm:"type:datetime;comment:出生日期"`
	Gender   string     `gorm:"column:gender;default:male;type:varchar(6);comment:femail表示女,male表示男"`
	Role     int        `gorm:"column:role;default:1;type:int;comment:1表示普通用户,2表示管理员"`
}

var tp *trace.TracerProvider

func tracerProvider() error {
	url := "http://192.168.2.152:4317"
	jexp, err := jaeger.New(jaeger.WithCollectorEndpoint(jaeger.WithEndpoint(url)))
	if err != nil {
		panic(err)
	}

	// 上报器 批量处理链路追踪器
	tp = trace.NewTracerProvider(
		trace.WithBatcher(jexp),
		// 如果未使用此选项，跟踪程序提供程序将使用该资源 默认资源。
		trace.WithResource(
			resource.NewWithAttributes(
				// 固定写法
				semconv.SchemaURL,
				// 设置service
				semconv.ServiceNameKey.String("mxshop-user-gin"),
				// 设置Process键值对 可以让其他人员分析 全局的，设置到trace上的
				attribute.String("environment", "dev"),
				attribute.Int("ID", 1),
			),
		),
	)
	otel.SetTracerProvider(tp)
	// 设置传播提取器
	otel.SetTextMapPropagator(propagation.NewCompositeTextMapPropagator(propagation.TraceContext{}, propagation.Baggage{}))
	return nil
}

func Server2(c *gin.Context) {
	dsn := "postgresql://root:msdnmm@192.168.2.158:5432/postgres"
	newLogger := logger.New(
		helper.New(os.Stdout, "\r\n", helper.LstdFlags),
		logger.Config{
			LogLevel: logger.Info,
			Colorful: true,
		},
	)
	db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{
		NamingStrategy: schema.NamingStrategy{
			SingularTable: true,
		},
		Logger: newLogger,
	})
	if err != nil {
		panic(err)
	}
	// 之前初始化好了*trace.TracerProvider这里就不用再初始化了
	if err = db.Use(tracing.NewPlugin()); err != nil {
		panic(err)
	}

	// 负责span的抽取和生成
	// 如果使用中间件otelgin.Middleware 它会把自己trace span，把context放到c.Request.Context()中
	// ctx := c.Request.Context()
	// p := otel.GetTextMapPropagator()
	// tr := tp.Tracer(traceName)
	// sCtx := p.Extract(ctx, propagation.HeaderCarrier(c.Request.Header))
	// spanCtx, span := tr.Start(sCtx, "server")

	if err = db.WithContext(c.Request.Context()).Model(User{BaseModel: BaseModel{ID: 12}}).First(&User{}).Error; err != nil {
		panic(err)
	}

	time.Sleep(500 * time.Millisecond)
	// span.End()
	c.JSON(200, gin.H{})

}
func main() {
	_ = tracerProvider()
	r := gin.Default()
	// 添加trace中间件
	r.Use(otelgin.Middleware("my-server"))
	r.GET("/", func(c *gin.Context) {
		c.JSON(200, gin.H{})
	})
	r.GET("/server", Server2)
	err := r.Run(":8090")
	if err != nil {
		return
	}
}

```

### kratos微服务库示例

完整的代码很长, 这里仅展示主要构成的伪代码,
源码在GitLab仓库[full-stack-engineering](https://gitlab.com/lookeke/full-stack-engineering)

conf/conf.proto:

```proto
message Bootstrap {
  Server server = 1;
  Data data = 2;
  Trace trace = 3;
}

// 可观测性
// 分布式链路追踪
message Trace {
  message Jaeger {
    message GRPC {
      string endpoint = 1;
    }
    message HTTP {
      string endpoint = 1;
    }
    string service_name = 1;
    GRPC grpc = 2;
    HTTP http = 3;
  }
  Jaeger jaeger = 1;
}

```

configs/config.yaml:

```yaml
# 可观测性
jaeger:
  service_name: full-stack-engineering-backend-api
  grpc:
    endpoint: host:4317
  http:
    endpoint: host:4318
```

cmd/main.go

```go
func main() {
...

// trace
var tc conf.Trace
if err := c.Scan(&tc); err != nil {
panic(err)
}

app, cleanup, err := wireApp(bc.Server, &tc, bc.Data, logger)
if err != nil {
panic(err)
}

defer cleanup()

...
}
```

server/http.go:

```go
package server

import (
	"context"
	"fmt"

	v1 "backend/api/helloworld/v1"
	"backend/internal/conf"
	myAuthz "backend/internal/helper/authz"
	"backend/internal/service"

	"github.com/casbin/casbin/v2/model"
	fileAdapter "github.com/casbin/casbin/v2/persist/file-adapter"
	"github.com/go-kratos/kratos/v2/middleware/logging"
	"github.com/go-kratos/kratos/v2/middleware/selector"
	"github.com/go-kratos/kratos/v2/middleware/tracing"
	"github.com/gorilla/handlers"
	casbinM "github.com/tx7do/kratos-casbin/authz/casbin"
	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/attribute"
	"go.opentelemetry.io/otel/propagation"
	sdktrace "go.opentelemetry.io/otel/sdk/trace"

	"go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracehttp"
	"go.opentelemetry.io/otel/sdk/resource"
	semconv "go.opentelemetry.io/otel/semconv/v1.25.0"

	"github.com/go-kratos/kratos/v2/helper"
	"github.com/go-kratos/kratos/v2/middleware/recovery"
	"github.com/go-kratos/kratos/v2/transport/http"

	"github.com/go-kratos/kratos/v2/middleware/auth/jwt"
	jwtv5 "github.com/golang-jwt/jwt/v5"
)

// NewWhiteListMatcher 设置白名单，不需要 token 验证的接口
func NewWhiteListMatcher() selector.MatchFunc {
	whiteList := make(map[string]struct{})
	whiteList["/helloworld.v1.GreeterService/SayHello"] = struct{}{}
	whiteList["/helloworld.v1.GreeterService/Query"] = struct{}{}
	whiteList["/shop.v1.ShopService/Login"] = struct{}{}
	return func(ctx context.Context, operation string) bool {
		if _, ok := whiteList[operation]; ok {
			return false
		}
		return true
	}
}

// Initializes an OTLP exporter, and configures the corresponding trace provider.
func initTracerProvider(ctx context.Context, res *resource.Resource, conn string) (func(context.Context) error, error) {
	// Set up a trace exporter

	// 服务端的Jaeger支持HTTPS时使用
	// traceExporter, err := otlptracehttp.New(ctx, otlptracehttp.WithEndpoint(conn))

	// 服务端的Jaeger不支持HTTPS时使用otlptracehttp.WithInsecure()显式声明只使用HTTP不安全的连接
	traceExporter, err := otlptracehttp.New(ctx, otlptracehttp.WithInsecure(), otlptracehttp.WithEndpoint(conn))
	if err != nil {
		return nil, fmt.Errorf("failed to create trace exporter: %w", err)
	}

	// Register the trace exporter with a TracerProvider, using a batch
	// span processor to aggregate spans before export.
	bsp := sdktrace.NewBatchSpanProcessor(traceExporter)
	tracerProvider := sdktrace.NewTracerProvider(
		// sdktrace.WithSampler(sdktrace.AlwaysSample()),
		// 将基于父span的采样率设置
		sdktrace.WithSampler(sdktrace.ParentBased(sdktrace.TraceIDRatioBased(1.0))),
		// 始终确保在生产中批量处理
		sdktrace.WithBatcher(traceExporter),
		// 在资源中记录有关此应用程序的信息
		sdktrace.WithResource(res),
		sdktrace.WithSpanProcessor(bsp),
	)
	otel.SetTracerProvider(tracerProvider)

	// Set global propagator to tracecontext (the default is no-op).
	otel.SetTextMapPropagator(propagation.TraceContext{})

	// Shutdown will flush any remaining spans and shut down the exporter.
	return tracerProvider.Shutdown, nil
}

// NewMiddleware 创建中间件
func NewMiddleware(
	ac *conf.Auth,
	c *conf.Server,
	logger helper.Logger,
) http.ServerOption {
	// casbin start
	m, _ := model.NewModelFromFile("../../configs/authz/authz_model.conf")
	a := fileAdapter.NewAdapter("../../configs/authz/authz_policy.csv")
	// casbin end
	return http.Middleware(
		recovery.Recovery(),
		logging.Server(logger), // logging 日志
		tracing.Server(),       // trace 链路追踪
		// jwt 身份验证
		selector.Server(
			jwt.Server(func(token *jwtv5.Token) (interface{}, error) {
				return []byte(ac.JwtKey), nil
			}),
			casbinM.Server(
				casbinM.WithCasbinModel(m),
				casbinM.WithCasbinPolicy(a),
				casbinM.WithSecurityUserCreator(myAuthz.NewSecurityUser),
			),
		).
			Match(NewWhiteListMatcher()).
			Build(),
	)
}

// NewHTTPServer new an HTTP server.
func NewHTTPServer(
	ac *conf.Auth,
	c *conf.Server,
	logger helper.Logger,
	tr *conf.Trace,
	greeter *service.GreeterService,
) *http.Server {
	// trace start
	ctx := context.Background()

	res, err := resource.New(ctx,
		resource.WithAttributes(
			// The service name used to display traces in backends
			// serviceName,
			semconv.ServiceNameKey.String(tr.Jaeger.ServiceName),
			attribute.String("exporter", "otlptracehttp"),
			attribute.String("environment", "dev"),
			attribute.Float64("float", 312.23),
		),
	)
	if err != nil {
		helper.Fatal(err)
	}

	// shutdownTracerProvider, err := initTracerProvider(ctx, res, tr.Jaeger.Http.Endpoint)
	_, err2 := initTracerProvider(ctx, res, tr.Jaeger.Http.Endpoint)
	if err2 != nil {
		helper.Fatal(err)
	}
	// trace end

	opts := []http.ServerOption{
		NewMiddleware(ac, c, logger),
		http.Filter(handlers.CORS( // 浏览器跨域
			handlers.AllowedHeaders([]string{"X-Requested-With", "Content-Type", "Authorization"}),
			handlers.AllowedMethods([]string{"GET", "POST", "PUT", "PATCH", "DELETE", "HEAD", "OPTIONS"}),
			// handlers.AllowedOrigins([]string{"http://localhost:3000", "http://127.0.0.1:3000"}),
			handlers.AllowedOrigins([]string{"*"}),
			handlers.AllowCredentials(),
		)),
	}
	if c.Http.Network != "" {
		opts = append(opts, http.Network(c.Http.Network))
	}
	if c.Http.Addr != "" {
		opts = append(opts, http.Address(c.Http.Addr))
	}
	if c.Http.Timeout != nil {
		opts = append(opts, http.Timeout(c.Http.Timeout.AsDuration()))
	}
	srv := http.NewServer(opts...)
	v1.RegisterGreeterServiceHTTPServer(srv, greeter)
	return srv
}

```

## 参考

1. https://gitlab.com/lookeke/full-stack-engineering
2. https://github.com/sunmery/opentelemetry
3. https://opentelemetry.io/docs

## 关于作者

### 基本信息

- 专业: 计算机科学方向
- 最近研究:
    - gitlab ci + argocd
    - 软件工程在前后端的工程化实践
- 感兴趣方向:
    - Kuebrnetes
    - DevOps

### 为什么写作

1. 分享欲
2. 提高写作水平
3. 不记死内容
4. 被人关注

### 写作目标:

0. 内容专业性强
1. 内容详细, 希望各类人都能看懂
2. 不起唬人标题
3. 每个文章内容都经过本人在干净的环境创建和验证
4. 不设坑, 不写 xx坑 导致 xx
5. 不写垃圾文, 水文, 与技术无关的文

### Github

- https://github.com/Mandala-lab
- https://github.com/sunmery

### 网站

- www.lookeke.com
- www.lookeke.top
- www.lookeke.cn
- www.lookeke.cc
