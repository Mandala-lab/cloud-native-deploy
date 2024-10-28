#!/usr/bin/env bash
# 启用 POSIX 模式并设置严格的错误处理机制
set -o posix errexit -o pipefail

mkdir -p /home/kubernetes/argocd
cd /home/kubernetes/argocd

# CLI登录
# $lb_ip:port: ip与端口
# --insecure: 忽略TLS验证
# --grpc-web
#lb_ip=$(kubectl get service example-argocd-server -o=jsonpath='{.status.loadBalancer.ingress[0].ip}' -n $ns)
lb_ip="argocd.example.com:31258"
argocd login \
$lb_ip \
--username admin \
--password $pwd \
--insecure

# 修改密码
argocd account update-password

# 注册集群以将应用程序部署到该集群(可选, 推荐)
# 将 ServiceAccount （argocd-manager） 安装到该 kubectl 上下文的 kube-system 命名空间中，
# 并将服务帐户绑定到管理员级别的 ClusterRole。Argo CD 使用此服务帐户令牌来执行其管理任务（即部署/监控）。
CLUSTER=$(kubectl config get-contexts -o name)
echo "$CLUSTER"
argocd cluster add "$CLUSTER"

# 创建项目
argocd proj create frontend

# 删除
# argocd proj delete frontend

# 添加仓库到项目
#  argocd proj add-source <PROJECT> <REPO>
argocd proj add-source frontend https://gitlab.com/lookeke/full-stack-engineering.git

# 删除
# argocd proj remove-source <PROJECT> <REPO>

# 排除项目
# argocd proj add-source <PROJECT> !<REPO>

# 添加集群与命名空间
# argocd proj add-destination <PROJECT> <CLUSTER>,<NAMESPACE>
# argocd proj remove-destination <PROJECT> <CLUSTER>,<NAMESPACE>
argocd proj add-destination frontend https://192.168.2.160:6443 frontend

# 创建仓库秘钥
cat > gitlab-secret.yml <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: argocd-example-apps
  labels:
    argocd.argoproj.io/secret-type: repository
type: Opaque
stringData:
  # Project scoped
  project: my-project1
  name: argocd-example-apps
  url: https://github.com/argoproj/argocd-example-apps.git
  username: ****
  password: ****
EOF

# 创建APP
argocd app create frontend \
--project frontend \
--repo https://gitlab.com/lookeke/full-stack-engineering.git \
--path frontend/ci \
--dest-server https://kubernetes.default.svc \
--dest-namespace frontend \
--validate

# 删除
#argocd app delete guestbook

# 列出用户
argocd account list

# 获取特定用户信息
argocd account get --account <username>

# 生成token
argocd account generate-token --account admin
# token:
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJhcmdvY2QiLCJzdWIiOiJhZG1pbjphcGlLZXkiLCJuYmYiOjE3MTQ5Mjg0MTYsImlhdCI6MTcxNDkyODQxNiwianRpIjoiYzJiNTAzYzAtNmI0Mi00MzljLTliYTQtNjk1M2E5ZjU5OGZiIn0.t1AjKKWYNBshV5oGFYXOQCfWX-S_u2hX3NcHS3WPMrM

# RBAC权限:
# p, role:lx, applications, *, */*, allow
# p, role:lx, clusters, *, *, allow
# p, role:lx, repositories, *, */*, allow
# p, role:lx, projects, *, */*, allow
# p, role:lx, projects, sync, */*, allow
# p, role:lx, logs, *, */*, allow
# p, role:lx, exec, *, */*, allow
# p, role:admin, applications, *, */*, allow
# p, role:admin, clusters, *, *, allow
# p, role:admin, repositories, *, */*, allow
# p, role:admin, projects, sync, */*, allow
# p, role:admin, logs, *, */*, allow
# p, role:admin, exec, *, */*, allow
# g, admin, role:admin
# g, admin, role:lx
# policy.default: role:admin

# 验证RBAC权限:
# 验证包含rbac的yml或csv文件
argocd admin settings rbac validate --policy-file argocd-rbac-cm.yml
# 命名空间:
argocd admin settings rbac validate --namespace argocd

# 测试策略
# https://argo-cd.readthedocs.io/en/stable/operator-manual/rbac/#testing-a-policy
argocd admin settings rbac can role:org-admin get applications --policy-file argocd-rbac-cm.yaml

