#!/usr/bin/env bash

set -euo pipefail
[[ "${TRACE:-}" ]] && set -x

main() {
    version="${1:-${GLIBC_VERSION:?GLIBC version required}}"
    prefix="${2:-/usr/lib/glibc}"
    mirror="${GLIBC_MIRROR:-https://ftpmirror.gnu.org/libc}"
    output_dir="${OUTPUT_DIR:-/output}"

    SRC_DIR="/tmp/glibc-src"
    BUILD_DIR="/tmp/glibc-build"
    PKG_DIR="/tmp/glibc-pkg"

    # ALL logs must go to STDERR (>&2) to avoid corrupting STDOUT
    echo "Building glibc $version" >&2

    rm -rf "$SRC_DIR" "$BUILD_DIR" "$PKG_DIR"
    mkdir -p "$SRC_DIR" "$BUILD_DIR" "$PKG_DIR" "$output_dir"

    echo "Downloading and extracting glibc..." >&2
    wget -qO- "$mirror/glibc-$version.tar.gz" | tar -zxf - -C "$SRC_DIR" --strip-components=1

    cd "$BUILD_DIR"
    echo "Configuring in $BUILD_DIR..." >&2
    "$SRC_DIR/configure" \
        --prefix="$prefix" \
        --libdir="$prefix/lib" \
        --libexecdir="$prefix/lib" \
        --enable-multi-arch \
        --enable-stack-protector=strong \
        --disable-werror >&2 # Redirect configure output too

    echo "Compiling..." >&2
    make -j"$(nproc)" >&2

    echo "Installing..." >&2
    make install DESTDIR="$PKG_DIR" >&2

    echo "Packaging..." >&2
    tar -zcf "$output_dir/glibc-bin-$version.tar.gz" -C "$PKG_DIR" .

    echo "Build complete: $output_dir/glibc-bin-$version.tar.gz" >&2

    if [[ "${STDOUT:-}" == "1" ]]; then
        # Only the binary data hits STDOUT
        cat "$output_dir/glibc-bin-$version.tar.gz"
    fi
}

main "$@"