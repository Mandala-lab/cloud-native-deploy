#!/usr/bin/env bash
# 启用 POSIX 模式并设置严格的错误处理机制
set -o posix errexit -o pipefail

# 创建 Issuer
# https://todoit.tech/k8s/cert/#%E5%88%9B%E5%BB%BA-issuer
# et’s Encrypt 利用 ACME (Automated Certificate Management Environment) 协议校验域名的归属，校验成功后可以自动颁发免费证书。
# 免费证书有效期只有 90 天，需在到期前再校验一次实现续期。
# 使用 cert-manager 可以自动续期，即实现永久使用免费证书。
# 校验域名归属的两种方式分别是 HTTP-01 和 DNS-01，校验原理详情可参见 Let's Encrypt 的运作方式。
# DNS-01 校验支持泛域名， 但是是不同 DNS 提供商的配置方式不同，DNS 提供商过多而 cert-manager 的 Issuer 不能全部支持。部分可以通过部署实现 cert-manager 的 Webhook 服务来扩展 Issuer 进行支持。例如阿里 DNS 就是通过 Webhook 的方式进行支持。

export CLOUDFLARE_EMAIL="xiconz@qq.com"
export CLOUDFLARE_TOKEN="JetH3-LDZZwk2mJ0kiPpE_FRCclEzkcot3gX4swd"

# 1. cloudflare 添加 DNS 记录. 映射到对应的服务器
# 2. 前往个人资料 -> API 令牌， 使用编辑区域 DNS 模版， 创建一个 token。
# 3. 测试
curl -X GET "https://api.cloudflare.com/client/v4/user/tokens/verify" \
     -H "Authorization: Bearer ${CLOUDFLARE_TOKEN}" \
     -H "Content-Type:application/json"

# 将得到的 token，保存到 .env 文件中，并将 .env.prod 添加到 .gitignore 中

cat > .env.prod <<EOF
api-token=${CLOUDFLARE_TOKEN}
EOF

# 使用 Kustomize 来管理该 token。
cat > kustomization.yaml <<EOF
resources:
  - letsencrypt-issuer.yaml
namespace: cert-manager
secretGenerator:
  - name: cloudflare-api-token-secret
    envs:
      - .env.prod # token 就存放在这里，这个文件不会被提交到 Git 仓库中
generatorOptions:
  disableNameSuffixHash: true
EOF

# 使用 Kustomize 来生成一个名为 cloudflare-api-token-secret 的 Secret, 该 Secret 被下面的清单使用

cat >letsencrypt-issuer.yaml<<EOF
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-dns01
spec:
  acme:
    privateKeySecretRef:
      name: letsencrypt-dns01
    server: https://acme-v02.api.letsencrypt.org/directory
    solvers:
    - dns01:
        cloudflare:
          email: ${CLOUDFLARE_EMAIL} # 替换成你的 cloudflare 邮箱账号
          apiTokenSecretRef:
            key: api-token
            name: cloudflare-api-token-secret # 引用保存 cloudflare 认证信息的 Secret
EOF

# 检查
kubectl kustomize ./

# 创建 issuer
kubectl apply -k ./

# 查看 Let't Encrypt 注册状态
kubectl get clusterissuer
kubectl describe clusterissuer letsencrypt-dns01
