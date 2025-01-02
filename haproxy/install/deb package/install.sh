#!/usr/bin/env bash
# 启用 POSIX 模式并设置严格的错误处理机制
set -o posix errexit -o pipefail

# 文档: https://haproxy.debian.net/#distribution=Ubuntu&release=noble&version=3.0

apt-get install --no-install-recommends software-properties-common
add-apt-repository ppa:vbernat/haproxy-3.0

apt-get install haproxy=3.0.\*
