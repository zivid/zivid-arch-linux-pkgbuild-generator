#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOT_DIR=$(realpath "$SCRIPT_DIR/..")

source /etc/os-release || exit $?

if [ $ID != "arch" ]; then
    # If not on Arch, build Docker image and re-run this script inside container
    docker build -t arch-deployment -f ${ROOT_DIR}/deployment/Dockerfile . || exit $?
    docker run --rm \
        --volume ~/.ssh:/home/deploymentuser/.ssh \
        --volume ~/.gitconfig:/home/deploymentuser/.gitconfig \
        -it arch-deployment \
        "$0" "$@"
else
    # This block only works on Arch
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
        git commit -m"Version $pkgver"
        git push --set-upstream origin master || exit $?
        popd || exit $?
    done
fi

