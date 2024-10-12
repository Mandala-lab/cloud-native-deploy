#!/bin/bash

set -x

helm uninstall consul -n consul

set +x
