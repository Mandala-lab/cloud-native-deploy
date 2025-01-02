package server

import (
	"fmt"
	"github.com/go-kratos/kratos/v2/registry"
	"github.com/google/wire"
	"github.com/hashicorp/consul/api"
	"register/internal/conf"
)

// ProviderSet is server providers.
var ProviderSet = wire.NewSet(NewGRPCServer, NewHTTPServer, NewRegistrar)

func NewRegistrar(conf *conf.Registry) registry.Registrar {
	fmt.Println("conf:", conf.Consul)
	c := &api.Config{
		// Address: "192.168.2.181:8500",
		// Scheme:  "http",
		Address:    conf.Consul.Address,
		Scheme:     conf.Consul.Schema,
		PathPrefix: "",
		Datacenter: "",
		Transport:  nil,
		HttpClient: nil,
		HttpAuth:   nil,
		WaitTime:   0,
		Token:      "",
		TokenFile:  "",
		Namespace:  "",
		Partition:  "",
		TLSConfig:  api.TLSConfig{},
	}
	cli, err := api.NewClient(c)
	if err != nil {
		panic(err)
	}

	r := consul.New(cli, consul.WithHealthCheck(false))
	return r
}
