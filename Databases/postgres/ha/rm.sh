#!/bin/bash

set -x
k get pvc -n postgresql

kubectl delete -n postgresql pvc/data-pg-ha-postgresql-ha-postgresql-0
kubectl delete -n postgresql pvc/data-pg-ha-postgresql-ha-postgresql-1
kubectl delete -n postgresql pvc/data-pg-ha-postgresql-ha-postgresql-2
kubectl delete -n postgresql pvc/data-postgresql-ha-postgresql-0
kubectl delete -n postgresql pvc/data-postgresql-ha-postgresql-1
kubectl delete -n postgresql pvc/data-postgresql-ha-postgresql-2

k get pvc -n postgresql
set +x
