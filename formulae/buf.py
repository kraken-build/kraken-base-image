from formula import DownloadFileFormula


class BufFormula(DownloadFileFormula):

    version = "1.17.0"
    download_url = "https://github.com/bufbuild/buf/releases/download/v${version}/buf-Linux-${archv1}"
    install_to = "/usr/local/bin"
    output_file = "{install_to}/buf"
    chmod = 0o755
