#!/usr/bin/env bash
# 启用 POSIX 模式并设置严格的错误处理机制
set -o posix errexit -o pipefail

mkdir -pv /home/kubernetes/minio
cd /home/kubernetes/minio

# 安装: https://github.com/minio/operator/tree/v6.0.4/helm/operator
# 配置: https://www.minio.org.cn/docs/minio/kubernetes/upstream/reference/operator-chart-values.html

helm search repo minio/tenant
helm pull minio/tenant
tar -zxvf tenant-*.tgz
cd tenant

# 修改values.yaml, 推荐修改pools.servers与pools.size和configSecret
# vi values.yaml

# 全新安装
helm install tenant . \
  --create-namespace  \
  --namespace minio-tenant \
  -f values.yaml

# 更新安装
#helm upgrade tenant . \
#  --namespace minio-tenant \
#  -f values.yaml

kubectl get po -n minio-tenant -owide
kubectl get svc -n minio-tenant

# 获取账户密码
kubectl get secrets -n minio-tenant \
myminio-env-configuration \
-ojsonpath='{.data.config\.env}' | base64 -d

svc_type="NodePort"
#SVC_TYPE="LoadBalancer"
kubectl patch svc myminio-console -n minio-tenant -p '{"spec":{"type":"NodePort"}}'

kubectl get svc/myminio-hl -n minio-tenant -o yaml > myminio-hl-svc.yaml.back
kubectl delete svc myminio-hl -n minio-tenant

cat > myminio-hl-svc.yaml <<EOF
apiVersion: v1
kind: Service
metadata:
  labels:
    v1.min.io/tenant: myminio
  name: myminio-hl
  namespace: minio-tenant
spec:
  ports:
  - name: https-minio
    port: 9000
    protocol: TCP
    targetPort: 9000
  publishNotReadyAddresses: true
  selector:
    v1.min.io/tenant: myminio
  type: $svc_type
EOF
kubectl apply -f myminio-hl-svc.yaml
