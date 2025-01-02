#!/usr/bin/env bash
set -o errexit -o pipefail

nohup sh -c \
'JENKINS_HOME="/mnt/data/158-jenkins" \
java -jar jenkins.war --httpPort=7081' \
&
