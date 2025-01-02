#!/bin/bash

set -x
export PG_DIR="/home/kubernetes/postgres"
export VERSION="12.3.2"

cd $PG_DIR || exit

helm repo add bitnami https://charts.bitnami.com/bitnami
helm search repo bitnami/postgresql-ha --version $VERSION
helm pull bitnami/postgresql-ha

tar -xvf postgresql-ha-$VERSION.tgz
cd postgresql-ha || exit

k create ns postgresql
helm install postgresql-ha ./ -n postgresql --values ./pg.yaml

# 给pg的PVC权限, 如果你的配置是云服务器, 可能不需要此操作
# /home/mnt/data/ 是pg的pvc所挂载的卷名的实际地址
chmod -R 777 /home/mnt/data/

watch kubectl get po,svc -n postgresql

echo "user: postgres"
export POSTGRES_PASSWORD=$(kubectl get secret --namespace postgresql postgresql-ha-postgresql -o jsonpath="{.data.password}" | base64 -d)
echo $POSTGRES_PASSWORD

#To get the password for "repmgr" run:
#    export REPMGR_PASSWORD=$(kubectl get secret --namespace postgresql postgresql-ha-postgresql -o jsonpath="{.data.repmgr-password}" | base64 -d)
#To connect to your database run the following command:
#    kubectl run postgresql-ha-client --rm --tty -i --restart='Never' --namespace postgresql --image docker.io/bitnami/postgresql-repmgr:16.1.0-debian-11-r21 --env="PGPASSWORD=$POSTGRES_PASSWORD"  \
#        --command -- psql -h postgresql-ha-pgpool -p 5432 -U postgres -d postgres
#To connect to your database from outside the cluster execute the following commands:
#  NOTE: It may take a few minutes for the LoadBalancer IP to be available.
#        Watch the status with: 'kubectl get svc --namespace postgresql -w postgresql-ha-pgpool
#    export SERVICE_IP=$(kubectl get svc --namespace postgresql postgresql-ha-pgpool --template "{{ range (index .status.loadBalancer.ingress 0) }}{{ . }}{{ end }}")
#    PGPASSWORD="$POSTGRES_PASSWORD" psql -h $SERVICE_IP -p 5432  -U postgres -d postgres

set +x

