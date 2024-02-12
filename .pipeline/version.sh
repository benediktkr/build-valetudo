#!/bin/bash

set -e

export GIT_CONFIG_PARAMETERS="'color.ui=always'"
GIT_CONFIG_PARAMETERS="${GIT_CONFIG_PARAMETERS} 'advice.detachedHead=false'"

export PWD_REPO_PATH=$(git rev-parse --show-toplevel)
export PWD_REPO_NAME=$(basename $PWD_REPO_PATH)
#export PWD_REPO_PATH=$(git rev-parse --git-dir)

if [[ "$PWD_REPO_NAME" != "Valetudo" ]]; then
    GIT_CHDIR_OPT="-C Valetudo/"
    export GIT_CHDIR_OPT
fi

if [[ -n "${BUILD_SNAPSHOT}" && "${BUILD_SNAPSHOT}" != "false" ]]; then
    # Jenkins will set this to "false" since it is the name of the build parameter
    if [[ "$(basename $(pwd))" == "Valetudo" ]]; then
        PACKAGE_JSON="$(pwd)/package.json"
    else
        PACKAGE_JSON="${PWD_REPO_PATH}/Valetudo/package.json"
    fi

    VALETUDO_NPM_VERSION=$(jq -r .version $PACKAGE_JSON)
    VALETUDO_VERSION="${VALETUDO_NPM_VERSION}-SNAPSHOT"
elif [[ -z "${VALETUDO_VERSION}" ]]; then
    # latest tag (annotated or not)
    #LATEST_TAG=$(git $GIT_CHDIR_OPT tag -l --sort=-creatordate | head -n 1)
    # latest annotated tag (releases)
    LATEST_TAG=$(git $GIT_CHDIR_OPT describe --tags --abbrev=0)
    VALETUDO_VERSION=$LATEST_TAG
fi

export VALETUDO_VERSION

if [[ -t 1 ]]; then
    if [[ -n "${VERSION_PRINT}" ]]; then
        echo "version: '${VALETUDO_VERSION}'"
    fi
else
    if [[ -n "JENKINS_VERSION" || -n "JENKINS_HOME" ]]; then
        echo $VALETUDO_VERSION
    fi
fi

