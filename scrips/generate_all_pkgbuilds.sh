#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOT_DIR=$(realpath "$SCRIPT_DIR/..")
VENV=$(mktemp --tmpdir --directory zivid-pkgbuild-build-env-XXXX) || exit $?

if [ -z "$1" ]; then
    echo Usage: $0 out-dir
    exit 1
fi
OUT_DIR=$1

function generate {
    releaseVersion=$1
    packageName=$2
    packageVersion=$3
    python $SCRIPT_DIR/generate_pkgbuild.py \
           --out-dir $OUT_DIR \
           --template $ROOT_DIR/PKGBUILD.in \
           --release-version $releaseVersion \
           --package $packageName \
           --package-version $packageVersion || exit $?
}

python -m venv $VENV || exit $?
source $VENV/bin/activate || exit $?
pip install --no-cache-dir -r $ROOT_DIR/requirements.txt || exit $?

zividVersion=1.3.0+bb9ee328-10
for zividPackage in zivid zivid-studio zivid-tools; do
    generate $zividVersion $zividPackage $zividVersion || exit $?
done

generate $zividVersion telicam-sdk 2.0.0.1-1 || exit $?

deactivate || exit $?

echo Success! [$0]
