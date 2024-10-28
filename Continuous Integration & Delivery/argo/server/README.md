## 说明

### api服务器

一般指k8s集群，使用svc或者ingress，istio，nodeport等方式暴露出去
功能：
app管理和状态查看
调用应用程序操作（例如同步、回滚、用户定义的操作）
存储库和集群凭据管理（存储为 K8s secret）
对外部身份提供程序进行身份验证和身份验证委派
RBAC 授权

### Git webhook事件的侦听/转发

存储库服务器
一般指gitlab
功能：
生成和管理k8s集群所需要的资源清单比如
仓库地址
版本信息（提交、标记、分支）
应用程序地址
模板设置：参数、helm变量等

### 控制器

一般是opretor属于k8s集群的概念，用来对某资源对象做持续监控并使其达到预期状态

### 文件

argocd-cm
kubectl get cm -n argocd-cm -oyaml
定义了argocd的通用配置

my-private-repo / istio-helm-repo / private-helm-repo / private-repo
定义了使用的仓库的信息配置，属于secret

argoproj-https-creds / argoproj-ssh-creds / github-creds / github-enterprise-creds
secret 存储了仓库的ssh秘钥等凭据信息

Argocd-cmd-params-cm
存储了env变量信息

# argocd-secret

存储了argocd所用的证书，比如签名证书，webhook，用户账号密码等

# Argocd-RBAC-CM

存储了rbac配置

# argocd-tls-certs-cm

存储了tls通信所用的文件信息

# argocd-ssh-known-hosts-cm

存储了git存储仓库的信息
