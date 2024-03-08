from formula import BinaryInstallFormula


class SternFormula(BinaryInstallFormula):

    version = "1.28.0"
    archive_url = "https://github.com/stern/stern/releases/download/v${version}/stern_${version}_linux_${archv2}.tar.gz"
    archive_members = ["stern"]
    install_to = "/usr/local/bin"
