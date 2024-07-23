#!/bin/bash

set -e

source .pipeline/version.sh
source .pipeline/git-checkout-version.sh

if [[ ! -d "dist/" ]]; then
    mkdir -pv dist/ | sed 's/^/    /'
fi

if [[ -z "$SKIP_BUILD" ]]; then
    echo "[ ] Cleaning up dist/"
    .pipeline/clean.sh | sed 's/^/    /'
    echo "[ ] Build: Valetudo ${VALETUDO_VERSION}"
    (
    set -x
    docker build \
        --pull \
        --progress plain \
        --target export \
        --output dist/ \
        -t valetudo-builder \
        .
    )
    # 2>&1 | sed 's/^/    /'

fi

[[ -f "dist/valetudo_config.json" ]] && config_file=$(ls -1 --color=always dist/valetudo_config.json)
echo "[ ] Config: ${config_file}"
if [[ -n "${VALETUDO_BUILD_PRINT_CONFIG}" && "${config_file}" != "" ]]; then
    jq -C . dist/valetudo_config.json | sed 's/^/    /'
fi

echo "[ ] $(ls --color=always -1d dist):"
pushd dist 1>/dev/null

for item in $(ls -1); do
    if [[ -d "${item}" ]]; then
        ls --color=always -d1 ${item} | sed 's/^/    [ ] /'
        for item_file in $(ls -1 ${item}); do
            if [[ -x "${item}/${item_file}" ]]; then
                echo -n "        [b] "
                ls --color=always -1 ${item}/${item_file}
                echo -n "           "
                file ${item}/${item_file} | awk -F':' '{ print $2 }'
            fi
        done
    else
        echo -n "    [ ] "
        ls --color=always -1 ${item}
    fi
done
popd 1>/dev/null

echo "[ ] Version: "
[[ -f "dist/valetudo_config.json" ]] && CONFIG_VERSION=$(jq -C ._version dist/valetudo_config.json | tr -d '"')
NPM_VERSION=$(jq -C .version Valetudo/package.json | tr -d '"')
echo "    [v] config:           ${CONFIG_VERSION}"
echo "    [v] npm:              ${NPM_VERSION}"
echo "    [v] VALETUDO_VERSION: ${VALETUDO_VERSION}"

if [[ -t 1 && -z "$SKIP_TAR" ]]; then
    .pipeline/package.sh
fi

