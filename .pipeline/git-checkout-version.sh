#!/bin/bash

function exit_checkout_ref {
    if [[ -n "${original_ref}" ]]; then
        echo "[<] Original git ref set: '${original_ref}'"
        git $GIT_CHDIR_OPT checkout ${original_ref} 2>&1 | sed 's/^/    /'
    fi
}
trap exit_checkout_ref EXIT

set -e

#current_branch=$(git $GIT_CHDIR_OPT rev-parse --abbrev-ref HEAD)
# borrwed from: oh-my-zsh:lib/git.zsh
ref=$(git $GIT_CHDIR_OPT symbolic-ref --quiet HEAD 2>/dev/null ||
    git $GIT_CHDIR_OPT symbolic-ref --short HEAD 2>/dev/null ||
    git $GIT_CHDIR_OPT describe --tags --exact-match HEAD 2>/dev/null ||
    git $GIT_CHDIR_OPT rev-parse --short HEAD 2>/dev/null ||
    return 0
    )
current_ref=$(echo ${ref#refs/heads/})


#source .pipeline/version.sh
if [[ -z "${BUILD_SNAPSHOT}" && "${current_ref}" != "${VALETUDO_VERSION}" ]]; then
    # for the trap EXIT fuction
    original_ref=$current_ref
    echo "[!] Current git HEAD is '${current_ref}'"
    echo "    [>] Checking out git ref: '${VALETUDO_VERSION}'"
    git $GIT_CHDIR_OPT checkout ${VALETUDO_VERSION} 2>&1 | sed 's/^/        /'
fi


