from formula import BinaryInstallFormula


class BuildkitFormula(BinaryInstallFormula):

    version = "0.12.2"
    archive_url = "https://github.com/moby/buildkit/releases/download/v${version}/buildkit-v${version}.linux-${archv2}.tar.gz"
    archive_members = ["bin/*"]
    install_to = "/usr/local/bin"
