#!/usr/bin/env bash
# 启用 POSIX 模式并设置严格的错误处理机制
set -o posix errexit -o pipefail

cat <<EOF> postgres-pvc.yaml
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: postgresql-pvc-claim
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: nfs-csi
  resources:
    requests:
      storage: 4Gi

EOF

kubectl apply -f postgres-pvc.yaml
