#!/usr/bin/env bash

# https://purelb.gitlab.io/docs/install/install/

# 开启strictARP
kubectl get configmap kube-proxy -n kube-system -o yaml > kube-proxy-cm.yaml
sed -i 's/strictARP: false/strictARP: true/g' kube-proxy-cm.yaml
kubectl apply -f kube-proxy-cm.yaml
kubectl rollout restart daemonset kube-proxy -n kube-system

cat <<EOF | sudo tee /etc/sysctl.d/k8s_arp.conf
net.ipv4.conf.all.arp_ignore=1
net.ipv4.conf.all.arp_announce=2

EOF
sudo sysctl --system

# ARP, 适用于云下没有LoadBalancer支持的集群, 可选, 与purelb使用
cat <<EOF | sudo tee /etc/sysctl.d/00-k8s-arp.conf
net.ipv4.conf.default.arp_announce = 2
net.ipv4.conf.lo.arp_announce = 2
net.ipv4.conf.all.arp_ignore = 1
net.ipv4.conf.all.arp_announce = 2
net.bridge.bridge-nf-call-arptables = 1
EOF
sysctl -p /etc/sysctl.d/00-k8s-arp.conf
cat /etc/sysctl.d/00-k8s-arp.conf
