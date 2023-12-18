import sys

from formula import BinaryInstallFormula


class SccacheFormula(BinaryInstallFormula):

    platform = {"linux": "unknown-linux-musl", "darwin": "apple-darwin"}[sys.platform]
    version = "0.7.4"
    archive_url = "https://github.com/mozilla/sccache/releases/download/v${version}/sccache-v${version}-${archv1}-${platform}.tar.gz"
    archive_members = ["sccache-v${version}-${archv1}-${platform}/sccache"]
    install_to = "/usr/local/bin"

    def finalize(self) -> None:
        self.chmod("+x", "${install_to}/sccache")
