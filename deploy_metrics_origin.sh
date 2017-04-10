#!/bin/bash

PREFIX=docker.io/openshift/origin-
PROJECT=openshift-infra
# grep subd /openshift.local.config/master/master-config.yaml
SUBDOMAIN=
VERSOIN=latets

oc project ${PROJECT}

oc create serviceaccount metrics-deployer

oadm policy add-cluster-role-to-user cluster-reader system:serviceaccount:openshift-infra:heapster

oc policy add-role-to-user edit system:serviceaccount:openshift-infra:metrics-deployer

oc secrets new metrics-deployer nothing=/dev/null

oadm policy add-role-to-user view system:serviceaccount:openshift-infra:hawkular -n openshift-infra

curl https://raw.githubusercontent.com/openshift/origin-metrics/master/metrics.yaml -o metrics.yaml

oc new-app -f metrics.yaml --as=system:serviceaccount:openshift-infra:metrics-deployer \
-p IMAGE_PREFIX=${PREFIX} \
-p IMAGE_VERSION=$VERSOIN \
-p HAWKULAR_METRICS_HOSTNAME=hawkular-metrics.${SUBDOMAIN} \
-p MODE=deploy \
-p USE_PERSISTENT_STORAGE=false \
-p DYNAMICALLY_PROVISION_STORAGE=false \
-p USER_WRITE_ACCESS=false \
-p CASSANDRA_NODES=1 \
-p CASSANDRA_PV_SIZE=10Gi

