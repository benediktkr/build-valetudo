#!/bin/bash

set -e

if [[ -n "${VALETUDO_VERSION}" ]]; then
    echo "environment var 'VALETUDO_VERSION' is alrady set, this probably means that a specific/version tag is being built manually" >&2
    echo "VALETUDO_VERSION: ${VALETUDO_VERSION}'" >&2
    echo >&2
    echo "will use this value and not look for tha latest git tag" >&2
    sleep 5
else
    PWD_REPO_NAME=$(basename $(git rev-parse --show-toplevel))
    if [[ "$PWD_REPO_NAME" != "Valetudo" ]]; then
        GIT_CHDIR_OPT="-C Valetudo/"
    fi
    LATEST_TAG=$(git $GIT_CHDIR_OPT describe --tags --abbrev=0)
    VALETUDO_VERSION=$LATEST_TAG
    export VALETUDO_VERSION
fi

if [[ -t 1 ]]; then
    echo "version: '${VALETUDO_VERSION}'"
else
    echo $VALETUDO_VERSION
fi


