#!/bin/bash
#

set -e

if [[ -z "$GITEA_SECRET" || -z "$VALETUDO_VERSION" || -z "$GITEA_URL" || -z "$GITEA_USER" ]]; then
    exit 1
fi

gitea_upload_file() {
    du -sh dist/$1
    curl \
        --upload-file dist/$1 \
        https://${GITEA_SECRET}@${GITEA_URL}/api/packages/${GITEA_USER}/generic/valetudo/${VALETUDO_VERSION}/$1
}


for arch in "aarch64" "armv7"; do
    gitea_upload_file "valetudo_${VALETUDO_VERSION}_${arch}.tar.gz"
done

for item in "openapi.json" "changelog.md" "changelog_nightly.md" "valetudo_release_manifest.json"; do
    gitea_upload_file ${item}
done
