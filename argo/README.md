# 安装

推荐使用OLM安装一个帮助管理集群上运行的 Operator 的工具

```shell
curl -sL https://github.com/operator-framework/operator-lifecycle-manager/releases/download/v0.28.0/install.sh | bash -s v0.28.0
```

https://github.com/argoproj-labs/argocd-operator/releases/tag

```shell
VERSION="v0.9.1"
wget https://github.com/argoproj-labs/argocd-operator/archive/refs/tags/${VERSION}.zip
```

安装操作员, 此 Operator 将安装在 “operators” 命名空间中，并可从集群中的所有命名空间中使用

```shell
kubectl create -f https://operatorhub.io/install/argocd-operator.yaml
kubectl get csv -n operators
```
