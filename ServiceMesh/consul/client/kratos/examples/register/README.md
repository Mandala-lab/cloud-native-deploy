1. 定义Consul配置
   `configs/register.yaml`

```yml
consul:
  address: 192.168.0.158
  schema: http
  health_check: false

```

2. conf层添加consul配置之后重新生成conf配置:`make config`
   `conf/conf.proto`

```proto
message Server {
  message HTTP {
    string network = 1;
    string addr = 2;
    google.protobuf.Duration timeout = 3;
  }
  message GRPC {
    string network = 1;
    string addr = 2;
    google.protobuf.Duration timeout = 3;
  }
  
  message Consul {
    string addr = 1;
    string schema = 2;
    bool healthChech = 3;
  }

  HTTP http = 1;
  GRPC grpc = 2;
  Consul consul = 3;
}
```

3. server层定义:
   `server/register.go`

```go
package server

import (
	"github.com/go-kratos/kratos/contrib/registry/consul/v2"
	"github.com/go-kratos/kratos/v2/registry"
	consulAPI "github.com/hashicorp/consul/api"
	"kratos-casbin/app/admin/internal/conf"
)

func NewRegistrar(conf *conf.Registry) registry.Registrar {
	c := consulAPI.DefaultConfig()
	c.Address = conf.Consul.Address
	c.Scheme = conf.Consul.Scheme
	cli, err := consulAPI.NewClient(c)
	if err != nil {
		panic(err)
	}
	r := consul.New(cli, consul.WithHealthCheck(conf.Consul.HealthCheck))
	return r
}

```

4. 注入依赖之后重新生成wire: `make generate`
   `server/server.go`

```go
package server

import (
	"github.com/google/wire"
)

// ProviderSet is server providers.
var ProviderSet = wire.NewSet(NewHTTPServer, NewRegistrar)

```

5. 注入口添加配置
   `cmd/xxx/main.go`

```go
func newApp(
logger log.Logger,
gs *grpc.Server,
hs *http.Server,
reg registry.Registrar, // 从server层作为依赖注入
) *kratos.App {
return kratos.New(
kratos.ID(id),
kratos.Name(Name),
kratos.Version(Version),
kratos.Metadata(map[string]string{}),
kratos.Logger(logger),
kratos.Server(
gs,
hs,
),
kratos.Registrar(reg), // 注册到Consul
)
}
```

## 参考

1. https://github.com/lisa-sum/kratos-consul
2. https://go-kratos.dev/docs/component/registry/
