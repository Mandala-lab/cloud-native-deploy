#!/usr/bin/env bash
# 启用 POSIX 模式并设置严格的错误处理机制
set -o posix errexit -o pipefail

# https://krew.sigs.k8s.io/docs/user-guide/setup/install/

cat >install.sh <<EOF
(
  set -x; cd "$(mktemp -d)" &&
  OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
  KREW="krew-${OS}_${ARCH}" &&
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
  tar zxvf "${KREW}.tar.gz" &&
  ./"${KREW}" install krew
)
EOF

chmod +x ./install.sh && ./install.sh

cat >> ~/.bashrc <<EOF
# krew
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
EOF

source ~/.bashrc
kubectl krew
