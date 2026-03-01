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
