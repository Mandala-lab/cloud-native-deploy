#!/usr/bin/env bash
set -o errexit -o pipefail

# 本人集群环境需要手动创建PV, 这里使用的是nfs-csi, 根据你的实际情况选择
cat > master_pv.yaml <<EOF
apiVersion: v1
kind: PersistentVolume
metadata:
  namespace: es
  name: elasticsearch-data-elasticsearch-es-master-0
spec:
  capacity:
    storage: 10Gi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: nfs-csi
  nfs:
    path: /mnt/data/160/elasticsearch/data/elasticsearch/es/master/master1  # NFS共享的路径
    server: 192.168.2.160  # NFS服务器地址
EOF

cat > host_0_pv.yaml <<EOF
apiVersion: v1
kind: PersistentVolume
metadata:
  namespace: es
  name: elasticsearch-data-elasticsearch-es-hot1-0
spec:
  capacity:
    storage: 100Gi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: nfs-csi
  nfs:
    path: /mnt/data/160/elasticsearch/data/elasticsearch/es/host/host0  # NFS共享的路径
    server: 192.168.2.160  # NFS服务器地址
EOF

cat > host_1_pv.yaml <<EOF
apiVersion: v1
kind: PersistentVolume
metadata:
  namespace: es
  name: elasticsearch-data-elasticsearch-es-hot1-1
spec:
  capacity:
    storage: 100Gi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: nfs-csi
  nfs:
    path: /mnt/data/160/elasticsearch/data/elasticsearch/es/host/host1  # NFS共享的路径
    server: 192.168.2.160  # NFS服务器地址
EOF

kubectl apply -f master_pv.yaml
kubectl apply -f host_0_pv.yaml
kubectl apply -f host_1_pv.yaml
