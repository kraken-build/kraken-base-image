import sys

from formula import DownloadFileFormula


class ArgocdFormula(DownloadFileFormula):

    platform = sys.platform
    version = "v2.10.2"
    download_url = "https://github.com/argoproj/argo-cd/releases/download/${version}/argocd-linux-${archv2}"
    chmod = 0o775
    output_directory = "${install_to}"
    install_to = "/usr/local/bin"
