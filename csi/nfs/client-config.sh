#!/bin/sh
set -x

apt install nfs-common -y

export SERVER_HOST="192.168.3.100"

cat >> /etc/fstab << EOF
$SERVER_HOST:/mnt/data  /mnt/data       nfs    defaults 0 0
EOF

mkdir -p /mnt/data

mount -a   #让文件/etc/fstab生效

df -Th /mnt/data
# 用来察看 NFS 分享出来的目录资源
showmount -e $SERVER_HOST

set +x

#sudo gdisk /dev/vdb
#sudo mkfs.ext4 /dev/sdb1
#sudo mount /dev/sdb1 /

