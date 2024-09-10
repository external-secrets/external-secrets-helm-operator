#!/bin/bash

REPO="https://github.com/external-secrets/external-secrets"
HELM_CHART_PATH="helm-charts/external-secrets"
HELM_CHART_VERSION=`echo ${1} | awk '{split($0,a,"-alpha"); print a[1]}'`

EXISTS=`grep -ir ${HELM_CHART_VERSION} ${HELM_CHART_PATH}/Chart.yaml | wc -l`

if [ ${EXISTS} -ge 1 ]; then
  echo "Helm chart version ${HELM_CHART_VERSION} already exists, doing nothing"
else
  echo "Helm chart version ${HELM_CHART_VERSION} does not exists, downloading into ${HELM_CHART_PATH}/"
  rm -rf ${HELM_CHART_PATH}/*
  curl -sL ${REPO}/releases/download/helm-chart-${HELM_CHART_VERSION}/external-secrets-${HELM_CHART_VERSION}.tgz | tar xz -C helm-charts/
fi

# apply patches to helm chart
# 1: remove CRDs; they are managed by OLM
yq e -i '.installCRDs = false' ${HELM_CHART_PATH}/values.yaml
rm -rf ${HELM_CHART_PATH}/templates/crds

# 2: reset runAsUser due to SCCs blocking runAsUser
# see: https://github.com/external-secrets/external-secrets/issues/2342
yq e -i '.securityContext.runAsUser = null' ${HELM_CHART_PATH}/values.yaml
yq e -i '.securityContext.seccompProfile = null' ${HELM_CHART_PATH}/values.yaml
yq e -i '.webhook.securityContext.runAsUser = null' ${HELM_CHART_PATH}/values.yaml
yq e -i '.webhook.securityContext.seccompProfile = null' ${HELM_CHART_PATH}/values.yaml
yq e -i '.certController.securityContext.runAsUser = null' ${HELM_CHART_PATH}/values.yaml
yq e -i '.certController.securityContext.seccompProfile = null' ${HELM_CHART_PATH}/values.yaml

# Patch remove the schema validation because it breaks the tests.
# kuttl is unable to properly provide values and further,
# helm --skip-schema-validation flag is not yet released.
rm -fr ${HELM_CHART_PATH}/values.schema.json
