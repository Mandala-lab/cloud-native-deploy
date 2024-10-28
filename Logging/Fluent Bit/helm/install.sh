#!/usr/bin/env bash
set -o errexit -o pipefail

alias k=kubectl

export ns="efk"

# Doc: https://docs.fluentbit.io/manual/installation/kubernetes#installing-with-helm-chart

helm repo add fluent https://fluent.github.io/helm-charts
helm search repo fluent

# --untar: 这是一个选项，指示 Helm 在下载后解压 chart
helm pull fluent/fluent-bit --untar

# 增加系统文件打开数的限制, 每个节点都要设置
# 通过修改系统的 ulimit 参数来增加系统允许打开的文件数量的限制
cp /etc/security/limits.conf{,.back}
cat >> /etc/security/limits.conf <<EOF
* soft nofile 65535
* hard nofile 65535
* soft noproc 65535
* hard noproc 65535
EOF

cat >> /etc/profile <<EOF
ulimit -n 65535
EOF
source /etc/profile

cat /etc/sysctl.conf | grep "fs.file-max"
cat /etc/sysctl.conf | grep "vm.swappiness"
cat /etc/sysctl.conf | grep "net.core.somaxconn"

cp /etc/sysctl.conf{,.back}
cat >> /etc/sysctl.conf <<EOF
# max open files，系统级限制，不能小于 ulimit 中设置的上限
fs.file-max = 65535
# 增大最大连接数
net.core.somaxconn = 10000
# 只要还有内存的情况下，就不使用 swap 交换空间
vm.swappiness = 0
vm.max_map_count=262144
EOF
sysctl -p

cp /etc/systemd/system.conf{,.back}
cat >> /etc/systemd/system.conf <<EOF
DefaultLimitNOFILE=655360
DefaultLimitNPROC=655360
EOF


# 重启
# reboot

cd fluent-bit || exit

k create ns ${ns}

# 安装
helm install fluent-bit -n ${ns} . -f values.yaml

# 卸载
# helm uninstall fluent-bit -n efk

kubectl get pod -n ${ns} -o wide

cat > fluentd-conf.yaml <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: fluentd-conf
  namespace: ${ns}
data:
  fluent.conf : |-
    <source>
      @type forward
      port 8888
      bind 0.0.0.0
    </source>

    <match *.service>
      @type elasticsearch
      host elasticsearch-es-http.elk.svc
      port 9200
      default_elasticsearch_version 8
      user elastic
      scheme https
      password 78HOWor95Iiot076O59xq2Am
      ssl_verify false
      data_stream_name logs-${tag}-fluentd
      include_timestamp true
      <buffer>
        @type file
        flush_interval 5s
        path /fluentd/buf/service-logs.*
      </buffer>
    </match>

    <match kube.**>
      @type elasticsearch
      host elasticsearch-es-http.elk.svc
      port 9200
      default_elasticsearch_version 8
      user elastic
      scheme https
      password 78HOWor95Iiot076O59xq2Am
      ssl_verify false
      data_stream_name logs-pod-fluentd
      include_timestamp true
      <buffer>
        @type file
        flush_interval 5s
        path /fluentd/buf/pod-logs.*
      </buffer>
    </match>
EOF

cat > fluentd-svc.yaml <<EOF
      apiVersion: v1
      kind: Service
      metadata:
        name: fluentd
        namespace: ${ns}
      spec:
        selector:
          app: fluentd
        ports:
        - port: 8888
          targetPort: 8888
EOF

cat > fluentd.yaml <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: fluentd
  namespace: ${ns}
spec:
  replicas: 3
  selector:
    matchLabels:
      app: fluentd
  template:
    metadata:
      labels:
        app: fluentd
    spec:
      containers:
      - name: fluentd
        #image: harbor.local.com/elk/fluentd:v1.16.2
        resources:
          limits:
            memory: "128Mi"
            cpu: "500m"
        ports:
        - containerPort: 8888
        volumeMounts:
          - name: fluentd-conf
            mountPath: /fluentd/etc/fluent.conf
            subPath: fluent.conf
      volumes:
        - name: fluentd-conf
          configMap:
            name: fluentd-conf
EOF

kubectl apply -f .

