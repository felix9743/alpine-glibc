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
RUN apt-get update -q && apt-get install -qy \
    bison \
    build-essential \
    gawk \
    gettext \
    linux-libc-dev \
    openssl \
    python3 \
    texinfo \
    wget

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