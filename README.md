# 📦 alpine-glibc

**Automated build and release of GNU C Library (glibc) packages for Alpine Linux.**

Alpine Linux uses `musl libc` by default. This project provides a GitHub Actions pipeline generating **multi-architecture APK packages** for `glibc`, allowing the execution of glibc-linked binaries on Alpine — Python wheels, VS Code Server, Rust tools, etc.

## ✨ Features

* **🔄 Auto-Update**: automatically detects and builds new versions of glibc.
* **🏗️ Multi-Arch**: native support for `x86_64` and `aarch64` (ARM64) only.
* **🛠️ Reproducible**: built in standardized Docker containers.
* **📦 Sub-packages**: `glibc`, `glibc-bin`, `glibc-libs`, `glibc-i18n`, `glibc-dev`.
* **🔀 musl/glibc Switch**: `glibc-enable` / `glibc-disable` tools included in `glibc-bin`.

---

## 🚀 Fast Installation

```sh
# Downloads and installs all packages for your architecture
wget -qO- https://raw.githubusercontent.com/felix9743/alpine-glibc/main/install.sh | sh
```

---

## 📋 Manual Installation

### 1. Identify your architecture
```sh
uname -m  # x86_64 or aarch64
```

### 2. Download and install

```sh
VERSION="2.43"
ARCH=$(uname -m)

# Download
wget https://github.com/felix9743/alpine-glibc/releases/download/v${VERSION}/glibc-${VERSION}-${ARCH}.apk
wget https://github.com/felix9743/alpine-glibc/releases/download/v${VERSION}/glibc-bin-${VERSION}-${ARCH}.apk
wget https://github.com/felix9743/alpine-glibc/releases/download/v${VERSION}/glibc-libs-${VERSION}-${ARCH}.apk

# Installation (post-install scripts automatically configure symlinks and ldconfig)
apk add --allow-untrusted glibc-${VERSION}-${ARCH}.apk glibc-bin-${VERSION}-${ARCH}.apk glibc-libs-${VERSION}-${ARCH}.apk
```

---

## 📦 Package Description

| Package | Description | Source |
|---|---|---|
| `glibc` | **Required.** Core shared libraries. | Compiled from GNU sources |
| `glibc-bin` | Utilities: `ldconfig`, `ldd`, `glibc-enable`, `glibc-disable`. | Compiled from GNU sources |
| `glibc-libs` | **Runtime libs**: `libstdc++.so.6`, `libgcc_s.so.1`, `libtirpc.so.3`. | Extracted from Debian Trixie |
| `glibc-i18n` | Localization data (locales). | Compiled from GNU sources |
| `glibc-dev` | Development headers. | Compiled from GNU sources |

> **Why is `glibc-libs` separate from `glibc-bin`?**
> `libstdc++`, `libgcc_s` and `libtirpc` are not produced by the glibc build.
> `libtirpc` replaces the deprecated Sun RPC support removed from glibc >= 2.26.
> All are extracted from Debian Trixie to ensure ABI compatibility with Debian binaries.
> If these libs are ever compiled from source, they will be integrated into `glibc-bin`.

---

## 🔀 musl / glibc Switch

The `glibc-bin` package includes two tools to switch the system dynamic linker:

```sh
# Enable glibc as loader (automatic musl backup as .musl)
glibc-enable

# Restore musl
glibc-disable
```

---

## 🔧 Post-Installation Verification

```sh
# Verify glibc loader
/usr/lib/glibc/bin/ldd --version

# Verify system symlinks
ls -la /lib64/ld-linux-x86-64.so.2    # x86_64
ls -la /lib/x86_64-linux-gnu/libc.so.6
ls -la /usr/lib/x86_64-linux-gnu/libstdc++.so.6

# Verify ldconfig cache
cat /etc/ld.so.conf.d/glibc.conf

# Test glibc-linked Python wheel
uv python install 3.12-gnu
uv run --python 3.12-gnu python -c "import sys; print(sys.version)"
```

---

## 📁 Installation Structure

glibc files are installed under `/usr/lib/glibc/` (FHS standard path):

```
/usr/lib/glibc/
├── lib/          # shared libraries (.so)
├── bin/          # utilities (ldd, locale...)
├── sbin/         # ldconfig
├── share/        # i18n data
└── etc/          # ld.so.conf, ld.so.cache

/lib64/ld-linux-x86-64.so.2              → /usr/lib/glibc/lib/ld-linux-x86-64.so.2
/lib/x86_64-linux-gnu/libc.so.6          → /usr/lib/glibc/lib/libc.so.6
/usr/lib/x86_64-linux-gnu/libstdc++.so.6 → /usr/lib/glibc/lib/libstdc++.so.6
/usr/lib/x86_64-linux-gnu/libtirpc.so.3  → /usr/lib/glibc/lib/libtirpc.so.3
/etc/ld.so.conf.d/glibc.conf
```

---

## 🛠️ Manual Build (Local)

If you want to build the packages yourself without using GitHub Actions, follow these steps:

### 1. Prerequisites
- Docker (for the glibc compilation)
- Alpine Linux environment with `abuild`, `bash`, and `curl` (or an Alpine container)
- RSA keys for signing (`abuild-keygen -a -i`)

### 2. Build the glibc tarball
```sh
VERSION="2.43"
ARCH=$(uname -m)

# Build the Docker builder
docker build -f builder/Dockerfile -t glibc-builder .

# Run the build and save the tarball to the packaging directory
docker run --rm -e GLIBC_VERSION=$VERSION -e STDOUT=1 glibc-builder > packaging/glibc-${VERSION}-${ARCH}.tar.gz
```

### 3. Prepare Debian runtime libraries
You need `libstdc++.so.6`, `libgcc_s.so.1` and `libtirpc.so.3` from a Debian Trixie environment (or use a container):
```sh
# Example extraction steps:
mkdir -p pkg/usr/lib/glibc/lib
# Copy libstdc++.so.6, libgcc_s.so.1 and libtirpc.so.3 from a Debian system into pkg/usr/lib/glibc/lib/
tar -czf packaging/glibc-libs-${VERSION}-${ARCH}.tar.gz -C pkg .
```

### 4. Build APKs
```sh
cd packaging
# Ensure all source files (tarballs, scripts) are in the directory
abuild -r
```

---

## 📜 Licenses
* **Project**: MIT License
* **glibc**: [GNU Lesser General Public License (LGPL)](https://www.gnu.org/licenses/lgpl-3.0.en.html)
* **libstdc++ / libgcc_s**: [GCC Runtime Library Exception](https://www.gnu.org/licenses/gcc-exception-3.1.en.html) (extracted from Debian Trixie)
* **libtirpc**: [BSD 3-Clause License](https://sourceforge.net/p/libtirpc/git/ci/master/tree/COPYING) (extracted from Debian Trixie)