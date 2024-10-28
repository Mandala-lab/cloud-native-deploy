#!/usr/bin/env bash

# https://purelb.gitlab.io/docs/install/config/
# https://juejin.cn/editor/drafts/7322305256172175400

# kubectl edit -n purelb lbnodeagent

export IP_POOL='192.168.3.170-192.168.3.199'
export SUBNET='192.168.3.170/25'


cat > purelb-l2.yaml <<EOF
apiVersion: purelb.io/v1
kind: ServiceGroup
metadata:
  name: layer2-ippool
  namespace: purelb
spec:
  local:
    v4pool:
      subnet: $SUBNET
      pool: $IP_POOL
      aggregation: default
EOF

cat purelb-l2.yaml
