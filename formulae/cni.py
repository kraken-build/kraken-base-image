from formula import BinaryInstallFormula


class CniFormula(BinaryInstallFormula):

    version = "v1.4.0"
    archive_url = "https://github.com/containernetworking/plugins/releases/download/${version}/cni-plugins-linux-${archv2}-${version}.tgz"
    archive_members = ["*"]
    install_to = "/opt/cni/bin"
    strip_all_components = False
