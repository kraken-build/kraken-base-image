import sys

from formula import DownloadFileFormula


class YqFormula(DownloadFileFormula):

    platform = sys.platform
    version = "4.30.1"
    download_url = "https://github.com/mikefarah/yq/releases/download/v${version}/yq_${platform}_${archv2}"
    chmod = 0o775
    output_file = "${install_to}/yq"
    install_to = "/usr/local/bin"
