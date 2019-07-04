
# Scripts to generate PKGBUILDs for Arch Linux

[![Build Status](https://travis-ci.org/zivid/arch-linux-pkgbuild-generator.svg?branch=master)](https://travis-ci.org/zivid/arch-linux-pkgbuild-generator)

This repository contains the scripts uses to generate [Zivid](https://www.zivid.com/) [PKGBUILD](https://wiki.archlinux.org/index.php/PKGBUILD)s for [Arch Linux](https://www.archlinux.org/) and to upload them to [AUR](https://wiki.archlinux.org/index.php/Arch_User_Repository).

## Installing Zivid software on Arch Linux

To install Zivid software on Arch Linux you should _not_ use the scripts in this repository, but rather use the uploaded PKGBUILDs in AUR.

See https://aur.archlinux.org/packages/?K=zivid for the list of Zivid packages.

These packages can easily be installed by using one of the [AUR helpers](https://wiki.archlinux.org/index.php/AUR_helpers) like [yaourt](https://aur.archlinux.org/packages/yaourt).

    yaourt -S --noconfirm zivid-studio zivid-tools

## Uploading new versions to AUR

1. Update `zividVersion` in `scripts/generate_all_pkgbuilds.sh`
2. Run the tests. See [.travis.yml](.travis.yml).
3. Run `./scripts/update_aur.sh`.

## Registering new packages

The list of packages to be uploaded is found in `scripts/generate_all_pkgbuilds.sh`, the list of dependencies can be found in `scripts/generate_pkgbuild.py`.

Extend those lists when Zivid releases more packages.
