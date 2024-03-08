import sys

from formula import DownloadFileFormula


class MinikubeFormula(DownloadFileFormula):

    platform = sys.platform
    version = "v1.32.0"
    download_url = "https://storage.googleapis.com/minikube/releases/${version}/minikube-linux-${archv2}"
    chmod = 0o775
    output_directory = "${install_to}"
    output_file = "${output_directory}/minikube"
    install_to = "/usr/local/bin"
