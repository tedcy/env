#!/usr/bin/env bash
set -euo pipefail

BASE_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
source "$BASE_DIR/glibc_check.sh"

clang_make_require_glibc "2.27" "cxx17 clang14"

LLVM_NAME="clang+llvm-14.0.0-x86_64-linux-gnu-ubuntu-18.04"
LLVM_URL="https://github.com/llvm/llvm-project/releases/download/llvmorg-14.0.0/${LLVM_NAME}.tar.xz"
DOWNLOAD_DIR="$BASE_DIR/downloads"
TOOLCHAIN_DIR="$BASE_DIR/toolchains"
ARCHIVE="$DOWNLOAD_DIR/${LLVM_NAME}.tar.xz"
INSTALL_DIR="$TOOLCHAIN_DIR/$LLVM_NAME"
BIN_DIR="$BASE_DIR/cxx17/bin"

mkdir -p "$DOWNLOAD_DIR" "$TOOLCHAIN_DIR" "$BIN_DIR"

if [ ! -x "$INSTALL_DIR/bin/clang++" ]; then
    rm -rf "$INSTALL_DIR"
    if [ ! -f "$ARCHIVE" ]; then
        curl -L --fail --retry 3 -C - -o "$ARCHIVE" "$LLVM_URL"
    fi
    tar -xf "$ARCHIVE" -C "$TOOLCHAIN_DIR"
fi

cat > "$BIN_DIR/clang++" <<EOF
#!/usr/bin/env bash
exec "$INSTALL_DIR/bin/clang++" "\$@"
EOF
chmod +x "$BIN_DIR/clang++"

"$BIN_DIR/clang++" --version | sed -n '1p'
