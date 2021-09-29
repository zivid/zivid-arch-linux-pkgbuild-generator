#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOT_DIR=$(realpath "$SCRIPT_DIR/..")
VENV=$(mktemp --tmpdir --directory zivid-pkgbuild-build-env-XXXX) || exit $?

zividVersion=2.4.2+1a2e8cfb-1
zividPackages="zivid zivid-studio zivid-tools zivid-genicam"

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
# shellcheck disable=SC1091
source $VENV/bin/activate || exit $?
pip install --no-cache-dir -r $ROOT_DIR/requirements.txt || exit $?

for zividPackage in $zividPackages; do
    generate $zividVersion $zividPackage $zividVersion || exit $?
done

generate $zividVersion zivid-telicam-driver 3.0.1.1-3 || exit $?

deactivate || exit $?

echo Success! [$0]
