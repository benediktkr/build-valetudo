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

gitea_release_create() {
    curl -s -X POST \
      https://${GITEA_SECRET}@${GITEA_URL}/api/v1/repos/${GITEA_USER}/build-valetudo/releases \
      -H 'accept: application/json' \
      -H 'Content-Type: application/json' \
      -d '{
  "body": "Valetudo release: ${VERSION}",
  "draft": false,
  "name": "Valetudo ${VERSION}",
  "prerelease": false,
  "tag_name": "${VERSION}",
  "target_commitish": "${GIT_COMMIT}"
}' | jq .
}

gitea_release_file() {
    curl -X POST \
      https://${GITEA_SECRET}@${GITEA_URL}/api/v1/repos/${GITEA_USER}/build-valetudo/releases/$1/assets?name=$2 \
  -H 'accept: application/json' \
  -H 'Content-Type: multipart/form-data' \
  -F "attachment=@$2;type=application/x-sh" | jq .
}

#gitea_release_create || true

for arch in "aarch64" "armv7"; do
    tarball="valetudo_${VALETUDO_VERSION}_${arch}.tar.gz"
    gitea_upload_file $tarball 
    #gitea_release_file $tarball
done

for item in "openapi.json" "changelog.md" "changelog_nightly.md" "valetudo_release_manifest.json"; do
    gitea_upload_file ${item}
done


