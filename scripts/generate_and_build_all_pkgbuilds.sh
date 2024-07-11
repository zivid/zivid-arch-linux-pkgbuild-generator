#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR=$(realpath "$SCRIPT_DIR/..")
BUILD_DIR="$ROOT_DIR/build"

mkdir --parents "$BUILD_DIR" || exit $?

source /etc/os-release || exit $?

if [ "$ID" != "arch" ]; then
    # If not on Arch, build Docker image and re-run this script inside container
    docker build -t arch-deployment -f "${ROOT_DIR}"/deployment/Dockerfile . || exit $?
    docker run --rm \
        --volume $BUILD_DIR:/build \
        --user "$(id -u):$(id -g)" \
        -it arch-deployment \
        "$0" "$@"
else
    BUILD_DIR="/build"
    scripts/generate_all_pkgbuilds.sh "$BUILD_DIR" || exit $?

    for packageDir in "$BUILD_DIR"/*; do
        pushd $packageDir || exit $?
        makepkg --nodeps || exit $?
        popd || exit $?
    done
fi
