#!/bin/bash

set -x
helm repo add bitnami https://charts.bitnami.com/bitnami
helm search repo bitnami/postgresql-ha
helm install postgresql-ha bitnami/postgresql-ha
set +x
