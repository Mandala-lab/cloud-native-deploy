#!/usr/bin/env bash
# 启用 POSIX 模式并设置严格的错误处理机制
set -o posix errexit -o pipefail

SAVE_PATH="/mnt/data/k8s/postgres"
mkdir -p ${SAVE_PATH}
chmod 755 ${SAVE_PATH}

cat <<EOF> postgres-pv.yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: postgresql-pvc-claim
spec:
  capacity:
    storage: 10Gi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: nfs-csi
  nfs:
    path: ${SAVE_PATH}  # NFS共享的路径
    server: 192.168.3.100 # NFS服务器地址
EOF

kubectl apply -f postgres-pv.yaml -n postgres
