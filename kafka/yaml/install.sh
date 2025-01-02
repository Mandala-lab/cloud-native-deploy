#!/bin/bash
set -x

kubectl create kafka-ui
kubectl apply -f kafka-ui.yaml

set +x
