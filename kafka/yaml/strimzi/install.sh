#!/usr/bin/env bash
# 启用 POSIX 模式并设置严格的错误处理机制
set -o posix errexit -o pipefail

mkdir -p /home/kubernetes/kafka
cd /home/kubernetes/kafka

# 入门: https://strimzi.io/quickstarts/

kubectl create namespace kafka
# 单机版kafka, 它声明了100g的pv, 需要节点有sc的存储支持
# 更多的kafka安装:https://github.com/strimzi/strimzi-kafka-operator/tree/0.43.0/examples/kafka

# 应用 Strimzi 安装文件，包括 ClusterRoles、ClusterRoleBindings 和一些自定义资源定义 （CRD）。
# CRD 定义用于自定义资源（CR，例如 Kafka、KafkaTopic 等）的架构，您将用于管理 Kafka 集群、主题和用户
wget 'https://strimzi.io/install/latest?namespace=kafka'
mv 'latest?namespace=kafka' kafka.yml
kubectl create -f kafka.yml -n kafka
kubectl get pod -n kafka

# 创建 Apache Kafka 集群
# 创建新的 Kafka 自定义资源以获取单节点 Apache Kafka 集群：
# Apply the `Kafka` Cluster CR file

#wget https://strimzi.io/examples/latest/kafka/kraft/kafka-single-node.yaml
cat > lb-10Gi-kafka-single-node.yaml <<EOF
apiVersion: kafka.strimzi.io/v1beta2
kind: KafkaNodePool
metadata:
  name: dual-role
  labels:
    strimzi.io/cluster: my-cluster
spec:
  replicas: 1
  roles:
    - controller
    - broker
  storage:
    type: jbod
    volumes:
      - id: 0
        type: persistent-claim
        size: 10Gi
        deleteClaim: false
        kraftMetadata: shared
---

apiVersion: kafka.strimzi.io/v1beta2
kind: Kafka
metadata:
  name: my-cluster
  annotations:
    strimzi.io/node-pools: enabled
    strimzi.io/kraft: enabled
spec:
  kafka:
    version: 3.9.0
    metadataVersion: 3.9-IV0
    listeners:
      - name: plain
        port: 9092
        type: loadbalancer
        tls: false
      - name: tls
        port: 9093
        type: internal
        tls: true
    config:
      offsets.topic.replication.factor: 1
      transaction.state.log.replication.factor: 1
      transaction.state.log.min.isr: 1
      default.replication.factor: 1
      min.insync.replicas: 1
  entityOperator:
    topicOperator: {}
    userOperator: {}
EOF

#kubectl apply -f kafka-single-node.yaml -n kafka
kubectl apply -f lb-10Gi-kafka-single-node.yaml -n kafka
kubectl wait kafka/my-cluster --for=condition=Ready --timeout=300s -n kafka

# 发送和接收消息
# 在集群运行的情况下，运行一个简单的生产者向 Kafka 主题发送消息（该主题是自动创建的）：
# 测试发送
kubectl -n kafka run kafka-producer -ti --image=quay.io/strimzi/kafka:0.43.0-kafka-3.8.0 --rm=true --restart=Never -- bin/kafka-console-producer.sh --bootstrap-server my-cluster-kafka-bootstrap:9092 --topic my-topic

# 测试接收
# 要在不同的终端中接收它们，请运行：
kubectl -n kafka run kafka-consumer -ti --image=quay.io/strimzi/kafka:0.43.0-kafka-3.8.0 --rm=true --restart=Never -- bin/kafka-console-consumer.sh --bootstrap-server my-cluster-kafka-bootstrap:9092 --topic my-topic --from-beginning

# 如果要转成外部的 LoadBalancer 或者 NodePort, 把listeners的type为internal改成loadbalancer或 nodeport
