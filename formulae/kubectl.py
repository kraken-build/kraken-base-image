import sys

from formula import DownloadFileFormula


class KubectlFormula(DownloadFileFormula):

    platform = sys.platform
    version = "v1.28.4"
    download_url = "https://dl.k8s.io/release/${version}/bin/${platform}/${archv2}/kubectl"
    chmod = 0o775
    output_directory = "${install_to}"
    install_to = "/usr/local/bin"
