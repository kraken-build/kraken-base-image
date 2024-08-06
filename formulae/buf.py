import sys

from formula import DownloadFileFormula


class BufFormula(DownloadFileFormula):

    platform = sys.platform.capitalize()
    version = "1.35.1"
    download_url = "https://github.com/bufbuild/buf/releases/download/v${version}/buf-${platform}-${archv1}"
    chmod = 0o775
    output_directory = "${install_to}"
    install_to = "/usr/local/bin"
