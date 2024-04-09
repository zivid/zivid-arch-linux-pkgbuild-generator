#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOT_DIR=$(realpath "$SCRIPT_DIR/..")
TMP_DIR=$(sudo -u nobody mktemp --tmpdir --directory zivid-pkgbuild-testing-XXXX) || exit $?

# Elevate permissions
if [ $EUID != 0 ]; then
    sudo "$0" "$@"
    exit $?
fi

sudo -u nobody $ROOT_DIR/scripts/generate_all_pkgbuilds.sh $TMP_DIR || exit $?

function test_zivid {
    [[ -f /usr/lib/libZividCore.so ]] || exit 1
}

function test_zivid-studio {
    [[ -f /usr/bin/ZividStudio ]] || exit 1
}

function test_zivid-tools {
    [[ -f /usr/bin/ZividListCameras ]] || exit 1
}

function test_zivid-genicam {
    [[ -f /usr/lib/zivid/genicam/libZividGenTLProducer.cti ]] || exit 1
}

function test_package {
    package=$1
    echo "Testing $package package"
    pushd $TMP_DIR/$package || exit $?
    PKGEXT=.pkg.tar sudo -E -u nobody makepkg || exit $?
    pacman -U --noconfirm ./*$package*.tar || exit $?
    popd || exit $?
    rm -r ${TMP_DIR:?}/$package

    test_$package || exit $?
}

test_package zivid || exit $?
test_package zivid-studio || exit $?
test_package zivid-tools || exit $?
test_package zivid-genicam || exit $?

rmdir $TMP_DIR || exit $?

echo Success! [$0]
