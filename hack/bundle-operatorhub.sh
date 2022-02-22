#!/bin/bash
set -euo pipefail

# this script is used to:
# (1) sync upstream operatorhub/openshift operators
#     repositories with our fork
# (2) automate the release worklflow with the above repositories
VERSION=$1

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
REPO_ROOT=$SCRIPT_DIR/../
BUNDLE_DIR="$REPO_ROOT/bundle"

COMMUNITY_UPSTREAM="https://github.com/k8s-operatorhub/community-operators"
COMMUNITY_FORK="git@github.com:external-secrets/community-operators.git"
COMMUNITY_DIRNAME=$(basename $COMMUNITY_UPSTREAM)

OPENSHIFT_UPSTREAM="https://github.com/redhat-openshift-ecosystem/community-operators-prod"
OPENSHIFT_FORK="git@github.com:external-secrets/community-operators-prod.git"
OPENSHIFT_DIRNAME=$(basename $OPENSHIFT_UPSTREAM)

if ! command -v hub &> /dev/null
then
    echo "hub could not be found"
    echo "see here for instructions: https://github.com/github/hub#installation"
    exit
fi

function main() {
  sync_repo ${COMMUNITY_UPSTREAM} ${COMMUNITY_FORK} ${COMMUNITY_DIRNAME}
  sync_repo ${OPENSHIFT_UPSTREAM} ${OPENSHIFT_FORK} ${OPENSHIFT_DIRNAME}
}

function sync_repo() {
  REPO=$1
  FORK=$2
  DIRNAME=$3
  BRANCH_NAME=bump-release-${VERSION}
  OWNER=$(basename $(dirname $REPO))

  TMP=$(mktemp -d)
  echo "workdir: ${TMP}"
  cd ${TMP}

  # The remote names follow a specific convention.
  # see here: https://hub.github.com/hub.1.html#conventions
  git clone -o upstream $REPO $DIRNAME
  cd $DIRNAME
  git remote add origin $FORK
  git push origin main
  git checkout -b ${BRANCH_NAME}

  cp -Tr ${BUNDLE_DIR} \
    ./operators/external-secrets-operator/${VERSION}

  if [[ -z $(git status --porcelain=v1 2>/dev/null) ]]; then
    echo "no changes detected. skipping"
  fi

  operator-sdk bundle validate \
    ./operators/external-secrets-operator/${VERSION} \
    --select-optional suite=operatorframework

  git add .
  git commit -s -m "chore: bump external secrets ${VERSION}"
  git push origin ${BRANCH_NAME} --force

  hub pull-request -o \
    -m "bump external-secrets operator ${VERSION}" \
    -m "bump external-secrets-operator ${VERSION}" \
    -b ${OWNER}:main \
    -h external-secrets:${BRANCH_NAME}

  rm -rf ${TMP}
}

main $@
