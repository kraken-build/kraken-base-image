from formula import BinaryInstallFormula


class CriDockerdFormula(BinaryInstallFormula):

    version = "0.4.6"
    archive_url = "https://github.com/Mirantis/cri-dockerd/releases/download/v${version}/cri-dockerd-${version}.amd64.tgz"
    archive_members = ["cri-dockerd/cri-dockerd"]
    install_to = "/usr/local/bin"
    upx_optimize = True
