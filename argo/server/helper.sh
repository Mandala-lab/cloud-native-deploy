#!/usr/bin/env bash
# 启用 POSIX 模式并设置严格的错误处理机制
set -o posix errexit -o pipefail

argocd proj create tiktok-e-commence

argocd proj add-source tiktok-e-commence https://github.com/sunmery/test-argocd.git
argocd proj add-source tiktok-e-commence https://github.com/sunmery/tiktok_e-commence.git

# 允许的目标集群和命名空间（对于始终提供服务器的集群，名称不用于匹配）
# argocd proj add-destination <PROJECT> <CLUSTER>,<NAMESPACE>
argocd proj add-destination tiktok-e-commence https://10.0.1.3:6443 tiktok
argocd proj add-destination tiktok-e-commence https://10.0.1.3:6443 default
argocd proj add-destination tiktok-e-commence https://kubernetes.default.svc tiktok
argocd proj add-destination tiktok-e-commence https://kubernetes.default.svc default

# 允许的目标 K8s 资源类型通过命令进行管理。请注意，命名空间范围的资源通过拒绝列表进行限制，而集群范围的资源通过允许列表进行限制
# argocd proj allow-cluster-resource <PROJECT> <GROUP> <KIND>
#argocd proj allow-cluster-resource tiktok-e-commence admin Namespace
#argocd proj allow-namespace-resource <PROJECT> <GROUP> <KIND>
#argocd proj deny-cluster-resource <PROJECT> <GROUP> <KIND>
#argocd proj deny-namespace-resource <PROJECT> <GROUP> <KIND>

# argocd app delete e-commence
argocd app create e-commence \
--project tiktok-e-commence \
--repo https://github.com/sunmery/test-argocd.git \
--path deployment/user \
--dest-server https://10.0.1.3:6443 \
--dest-namespace tiktok \
--validate

# test
argocd app delete e-commence || true
argocd app create e-commence \
--project tiktok-e-commence \
--repo https://github.com/sunmery/tiktok_e-commence.git \
--revision pre \
--path user/manifests/application/overlays/production \
--dest-name in-cluster \
--dest-namespace tiktok \
--validate

argocd app sync argocd/e-commence
