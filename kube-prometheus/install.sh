#!/bin/bash

set -x

export DIR_HOME="/home/kubernetes/"
cd $DIR_HOME || exit

git clone --depth 1 https://github.com/prometheus-operator/kube-prometheus.git
cd kube-prometheus || exit

# Create the namespace and CRDs, and then wait for them to be available before creating the remaining resources
# Note that due to some CRD size we are using kubectl server-side apply feature which is generally available since kubernetes 1.22.
# If you are using previous kubernetes versions this feature may not be available and you would need to use kubectl create instead.
kubectl apply --server-side -f manifests/setup
kubectl wait \
	--for condition=Established \
	--all CustomResourceDefinition \
	--namespace=monitoring
kubectl apply -f manifests/

set +x

kubectl patch svc prometheus-k8s -n monitoring -p '{"spec":{"type":"LoadBalancer"}}'
kubectl patch svc grafana -n monitoring -p '{"spec":{"type":"LoadBalancer"}}'
