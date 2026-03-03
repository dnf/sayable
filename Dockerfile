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
    # Elixir (pulls in Erlang/OTP as dependency)
    elixir \
    # Erlang/OTP + rebar3
    erlang-dev erlang-tools rebar3 \
    # rlwrap for Clojure REPL
    rlwrap \
    && rm -rf /var/lib/apt/lists/*

# .NET SDK 8.0 via Microsoft's apt repo
RUN curl -fsSL https://packages.microsoft.com/config/ubuntu/24.04/packages-microsoft-prod.deb -o /tmp/ms.deb \
    && dpkg -i /tmp/ms.deb && rm /tmp/ms.deb \
    && apt-get update && apt-get install -y --no-install-recommends dotnet-sdk-8.0 \
    && rm -rf /var/lib/apt/lists/*

# Swift 5.10 (URL pattern differs by architecture)
RUN ARCH="$(dpkg --print-architecture)" && \
    VER="5.10.1" && \
    if [ "$ARCH" = "arm64" ] || [ "$ARCH" = "aarch64" ]; then \
      URL="https://download.swift.org/swift-${VER}-release/ubuntu2404-aarch64/swift-${VER}-RELEASE/swift-${VER}-RELEASE-ubuntu24.04-aarch64.tar.gz"; \
    else \
      URL="https://download.swift.org/swift-${VER}-release/ubuntu2404/swift-${VER}-RELEASE/swift-${VER}-RELEASE-ubuntu24.04.tar.gz"; \
    fi && \
    curl -fsSL "$URL" | tar -C /usr/local --strip-components=2 -xz

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

# Elm via npm (after Node.js) — no arm64 Linux binary available
RUN ARCH="$(dpkg --print-architecture)" && \
    if [ "$ARCH" != "arm64" ] && [ "$ARCH" != "aarch64" ]; then \
      npm install -g elm elm-test; \
    else \
      echo "Skipping Elm: no arm64 Linux binary available"; \
    fi

# Haskell (GHC + cabal) via ghcup
RUN curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | \
    BOOTSTRAP_HASKELL_NONINTERACTIVE=1 \
    BOOTSTRAP_HASKELL_INSTALL_CABAL=1 \
    BOOTSTRAP_HASKELL_INSTALL_GHC=1 \
    sh
ENV PATH="/root/.ghcup/bin:${PATH}"

# Clojure CLI
RUN curl -fsSL https://download.clojure.org/install/linux-install.sh | bash

# Zig (extract to /opt/zig, symlink binary to /usr/local/bin)
RUN ARCH="$(dpkg --print-architecture)" && \
    ZIG_ARCH="$ARCH" && \
    if [ "$ARCH" = "amd64" ]; then ZIG_ARCH="x86_64"; fi && \
    if [ "$ARCH" = "arm64" ]; then ZIG_ARCH="aarch64"; fi && \
    mkdir -p /opt/zig && \
    curl -fsSL "https://ziglang.org/download/0.14.0/zig-linux-${ZIG_ARCH}-0.14.0.tar.xz" | tar -C /opt/zig --strip-components=1 -xJ && \
    ln -sf /opt/zig/zig /usr/local/bin/zig

# Dart SDK
RUN ARCH="$(dpkg --print-architecture)" && \
    curl -fsSL "https://storage.googleapis.com/dart-archive/channels/stable/release/latest/sdk/dartsdk-linux-${ARCH}-release.zip" -o /tmp/dart.zip && \
    unzip -q /tmp/dart.zip -d /opt && rm /tmp/dart.zip
ENV PATH="/opt/dart-sdk/bin:${PATH}"

# OCaml via opam
RUN apt-get update && apt-get install -y --no-install-recommends opam \
    && rm -rf /var/lib/apt/lists/* \
    && opam init --disable-sandboxing --yes \
    && eval $(opam env) \
    && opam install dune alcotest --yes
ENV PATH="/root/.opam/default/bin:${PATH}"

# just (task runner)
RUN curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to /usr/local/bin

WORKDIR /workspace

CMD ["bash"]
