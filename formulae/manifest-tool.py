
from formula import BinaryInstallFormula


class ManifestToolFormula(BinaryInstallFormula):

    version = "2.0.5"
    archive_url = (
        "https://github.com/estesp/manifest-tool/releases/download/v${version}/"
        "binaries-manifest-tool-${version}.tar.gz"
    )
    archive_members = {"manifest-tool-${platform}-${arch}": "manifest-tool"}
    install_to = "/usr/local/bin"
