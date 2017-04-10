#!/bin/bash

export PREFIX=
export PROJECT=openshift-infra
export SUBDOMAIN=


oc project ${PROJECT}

oc create serviceaccount metrics-deployer

oadm policy add-cluster-role-to-user cluster-reader system:serviceaccount:openshift-infra:heapster

oc policy add-role-to-user edit system:serviceaccount:openshift-infra:metrics-deployer

oc secrets new metrics-deployer nothing=/dev/null

oc new-app metrics-deployer-template --as=system:serviceaccount:openshift-infra:metrics-deployer -p \
IMAGE_PREFIX=${PREFIX},\
IMAGE_VERSION=,\
HAWKULAR_METRICS_HOSTNAME=hawkular-metrics.${SUBDOMAIN},\
MODE=deploy,\
USE_PERSISTENT_STORAGE=true,\
DYNAMICALLY_PROVISION_STORAGE=true,\
CASSANDRA_NODES=1,\
CASSANDRA_PV_SIZE=10Gi
