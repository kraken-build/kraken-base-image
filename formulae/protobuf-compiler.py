import platform
import sys

from formula import BinaryInstallFormula


class ProtobufCompilerFormula(BinaryInstallFormula):

    arch = {"arm64": "aarch_64", "aarch64": "aarch_64"}.get(platform.machine(), platform.machine())
    platform = {"linux": "linux", "darwin": "osx"}[sys.platform]
    version = "3.20.1"
    archive_url = (
        "https://github.com/protocolbuffers/protobuf/releases/download/v${version}/"
        "protoc-${version}-${platform}-${arch}.zip"
    )
    archive_members = ["bin/protoc"]
    install_to = "/usr/local/bin"
