#!/usr/bin/env bash
# 启用 POSIX 模式并设置严格的错误处理机制
set -o posix errexit -o pipefail

mkdir -p /home/kubernetes/casdoor
cd /home/kubernetes/casdoor

kubectl create ns casdoor

cat > app.conf <<EOF
appname = casdoor
httpport = 8000
runmode = dev
copyrequestbody = true
driverName = postgres
dataSourceName = "user=root password=msdnmm host=localhost port=5432 sslmode=disable dbname=casdoor"
dbName = casdoor
tableNamePrefix =
showSql = false
redisEndpoint =
defaultStorageProvider =
isCloudIntranet = false
authState = "casdoor"
socks5Proxy = "127.0.0.1:10808"
verificationCodeTimeout = 10
initScore = 0
logPostOnly = true
isUsernameLowered = false
origin =
originFrontend =
staticBaseUrl = "https://cdn.casbin.org"
isDemoMode = false
batchSize = 100
enableGzip = true
ldapServerPort = 389
radiusServerPort = 1812
radiusSecret = "secret"
quota = {"organization": -1, "user": -1, "application": -1, "provider": -1}
logConfig = {"filename": "logs/casdoor.log", "maxdays":99999, "perm":"0770"}
initDataFile = "./init_data.json"
frontendBaseDir = "../casdoor"
EOF

kubectl get cm -n casdoor
kubectl create cm app.conf --from-file app.conf -n casdoor
kubectl apply -f casdoor.yaml -n casdoor
