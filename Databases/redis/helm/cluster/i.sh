#!/usr/bin/env bash
# 启用 POSIX 模式并设置严格的错误处理机制
set -o posix errexit -o pipefail

helm repo add bitnami https://charts.bitnami.com/bitnami
helm pull bitnami/redis-cluster
tar -zxvf redis-cluster-*.*.*.tgz

kubectl create secret \
generic redis-password-secret \
--from-literal=redis-password=msdnmm,. \
-n redis-ha

# rm
# kubectl delete secret \
# redis-password-secret \
# -n redis-ha

# TLS
# kubectl create secret generic certificates-tls-secret --from-file=./cert.pem --from-file=./cert.key --from-file=./ca.pem

helm uninstall redis-ha -n redis-ha
cat > values.yaml <<EOF
#password: msdnmm,.
# 使用密码身份验证
usePassword: true
# 将密码挂载为文件而不是环境变量
usePasswordFile: true
# 密码密钥对象的名称（用于密码身份验证）
existingSecret: redis-password-secret

tls:
  enabled: false

metrics:
  enabled: false

service:
  ports:
    redis: 6379
  type: LoadBalancer
#  loadBalancerIP:
#    - 192.168.2.100
#    - 192.168.2.152
#    - 192.168.2.155
#  sessionAffinity: ClientIP

cluster:
  hostMode: false
  # 是否初始化redis
  init: true
  # 这是包括副本在内的节点总数。
  nodes: 3
  # 集群中每个主节点的副本数量
  replicas: 2
  # 配置从 Kubernetes 集群外部访问 Redis® 集群
#  externalAccess:
#    enabled: false
#    service:
#      type: LoadBalancer
#      port: 6379
#      loadBalancerIP:
#        - 192.168.2.100
#        - 192.168.2.152
#        - 192.168.2.155

EOF

# --set password
helm upgrade --install \
redis-ha redis-cluster-*.*.*.tgz \
-f values.yaml \
-n redis-ha \
--create-namespace

kubectl get po,svc -n redis-ha

# uninstall
# helm uninstall redis-ha -n redis-ha

# 添加节点
# helm upgrade --timeout 600s <release> \
# --set "password=${REDIS_PASSWORD} \
# --set cluster.nodes=7 \
# --set cluster.update.addNodes=true \
# --set cluster.update.currentNumberOfNodes=6" \
# --set oci://REGISTRY_NAME/REPOSITORY_NAME/redis-cluster

# Redis&reg; can be accessed on the following DNS names from within your cluster:
#
#     redis-ha-master.redis-ha.svc.cluster.local for read/write operations (port 6379)
#     redis-ha-replicas.redis-ha.svc.cluster.local for read-only operations (port 6379)
#
#
#
# To get your password run:
#
#     export REDIS_PASSWORD=$(kubectl get secret --namespace redis-ha redis-ha -o jsonpath="{.data.redis-password}" | base64 -d)
#
# To connect to your Redis&reg; server:
#
# 1. Run a Redis&reg; pod that you can use as a client:
#
#    kubectl run --namespace redis-ha redis-client --restart='Never'  --env REDIS_PASSWORD=$REDIS_PASSWORD  --image docker.io/bitnami/redis:7.2.5-debian-12-r0 --command -- sleep infinity
#
#    Use the following command to attach to the pod:
#
#    kubectl exec --tty -i redis-client \
#    --namespace redis-ha -- bash
#
# 2. Connect using the Redis&reg; CLI:
#    REDISCLI_AUTH="$REDIS_PASSWORD" redis-cli -h redis-ha-master
#    REDISCLI_AUTH="$REDIS_PASSWORD" redis-cli -h redis-ha-replicas
#
# To connect to your database from outside the cluster execute the following commands:
#
#     kubectl port-forward --namespace redis-ha svc/redis-ha-master 6379:6379 &
#     REDISCLI_AUTH="$REDIS_PASSWORD" redis-cli -h 127.0.0.1 -p 6379
#
# WARNING: There are "resources" sections in the chart not set. Using "resourcesPreset" is not recommended for production. For production installations, please set the following values according to your workload needs:
#   - metrics.resources
#   - replica.resources
#   - master.resources
# +info https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/
