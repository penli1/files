#!/bin/bash
#run on OpenShift Master

curl -o metrics-deployer.yaml  https://raw.githubusercontent.com/openshift/openshift-ansible/release-1.3/roles/openshift_hosted_templates/files/v1.3/enterprise/metrics-deployer.yaml

PREFIX=
PROJECT=openshift-infra
SUBDOMAIN=`grep subd /etc/origin/master/master-config.yaml | awk '{ print $2 }' | sed 's:^.\(.*\).$:\1:'`

oc project ${PROJECT}

oc create serviceaccount metrics-deployer

oadm policy add-cluster-role-to-user cluster-reader system:serviceaccount:openshift-infra:heapster

oc policy add-role-to-user edit system:serviceaccount:openshift-infra:metrics-deployer

oc secrets new metrics-deployer nothing=/dev/null

oc new-app -f metrics-deployer.yaml --as=system:serviceaccount:openshift-infra:metrics-deployer \
--param IMAGE_PREFIX=${PREFIX} \
--param IMAGE_VERSION=3.3.1 \
--param MASTER_URL=$MASTERURL \
--param HAWKULAR_METRICS_HOSTNAME=hawkular-metrics.${SUBDOMAIN} \
--param MODE=deploy \
--param USE_PERSISTENT_STORAGE=true \
--param DYNAMICALLY_PROVISION_STORAGE=false \
--param CASSANDRA_NODES=1 \
--param CASSANDRA_PV_SIZE=10Gi
