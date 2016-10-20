#!/bin/bash

#PREFIX=openshift/origin-
PREFIX=registry.ops.openshift.com/openshift3/
#PREFIX=brew-pulp-docker01.web.prod.ext.phx2.redhat.com:8888/openshift3/
#PREFIX=brew-pulp-docker01.web.qa.ext.phx1.redhat.com:8888/openshift3/

#VERSION=latest
VERSION=3.3.1

PROJECT=
SUBDOMAIN=
MASTER=
PORT=

#oc new-project $PROJECT

oc project $PROJECT

oc secrets new logging-deployer nothing=/dev/null

oc new-app logging-deployer-account-template

oadm policy add-cluster-role-to-user oauth-editor system:serviceaccount:logging:logging-deployer

oadm policy add-cluster-role-to-user cluster-reader system:serviceaccount:logging:aggregated-logging-fluentd

oadm policy add-scc-to-user privileged system:serviceaccount:logging:aggregated-logging-fluentd

oc create configmap logging-deployer \
--from-literal kibana-hostname=kibana.$SUBDOMAIN \
--from-literal public-master-url=https://$MASTER:$PORT \
--from-literal es-cluster-size=1 \
--from-literal es-instance-ram=1G \
--from-literal es-pvc-size= \
--from-literal es-pvc-prefix= \
--from-literal es-pvc-dynamic=false \
--from-literal storage-group= \
--from-literal use-journal=true \
--from-literal enable-ops-cluster=false \
--from-literal kibana-ops-hostname=kibana-ops.$SUBDOMAIN

#oc label node -l registry=enabled logging-infra-fluentd=true --overwrite

# install, uninstall, reinstall, upgrade, migrate, start, stop. migrate
oc new-app logging-deployer-template -p IMAGE_PREFIX=$PREFIX,IMAGE_VERSION=$VERSION,MODE=install
 
