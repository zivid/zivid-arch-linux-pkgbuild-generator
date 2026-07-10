from pathlib import Path
import hashlib
import argparse
import requests


def _sha256sum(url):
    request = requests.get(url, stream=True)
    sha256 = hashlib.sha256()
    print(f"Calculating sha265sum of {url}", end="", flush=True)
    for chunk in request.iter_content(1000000):
        print(".", end="", flush=True)
        sha256.update(chunk)
    print("done", flush=True)
    return sha256.hexdigest()


def _ubuntu_package_name_to_arch(name):
    return name if name.startswith("zivid") else f"zivid-{name}"


class Pkgbuild:
    company_url = "https://www.zivid.com"
    description = "Defining the Future of 3D Machine Vision"

    dependencies = {
        "zivid-opencl": ("opencl-driver",),
        "zivid-cuda": ("nvidia-utils",),
        "zivid-studio": ("zivid",),
        "zivid-tools": ("zivid",),
        "zivid-genicam": ("zivid",),
    }

    # The GPU backends are the two mutually-exclusive providers of the virtual
    # `zivid` package. Each one:
    #   - provides `zivid`, so packages depending on `zivid` (studio/tools/...)
    #     are satisfied and `pacman -S zivid` prompts the user to pick a backend;
    #   - conflicts `zivid`, so only one backend can be installed at a time and so
    #     it cleanly takes over the files (headers, libZividCore.so) that the old
    #     monolithic `zivid` package used to own;
    #   - replaces `zivid`, so a `-Syu` from a pre-split install migrates the old
    #     real `zivid` package to a backend in a single transaction.
    conflicts = {
        "zivid-cuda": ("zivid", "zivid-opencl"),
        "zivid-opencl": ("zivid", "zivid-cuda"),
        "zivid-studio": (),
        "zivid-tools": (),
        "zivid-genicam": (),
    }

    provides = {
        "zivid-cuda": ("zivid",),
        "zivid-opencl": ("zivid",),
        "zivid-studio": (),
        "zivid-tools": (),
        "zivid-genicam": (),
    }

    replaces = {
        "zivid-cuda": ("zivid",),
        "zivid-opencl": ("zivid",),
        "zivid-studio": (),
        "zivid-tools": (),
        "zivid-genicam": (),
    }

    def __init__(self, base_dir: Path, template: str):
        self.base_dir = base_dir
        self.template = template

    def source_url(self, release_version, package_name, package_version):
        return f"https://downloads.zivid.com/sdk/releases/{release_version}/u20/{package_name}_{package_version}_amd64.deb"

    def configure(self, release_version, ubuntu_package_name, package_version):
        package_name = _ubuntu_package_name_to_arch(ubuntu_package_name)

        source_url = self.source_url(
            release_version, ubuntu_package_name, package_version
        )
        return self.template.format(
            name=package_name,
            pkgver=package_version.replace("-", "_"),
            description=self.description,
            url=self.company_url,
            dependencies=" ".join(self.dependencies[package_name]),
            conflicts=" ".join(self.conflicts[package_name]),
            provides=" ".join(self.provides[package_name]),
            replaces=" ".join(self.replaces[package_name]),
            source=source_url,
            sha256sum=_sha256sum(source_url),
        )

    def write(self, release_version, ubuntu_package_name, package_version):
        package_name = _ubuntu_package_name_to_arch(ubuntu_package_name)

        out_dir = self.base_dir / package_name
        out_dir.mkdir(parents=True)

        out_file_name = out_dir / "PKGBUILD"
        print(f"Writing {out_file_name}")
        with out_file_name.open("w") as out_file:
            out_file.write(
                self.configure(release_version, ubuntu_package_name, package_version)
            )


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--out-dir")
    parser.add_argument("--template")
    parser.add_argument("--release-version")
    parser.add_argument("--package")
    parser.add_argument("--package-version")
    options = parser.parse_args()

    pkgbuild = Pkgbuild(
        Path(options.out_dir),
        Path(options.template).read_text(encoding="utf-8"),
    )

    pkgbuild.write(options.release_version, options.package, options.package_version)

    print("Done")


if __name__ == "__main__":
    main()
