import sys

from formula import BinaryInstallFormula


class GrcovFormula(BinaryInstallFormula):

    platform = {"linux": "unknown-linux-gnu", "darwin": "apple-darwin"}[sys.platform]
    version = "0.8.19"
    archive_url = "https://github.com/mozilla/grcov/releases/download/v${version}/grcov-${archv1}-${platform}.tar.bz2"
    archive_members = ["grcov"]
    install_to = "/usr/local/bin"
