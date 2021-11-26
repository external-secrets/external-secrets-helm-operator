#!/bin/bash

REPO="https://github.com/external-secrets/external-secrets"
HELM_CHART_VERSION="0.3.8"
HELM_CHART_PATH="helm-charts/external-secrets"

EXISTS=`grep -ir ${HELM_CHART_VERSION} ${HELM_CHART_PATH}/Chart.yaml | wc -l`

if [ ${EXISTS} -ge 1 ]; then
  echo "Helm chart version ${HELM_CHART_VERSION} already exists, doing nothing"
else
  echo "Helm chart version ${HELM_CHART_VERSION} does not exists, downloading into ${HELM_CHART_PATH}/"
  rm -rf ${HELM_CHART_PATH}/*
  curl -sL ${REPO}/releases/download/helm-chart-${HELM_CHART_VERSION}/external-secrets-${HELM_CHART_VERSION}.tgz | tar xz -C helm-charts/
fi