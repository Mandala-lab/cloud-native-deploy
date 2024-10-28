#!/usr/bin/env bash

helm repo add elastic https://helm.elastic.co
helm repo update

# CRD
wget https://download.elastic.co/downloads/eck/2.9.0/crds.yaml
kubectl apply -f crds.yaml

# Operator
wget https://download.elastic.co/downloads/eck/2.9.0/operator.yaml
kubectl apply -f operator.yaml
