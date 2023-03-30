#!/bin/bash
set -euo pipefail

# this script is used to attach image digests to the bundle CSV:

YQ=$1
CRANE=$2

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
REPO_ROOT=$SCRIPT_DIR/../
BUNDLE_DIR="$REPO_ROOT/bundle"
CSV_FILE="${BUNDLE_DIR}/manifests/external-secrets-operator.clusterserviceversion.yaml"

if ! command -v $CRANE &> /dev/null
then
    echo "crane could not be found"
    exit
fi

if ! command -v $YQ &> /dev/null
then
    echo "yq could not be found"
    exit
fi

if [ ! -f $CSV_FILE ]; then
    echo "CSV File not found at $CSV_FILE"
    exit
fi

source_refs=()

echo "Finding image references from container definitions..."
for img in $($YQ eval '.spec.install.spec.deployments[].spec.template.spec.containers[].image' $CSV_FILE)
do
  source_refs+=( "$img" )
done

# get unique refs only
sorted_unique_refs=($(echo "${source_refs[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))

echo  
echo "The following refs were found:"
for ref in "${sorted_unique_refs[@]}"
do
  echo "   $ref"
done

echo
# process each image, then search and replace with sed.
for ref in "${sorted_unique_refs[@]}"
do
  echo "Processing $ref..."
 
  # if not a digest ref, skopeo inspect it.
  if ! [[ "$ref" =~ "@" ]]
  then
    img_name="${ref%%:*}"
  else
    img_name=$(echo $ref | cut -f 1 -d'@')
  fi

  # tags to digest, and we're not already dealing with a digest ref.
  if ! [[ "$ref" =~ "@" ]]
  then
    echo "  Processing tag to digest conversion..."
    img_digest=$($CRANE digest $ref)

    echo "  Digest is $img_name@$img_digest"

    sed -i'.original' -e "s#$ref#$img_name@$img_digest#g" $CSV_FILE
    rm $CSV_FILE.original

  fi
done

CREATED_TIME=`date +"%FT%H:%M:%SZ"`
yq eval --inplace ".metadata.annotations.createdAt = \"${CREATED_TIME}\"" "$CSV_FILE"
