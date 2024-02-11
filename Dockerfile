FROM node:latest as base

# uid 1000
USER node

FROM base as builder
COPY --chown=node:node Valetudo/ /usr/local/src/Valetudo/
WORKDIR /usr/local/src/Valetudo
ENV VALETUDO_CONFIG_PATH=/usr/local/src/Valetudo/build/valetudo_config.json

# Install (dependencies) and build as separate layers for caching
RUN set -x && \
    npm install
RUN set -x && \
    npm run build

# Create default config file
#   The dev server will fail to start, because it requires a config file
#   to have already existed, and to have robot.implmentation set. But
#   we are starting it to create a default config file (that we don't
#   intend to use with npm, we just want it for the build).
# Setting env var ourselves
#   The 'npm run start:dev --workspace=backend' invokes the 'start:dev' command
#   that is defined in Valetudo/backend/package.json
#   It's defiend as 'cross-env VALETUDO_CONFIG_PATH=../local/valetudo_config.json npm run start"
#   So we can just run 'npm run' with '--workspace=backend' directly (or by
#   changing WORKDIR to Valetudo/backend), and set the 'VALETUDO_CONFIG_PATH' ourselves.
# cp -rv /usr/local/src/Valetudo/backend/lib/res/valetudo.openapi.schema.json /usr/local/src/build/openapi.json && \
#mkdir $(dirname $VALETUDO_CONFIG_PATH) && \
# Config file in repo
#   There is a file 'backend/lib/res/default_config.json' present in the
#   repo source tree.
#     $ diff build/valetudo_config.json backend/lib/res/default_config.json
#     <   "embedded": false,
#     >   "embedded": true,
#     <   "_version": "2023.12.0"
#     >   "_version": ""
#   The generated file hhas the version number that was built (and has "embedded"
#   set to false, i dont know what the significant of that is), so we generate
#   valeutdo_condig.json and use that one to get easy access to the verson)
# Docs
#   Where do they go??

ENV VALETUDO_BUILD_UPX_FILES="false"
RUN set -x && \
    npm run start --workspace=backend 2>/dev/null || true && \
    if [[ "$VALETUDO_BUILD_UPX_FILES" == "true" ]]; then npm run upx; fi && \
    npm run build_docs && \
    npm run build_openapi_schema && \
    npm run build_release_manifest && \
    npm run generate_changelog && \
    npm run generate_nightly_changelog && \
    mv build/valetudo.openapi.schema.json build/openapi.json

FROM scratch as export
COPY --from=builder /usr/local/src/Valetudo/build/ .
