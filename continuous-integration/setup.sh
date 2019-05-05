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
       python-black \
       python-pip \
       python-pylint \
       shellcheck \
       sudo \
       tar \
    || exit $?

echo Success! [$0]
