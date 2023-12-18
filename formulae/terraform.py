import sys

from formula import BinaryInstallFormula


class TerraformFormula(BinaryInstallFormula):

    platform = {"linux": "unknown-linux-musl", "darwin": "apple-darwin"}[sys.platform]
    version = "1.6.6"
    archive_url = "https://releases.hashicorp.com/terraform/${version}/terraform_${version}_linux_${archv2}.zip"
    archive_members = ["terraform"]
    install_to = "/usr/local/bin"

    def finalize(self) -> None:
        self.chmod("+x", "${install_to}/terraform")
