#!/bin/bash

set -x

mkdir -p /home/kubernetes/harbor
cd /home/kubernetes/harbor || exit

helm repo add harbor https://helm.goharbor.io
helm repo list
# 列出最新版本的包
helm search repo harbor -l |  grep harbor/harbor  | head  -4

# 拉取到本地
helm pull harbor/harbor
ls harbor-*.tgz

# 解压
tar zxvf harbor-*.tgz

# 进入到harbor目录
ll harbor

# externalURL修改为对应的Addr

cat > harbor-values.yaml <<EOF
# The external URL for Harbor core service. It is used to
# 1) populate the docker/helm commands showed on portal
# 2) populate the token service URL returned to docker client
#
# Format: protocol://domain[:port]. Usually:
# 1) if "expose.type" is "ingress", the "domain" should be
# the value of "expose.ingress.hosts.core"
# 2) if "expose.type" is "clusterIP", the "domain" should be
# the value of "expose.clusterIP.name"
# 3) if "expose.type" is "nodePort", the "domain" should be
# the IP address of k8s node
#
# If Harbor is deployed behind the proxy, set it as the URL of proxy
externalURL: harbor.localhost.com
expose:
  # Set how to expose the service. Set the type as "ingress", "clusterIP", "nodePort" or "loadBalancer"
  # and fill the information in the corresponding section
  type: loadBalancer
  tls:
    # Enable TLS or not.
    # Delete the "ssl-redirect" annotations in "expose.ingress.annotations" when TLS is disabled and "expose.type" is "ingress"
    # Note: if the "expose.type" is "ingress" and TLS is disabled,
    # the port must be included in the command when pulling/pushing images.
    # Refer to https://github.com/goharbor/harbor/issues/5291 for details.
    enabled: true
    # The source of the tls certificate. Set as "auto", "secret"
    # or "none" and fill the information in the corresponding section
    # 1) auto: generate the tls certificate automatically
    # 2) secret: read the tls certificate from the specified secret.
    # The tls certificate can be generated manually or by cert manager
    # 3) none: configure no tls certificate for the ingress. If the default
    # tls certificate is configured in the ingress controller, choose this option
    certSource: auto
    auto:
      # The common name used to generate the certificate, it's necessary
      # when the type isn't "ingress"
      commonName: "harbor"
    secret:
      # The name of secret which contains keys named:
      # "tls.crt" - the certificate
      # "tls.key" - the private key
      secretName: ""
  loadBalancer:
    # The name of LoadBalancer service
    name: harbor
    # Set the IP if the LoadBalancer supports assigning IP
    IP: ""
    ports:
      # The service port Harbor listens on when serving HTTP
      httpPort: 80
      # The service port Harbor listens on when serving HTTPS
      httpsPort: 443
    # Annotations on the loadBalancer service
    annotations: {}
    # loadBalancer-specific labels
    labels: {}
    sourceRanges: []
persistence:
  enabled: true
  resourcePolicy: "keep"
  persistentVolumeClaim:
    registry:
      # Use the existing PVC which must be created manually before bound,
      # and specify the "subPath" if the PVC is shared with other components
      existingClaim: ""
      # Specify the "storageClass" used to provision the volume. Or the default
      # StorageClass will be used (the default).
      # Set it to "-" to disable dynamic provisioning
      storageClass: ""
      subPath: ""
      accessMode: ReadWriteOnce
      size: 5Gi
      annotations: {}
database:
  # if external database is used, set "type" to "external"
  # and fill the connection information in "external" section
  type: external
  external:
    host: "192.168.3.121"
    port: "5432"
    username: "postgres"
    password: "postgres"
    coreDatabase: "harbor"
    # if using existing secret, the key must be "password"
    existingSecret: ""
    # "disable" - No SSL
    # "require" - Always SSL (skip verification)
    # "verify-ca" - Always SSL (verify that the certificate presented by the
    # server was signed by a trusted CA)
    # "verify-full" - Always SSL (verify that the certification presented by the
    # server was signed by a trusted CA and the server host name matches the one
    # in the certificate)
    sslmode: "disable"
redis:
  # if external Redis is used, set "type" to "external"
  # and fill the connection information in "external" section
  type: external
  external:
    # support redis, redis+sentinel
    # addr for redis: <host_redis>:<port_redis>
    # addr for redis+sentinel: <host_sentinel1>:<port_sentinel1>,<host_sentinel2>:<port_sentinel2>,<host_sentinel3>:<port_sentinel3>
    addr: "localhost:6379"
    # The name of the set of Redis instances to monitor, it must be set to support redis+sentinel
    sentinelMasterSet: ""
    # The "coreDatabaseIndex" must be "0" as the library Harbor
    # used doesn't support configuring it
    # harborDatabaseIndex defaults to "0", but it can be configured to "6", this config is optional
    # cacheLayerDatabaseIndex defaults to "0", but it can be configured to "7", this config is optional
    coreDatabaseIndex: "0"
    jobserviceDatabaseIndex: "1"
    registryDatabaseIndex: "2"
    trivyAdapterIndex: "5"
    # harborDatabaseIndex: "6"
    # cacheLayerDatabaseIndex: "7"
    # username field can be an empty string, and it will be authenticated against the default user
    username: "default"
    password: "msdnmm"
    # If using existingSecret, the key must be REDIS_PASSWORD
    existingSecret: ""
trivy:
  # enabled the flag to enable Trivy scanner
  enabled: true
trace:
  enabled: true
  # trace provider: jaeger or otel
  # jaeger should be 1.26+
  provider: jaeger
  # set sample_rate to 1 if you wanna sampling 100% of trace data; set 0.5 if you wanna sampling 50% of trace data, and so forth
  sample_rate: 1
  # namespace used to differentiate different harbor services
  # namespace:
  # attributes is a key value dict contains user defined attributes used to initialize trace provider
  # attributes:
  #   application: harbor
  jaeger:
    # jaeger supports two modes:
    #   collector mode(uncomment endpoint and uncomment username, password if needed)
    #   agent mode(uncomment agent_host and agent_port)
    endpoint: http://hostname:14268/api/traces
    # username:
    # password:
    # agent_host: hostname
    # export trace data by jaeger.thrift in compact mode
    # agent_port: 6831
  otel:
    endpoint: hostname:4318
    url_path: /v1/traces
    compression: false
    insecure: true
    # timeout is in seconds
    timeout: 10
EOF

helm install harbor ./harbor -f harbor-values.yaml \
  -n harbor \
  --create-namespace \
  --dry-run | grep externalURL

echo "harbor.localhost.com" | tee -a /etc/hosts
cat /etc/hosts

kubectl get po,svc -n harbor -owide

set +x
