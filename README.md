
# Scripts to generate PKGBUILDs for Arch Linux

[![Build Status][ci-badge]][ci-url]

This repository contains the scripts uses to generate [Zivid](https://www.zivid.com/) [PKGBUILD](https://wiki.archlinux.org/index.php/PKGBUILD)s for [Arch Linux](https://www.archlinux.org/) and to upload them to [AUR](https://wiki.archlinux.org/index.php/Arch_User_Repository).

## Installing Zivid software on Arch Linux

To install Zivid software on Arch Linux you should _not_ use the scripts in this repository, but rather use the uploaded PKGBUILDs in AUR.

See https://aur.archlinux.org/packages/?K=zivid for the list of Zivid packages.

These packages can easily be installed by using one of the [AUR helpers](https://wiki.archlinux.org/index.php/AUR_helpers) like [yaourt](https://aur.archlinux.org/packages/yaourt).

    yaourt -S --noconfirm zivid-studio zivid-tools

## Uploading new versions to AUR

1. Update `zividVersion` in `scripts/generate_all_pkgbuilds.sh`
2. Run the tests. See [azure-pipelines.yml](azure-pipelines.yml).
3. Make sure you have an AUR account with write access to the zivid repo and SSH public key.
4. Run `./scripts/update_aur.sh`.

## Registering new packages

The list of packages to be uploaded is found in `scripts/generate_all_pkgbuilds.sh`, the list of dependencies can be found in `scripts/generate_pkgbuild.py`.

Extend those lists when Zivid releases more packages.

[ci-badge]: https://img.shields.io/azure-devops/build/zivid-devops/83d24458-0938-4d05-a0d0-104cd8dff5e3/7
[ci-url]: https://dev.azure.com/zivid-devops/zivid-arch-linux-pkgbuild-generator/_build/latest?definitionId=7&branchName=master
