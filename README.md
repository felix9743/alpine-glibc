# 📦 alpine-glibc

**Automated build and release system for GNU C Library (glibc) packages on Alpine Linux.**

Alpine Linux uses `musl` libc by default. While efficient, this can break compatibility with pre-compiled binaries. This repository provides a GitHub Actions pipeline to generate **multi-architecture APK packages** for `glibc`, enabling seamless execution of glibc-linked applications on Alpine.

## ✨ Features

* **🔄 Auto-Update:** Automatically tracks and builds the latest `glibc` versions.
* **🏗️ Multi-Arch:** Native support for `x86_64` and `aarch64` (ARM64).
* **🛠️ Reproducible:** Built inside standardized Docker containers for consistency.
* **📦 Sub-package Support:** Includes `-dev`, `-bin`, and `-i18n` for full compatibility.

---

## 🚀 Installation & Usage

### 1. Identify Your Architecture
Determine your system architecture to pick the right assets:
```bash
uname -m

```

### 2. Download and Install

Replace `<VERSION>` and `<ARCH>` with your desired targets. We recommend installing both the base and the binary package.

```bash
# Example for v2.43 on aarch64
VERSION="2.43-r0"
ARCH="aarch64"

wget https://github.com/Jobians/alpine-glibc/releases/download/v2.43/glibc-${VERSION}-${ARCH}.apk
wget https://github.com/Jobians/alpine-glibc/releases/download/v2.43/glibc-bin-${VERSION}-${ARCH}.apk

# Install the packages
apk add --allow-untrusted glibc-${VERSION}-${ARCH}.apk glibc-bin-${VERSION}-${ARCH}.apk

```

### 3. Package Types

| Package | Description |
| --- | --- |
| `glibc` | **Required.** The core shared libraries. |
| `glibc-bin` | Helper binaries (ldconfig, etc). Recommended for most users. |
| `glibc-i18n` | Locale and localization data. |
| `glibc-dev` | Development headers (only needed if compiling software). |

---

## 🔧 Verification

After installation, verify that the glibc dynamic linker is working:

```bash
/usr/lib/glibc/bin/ldd --version

```

---

## 💖 Donate

If you like this project and want to support development, you can donate using crypto:

[Donate here](https://cwallet.com/t/TE6A6KMV)

## 📜 License

* **Project:** MIT License
* **glibc:** [GNU Lesser General Public License (LGPL)](https://www.gnu.org/licenses/lgpl-3.0.en.html)