#!/usr/bin/env bash
# 启用 POSIX 模式并设置严格的错误处理机制
set -o posix errexit -o pipefail

# https://docs.citusdata.com/en/v12.1/get_started/tutorial_multi_tenant.html#multi-tenant-tutorial
docker run -d \
  --name citus \
  -p 5432:5432 \
  -e POSTGRES_PASSWORD=mypass \
  citusdata/citus:12.1
