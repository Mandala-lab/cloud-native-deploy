#!/usr/bin/env bash
# 启用 POSIX 模式并设置严格的错误处理机制
set -o posix errexit -o pipefail

# https://www.cockroachlabs.com/docs/v24.3/orchestrate-a-local-cluster-with-kubernetes?#step-3-use-the-built-in-sql-client

# 注意, 默认的示例文件是每个节点 60G, 三个节点
