#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.."

echo "==> parent-time: Linux development setup (Ubuntu/Debian)"
echo ""

# Use sudo only when not already root
SUDO=""
if [ "$(id -u)" -ne 0 ]; then
    SUDO="sudo"
fi

# ---- System packages ----
echo "==> Installing system packages..."
$SUDO apt-get update
$SUDO apt-get install -y \
    build-essential \
    cmake \
    curl \
    ca-certificates \
    git \
    gnupg \
    unzip \
    ruby ruby-bundler \
    php-cli php-xml php-mbstring \
    openjdk-17-jdk-headless \
    python3 python3-venv

# ---- Node.js 22 via NodeSource ----
if ! command -v node &>/dev/null || ! node -v | grep -q '^v2[2-9]'; then
    echo "==> Installing Node.js 22..."
    curl -fsSL https://deb.nodesource.com/setup_22.x | $SUDO bash -
    $SUDO apt-get install -y nodejs
fi

# ---- Go ----
if ! command -v go &>/dev/null; then
    echo "==> Installing Go..."
    ARCH="$(dpkg --print-architecture)"
    curl -fsSL "https://go.dev/dl/go1.21.13.linux-${ARCH}.tar.gz" | $SUDO tar -C /usr/local -xz
fi
export PATH="/usr/local/go/bin:$PATH"

# ---- Rust via rustup ----
if ! command -v rustc &>/dev/null; then
    echo "==> Installing Rust via rustup..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    # shellcheck source=/dev/null
    source "$HOME/.cargo/env"
fi

# ---- uv (Python package manager) ----
if ! command -v uv &>/dev/null; then
    echo "==> Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$HOME/.local/bin:$PATH"
fi

# ---- Composer (PHP package manager) ----
if ! command -v composer &>/dev/null; then
    echo "==> Installing Composer..."
    curl -sS https://getcomposer.org/installer | $SUDO php -- --install-dir=/usr/local/bin --filename=composer
fi

# ---- just (task runner) ----
if ! command -v just &>/dev/null; then
    echo "==> Installing just..."
    curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | $SUDO bash -s -- --to /usr/local/bin
fi

# ---- Project dependencies ----
echo "==> Installing project dependencies..."
(cd typescript && npm install)
(cd python && uv sync --extra dev)
(cd ruby && bundle install)
(cd php && composer install --ignore-platform-reqs)

# ---- Persist PATH for future shells ----
SHELL_RC="$HOME/.bashrc"
[ -n "${ZSH_VERSION:-}" ] && SHELL_RC="$HOME/.zshrc"
{
    echo ''
    echo '# Added by parent-time bootstrap'
    echo 'export PATH="/usr/local/go/bin:$PATH"'
    echo '[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"'
    echo 'export PATH="$HOME/.local/bin:$PATH"'
} >> "$SHELL_RC"

echo ""
echo "==> Setup complete! Verify with: just test"
echo ""
echo "PATH entries were added to $SHELL_RC."
echo "Run 'source $SHELL_RC' or open a new terminal, then run 'just test'."
