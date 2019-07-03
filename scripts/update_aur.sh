#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

TMP_DIR=$(mktemp --tmpdir --directory zivid-aur-update-XXXX)
BUILD_DIR=$TMP_DIR/build
GIT_DIR=$TMP_DIR/git

$SCRIPT_DIR/generate_all_pkgbuilds.sh $BUILD_DIR || exit $?

mkdir -p $GIT_DIR || exit $?
cd $GIT_DIR || exit $?
for packageDir in "$BUILD_DIR"/*; do
    package=$(basename $packageDir)
    git clone ssh://aur@aur.archlinux.org/$package.git || exit $?
    pushd $package || exit $?
    cp $packageDir/* . || exit $?
    pkgver=$(grep pkgver PKGBUILD |cut -d"'" -f2)
    makepkg --printsrcinfo > .SRCINFO || exit $?
    git add $(ls -A) || exit $?
    git ci -m"Version $pkgver"
    git push --set-upstream origin master || exit $?
    popd || exit $?
done
