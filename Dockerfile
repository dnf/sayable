FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# System packages + language runtimes available from distro
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    curl \
    ca-certificates \
    git \
    gnupg \
    unzip \
    # Ruby 3.2
    ruby \
    # PHP 8.3
    php-cli php-xml php-mbstring \
    # OpenJDK 17 (for Kotlin + Java)
    openjdk-17-jdk-headless \
    # Python 3.12
    python3 python3-venv \
    && rm -rf /var/lib/apt/lists/*

# .NET SDK 8.0 via Microsoft's apt repo
RUN curl -fsSL https://packages.microsoft.com/config/ubuntu/24.04/packages-microsoft-prod.deb -o /tmp/ms.deb \
    && dpkg -i /tmp/ms.deb && rm /tmp/ms.deb \
    && apt-get update && apt-get install -y --no-install-recommends dotnet-sdk-8.0 \
    && rm -rf /var/lib/apt/lists/*

# Swift 5.10
RUN ARCH="$(dpkg --print-architecture)" && \
    SWIFT_URL="https://download.swift.org/swift-5.10.1-release/ubuntu2404/${ARCH}/swift-5.10.1-RELEASE-ubuntu24.04-${ARCH}.tar.gz" && \
    curl -fsSL "$SWIFT_URL" | tar -C /usr/local --strip-components=2 -xz

# Node.js 22 via NodeSource
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && rm -rf /var/lib/apt/lists/*

# Go 1.21
RUN ARCH="$(dpkg --print-architecture)" && \
    curl -fsSL "https://go.dev/dl/go1.21.13.linux-${ARCH}.tar.gz" | tar -C /usr/local -xz
ENV PATH="/usr/local/go/bin:${PATH}"

# Rust stable via rustup
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# uv (Python package manager)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:${PATH}"

# Composer (PHP package manager)
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# just (task runner)
RUN curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to /usr/local/bin

WORKDIR /workspace

CMD ["bash"]
