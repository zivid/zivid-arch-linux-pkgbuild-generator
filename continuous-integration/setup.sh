#!/bin/bash

# Elevate permissions
if [ $EUID != 0 ]; then
    sudo "$0" "$@"
    exit $?
fi

pacman -Syu --noconfirm --needed \
       awk \
       fakeroot \
       file \
       flake8 \
       grep \
       intel-compute-runtime \
       python-black \
       python-pip \
       python-pylint \
       python-isort \
       shellcheck \
       sudo \
       tar \
    || exit $?

echo Success! [$0]
