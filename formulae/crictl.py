from formula import BinaryInstallFormula


class CrictlFormula(BinaryInstallFormula):

    version = "v1.30.1"
    archive_url = "https://github.com/kubernetes-sigs/cri-tools/releases/download/${version}/crictl-${version}-linux-amd64.tar.gz"
    archive_members = ["crictl"]
    install_to = "/usr/local/bin"
    upx_optimize = True
