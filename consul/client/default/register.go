package main

import (
	"fmt"
	consul "github.com/hashicorp/consul/api"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
)

const ID = "1"
const REGISTER_SERVER_NAME = "test.service.register"
const SERVER_NAME = "microservice-shop.service.account"

var TAGS = []string{"video"}

const HOST = "192.168.2.181"
const PORT = 8500

func main() {
	// 创建Consul客户端
	config := &consul.Config{
		Address:    fmt.Sprintf("%s:%d", HOST, PORT), // consul注册地址, 默认是localhost:8500
		Scheme:     "",
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
		TLSConfig:  consul.TLSConfig{},
	}
	client, err := consul.NewClient(config)
	if err != nil {
		log.Fatal("Consul客户端创建失败:", err)
	}

	// 注册服务
	err = registerService(client)
	if err != nil {
		log.Fatal("服务注册失败:", err)
	}

	// 发现服务
	discoveredService, err := discoverService(client, SERVER_NAME)
	if err != nil {
		log.Fatal("服务发现失败:", err)
	}

	// 调用发现的服务
	callService(discoveredService)

	// 等待信号以进行优雅关闭
	waitForSignal()
}

func registerService(client *consul.Client) error {
	// 微服务名称采用三段式的命名规则，中间使用中横线分隔，即xxxx-xxxx-xxxx形式
	// 一级服务名为组织名称，如hope，二级服务名为应用或项目的名称，如madp，三级服务名为功能模块的名称，如auth。
	// 整体为hope-madp-auth，使用英文拼写，单词间不要使用空格和_。请全部使用小写字母

	// 创建服务注册信息
	reg := &consul.AgentServiceRegistration{
		ID:      ID,
		Name:    REGISTER_SERVER_NAME,
		Tags:    TAGS,
		Address: HOST,
		Port:    PORT,
		// Check: &consul.AgentServiceCheck{
		// 	HTTP:     "http://192.168.2.181:8080/health",
		// 	Interval: "10s",
		// },
	}

	// 注册服务
	err := client.Agent().ServiceRegister(reg)
	if err != nil {
		return err
	}

	fmt.Println("服务注册成功")
	return nil
}
func discoverService(client *consul.Client, serviceName string) (*consul.AgentService, error) {
	// 使用Consul进行服务发现
	passingOnly := true
	services, _, err := client.Health().Service(serviceName, "", passingOnly, nil)
	if err != nil {
		return nil, err
	}

	if len(services) == 0 {
		return nil, fmt.Errorf("未找到服务: %s", serviceName)
	}

	// 返回发现的服务
	return services[0].Service, nil
}
func callService(service *consul.AgentService) {
	// 调用发现的服务
	fmt.Printf("调用服务: %s\n", service.Service)

	resp, err := http.Get(fmt.Sprintf("http://%s:%d", service.Address, service.Port))
	if err != nil {
		log.Fatal("服务调用失败:", err)
	}
	defer resp.Body.Close()
	fmt.Println("服务调用成功")

}
func waitForSignal() {
	// 等待信号以进行优雅关闭
	sigCh := make(chan os.Signal, 1)
	signal.Notify(sigCh, syscall.SIGINT, syscall.SIGTERM)
	<-sigCh
	fmt.Println("接收到信号，开始关闭服务...")
	// 执行清理操作
	fmt.Println("服务已关闭")
}
