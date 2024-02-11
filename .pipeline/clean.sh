#!/bin/bash
#

set +e
set +x

(
    docker image rm valetudo-builder

    rm -v dist/**/*.upx
    pushd dist/ >/dev/null
    rm -vr aarch64/
    rm -vr armv7/
    rm -v changelog.md
    rm -v changelog_nightly.md
    rm -v valetudo.openapi.schema.json
    rm -v openapi.json
    rm -v valetudo_release_manifest.json
    rm -v valetudo_version.txt
    rm -v valetudo_config.json
    rm -v valetudo_*.tar.gz
) 2>/dev/null

exit 0

