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
        "zivid-telicam-driver": (),
        "zivid": ("zivid-telicam-driver", "opencl-driver"),
        "zivid-studio": ("zivid",),
        "zivid-tools": ("zivid",),
        "zivid-genicam": ("zivid",),
    }

    replaces = {
        "zivid-telicam-driver": ("zivid-telicam-sdk",),
        "zivid": (),
        "zivid-studio": (),
        "zivid-tools": (),
        "zivid-genicam": (),
    }

    def __init__(self, base_dir: Path, template_file: Path):
        self.base_dir = base_dir
        with template_file.open() as in_file:
            self.template = in_file.read()

    def source_url(self, release_version, package_name, package_version):
        return f"https://downloads.zivid.com/sdk/releases/{release_version}/u18/{package_name}_{package_version}_amd64.deb"

    def configure(self, release_version, ubuntu_package_name, package_version):
        source_url = self.source_url(
            release_version, ubuntu_package_name, package_version
        )
        package_name = _ubuntu_package_name_to_arch(ubuntu_package_name)
        return self.template.format(
            name=package_name,
            pkgver=package_version.replace("-", "_"),
            description=self.description,
            url=self.company_url,
            dependencies=" ".join(self.dependencies[package_name]),
            conflicts=" ".join(self.replaces[package_name]),
            provides=" ".join(self.replaces[package_name]),
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

    pkgbuild = Pkgbuild(Path(options.out_dir), Path(options.template))

    pkgbuild.write(options.release_version, options.package, options.package_version)

    print("Done")


if __name__ == "__main__":
    main()
