#!/usr/bin/env bash
set -euo pipefail

BASE_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
source "$BASE_DIR/glibc_check.sh"

clang_make_require_glibc "2.27" "cxx20 clang18"

LLVM_NAME="clang+llvm-18.1.8-x86_64-linux-gnu-ubuntu-18.04"
LLVM_URL="https://github.com/llvm/llvm-project/releases/download/llvmorg-18.1.8/${LLVM_NAME}.tar.xz"
LIBTINFO_DEB="libtinfo5_6.2-0ubuntu2.1_amd64.deb"
LIBTINFO_URL="https://archive.ubuntu.com/ubuntu/pool/universe/n/ncurses/${LIBTINFO_DEB}"
DOWNLOAD_DIR="$BASE_DIR/downloads"
TOOLCHAIN_DIR="$BASE_DIR/toolchains"
ARCHIVE="$DOWNLOAD_DIR/${LLVM_NAME}.tar.xz"
INSTALL_DIR="$TOOLCHAIN_DIR/$LLVM_NAME"
LIBTINFO_DIR="$BASE_DIR/cxx20/libtinfo5"
LIBTINFO_MARKER="$LIBTINFO_DIR/.source-$LIBTINFO_DEB"
BIN_DIR="$BASE_DIR/cxx20/bin"

mkdir -p "$DOWNLOAD_DIR" "$TOOLCHAIN_DIR" "$BIN_DIR" "$LIBTINFO_DIR"

if [ ! -x "$INSTALL_DIR/bin/clang++" ]; then
    rm -rf "$INSTALL_DIR"
    if [ ! -f "$ARCHIVE" ]; then
        curl -L --fail --retry 3 -C - -o "$ARCHIVE" "$LLVM_URL"
    fi
    tar -xf "$ARCHIVE" -C "$TOOLCHAIN_DIR"
fi

if [ ! -f "$LIBTINFO_MARKER" ]; then
    rm -rf "$LIBTINFO_DIR"
    mkdir -p "$LIBTINFO_DIR"
    if [ ! -f "$DOWNLOAD_DIR/$LIBTINFO_DEB" ]; then
        curl -L --fail --retry 3 -o "$DOWNLOAD_DIR/$LIBTINFO_DEB" "$LIBTINFO_URL"
    fi
    dpkg-deb -x "$DOWNLOAD_DIR/$LIBTINFO_DEB" "$LIBTINFO_DIR"
    touch "$LIBTINFO_MARKER"
fi

ln -sfn "$LIBTINFO_DIR/lib/x86_64-linux-gnu/libtinfo.so.5" "$INSTALL_DIR/lib/libtinfo.so.5"

cat > "$BIN_DIR/clang++" <<EOF
#!/usr/bin/env bash
exec "$INSTALL_DIR/bin/clang++" "\$@"
EOF
chmod +x "$BIN_DIR/clang++"

"$BIN_DIR/clang++" --version | sed -n '1p'
