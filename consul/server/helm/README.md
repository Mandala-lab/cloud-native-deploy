# Kubernetes helm install consul

根据官方的安装教程编写的shell, 简化了安装步骤, 浓缩为一个shell脚本

## 先决条件

1. 一个正常运行的Kubernetes集群
2. Helm版本3.x以上

## 快速安装

```shell
chmod +x ./install.sh
./install.sh
```

## 自定义安装

### 配置项

参阅[helm values](https://developer.hashicorp.com/consul/docs/k8s/helm)获取helm values的可配置的参数,
并 修改目录下的`consul-values.yaml`配置以满足你的个性化需求,之后重新运行`./install.sh`脚本即可

## 资料

1. https://developer.hashicorp.com/consul/tutorials/get-started-kubernetes/kubernetes-gs-deploy
2. https://developer.hashicorp.com/consul/docs/k8s/helm
