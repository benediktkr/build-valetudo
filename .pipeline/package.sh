#!/bin/bash
#

if [[ -z "${VALETUDO_VERSION}" ]]; then
    echo "[!] ERROR: 'VALETUDO_VERSION' is not set!"
    exit 1
fi


TAR_NAME="valetudo_${VALETUDO_VERSION}"
echo "[>] Creating tarballs: "
#tar czf ${TAR_NAME}.tar.gz dist/
#mv ${TAR_NAME}.tar.gz dist/
#ls -1 --color=always dist/${TAR_NAME}.tar.gz | sed 's/^/    /'

for arch in "aarch64" "armv7"; do
    tar czf dist/${TAR_NAME}_${arch}.tar.gz dist/${arch}/ dist/openapi.json dist/valetudo_config.json dist/valetudo_release_manifest.json dist/changelog.md dist/changelog_nightly.md
    ls -1 --color=always dist/${TAR_NAME}_${arch}.tar.gz | sed 's/^/    /'
done

