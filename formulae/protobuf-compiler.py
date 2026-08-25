import platform
import sys

from formula import UnixPackageFormula


class ProtobufCompilerFormula(UnixPackageFormula):

    arch = {"arm64": "aarch_64", "aarch64": "aarch_64"}.get(platform.machine(), platform.machine())
    platform = {"linux": "linux", "darwin": "osx"}[sys.platform]
    version = "36.0"
    archive_url = (
        "https://github.com/protocolbuffers/protobuf/releases/download/v${version}/"
        "protoc-${version}-${platform}-${arch}.zip"
    )
    upx_optimize = True
