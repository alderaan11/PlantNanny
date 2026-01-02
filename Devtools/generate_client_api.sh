#!/usr/bin/env bash

# Load nvm if available (needed for npm-installed tools)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

ROOT_DIR=$(git rev-parse --show-toplevel)

if [ "$ROOT_DIR" = "" ]; then
  ROOT_DIR=$(pwd)
fi


# This script generates the client API code from the OpenAPI specification for Dart.
# It requires 'openapi-generator-cli' to be installed and available in the PATH.

if ! command -v openapi-generator-cli &> /dev/null
then
    echo "openapi-generator-cli could not be found. Please install it first."
    echo "Usage: npm install -g @openapitools/openapi-generator-cli"
    exit 1
fi

mkdir -p $ROOT_DIR/ClientApi

openapi-generator-cli generate \
  -i $ROOT_DIR/api/plant_nanny_api.yaml \
  -g dart-dio \
  -o $ROOT_DIR/ClientApi \
  --additional-properties=pubName=plant_nanny_api 