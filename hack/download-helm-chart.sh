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
sed -i "s|installCRDs: [^ ]*|installCRDs: false|g" ${HELM_CHART_PATH}/values.yaml
rm -rf ${HELM_CHART_PATH}/templates/crds