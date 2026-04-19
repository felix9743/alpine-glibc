# builder/Dockerfile

# Use Ubuntu 24.04 as base
FROM ubuntu:24.04

# Metadata
LABEL org.opencontainers.image.authors="felix9743 <felix.9743@laposte.net>"
LABEL org.opencontainers.image.source="https://github.com/felix9743/alpine-glibc"
LABEL org.opencontainers.image.description="Build glibc binaries for Alpine Linux"

ENV DEBIAN_FRONTEND=noninteractive
ENV PREFIX_DIR=/usr/lib/glibc

# Install dependencies
RUN apt update -q && apt install -qy \
    bison \
    build-essential \
    curl \
    ca-certificates \
    gawk \
    gettext \
    linux-libc-dev \
    openssl \
    texinfo \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Installation de Node.js 24 LTS via le script officiel NodeSource
RUN curl -fsSL https://deb.nodesource.com/setup_24.x | bash - \
    && apt install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Install uv for modern Python management
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:$PATH"

# Install specific Python version via uv and link it as system python3
RUN uv python install 3.12 && ln -sf $(uv python find 3.12) /usr/bin/python3

# Create build directories
RUN mkdir -p /builder /glibc-build

# Copy build script
COPY builder/build-glibc.sh /builder/build-glibc.sh

# Copy configparams to the expected location
COPY builder/configparams /glibc-build/configparams

# Set working directory inside container
WORKDIR /builder

# Make sure script is executable
RUN chmod +x build-glibc.sh

# Entrypoint to build glibc
ENTRYPOINT ["./build-glibc.sh"]