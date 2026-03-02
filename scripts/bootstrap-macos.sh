#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.."

echo "==> parent-time: macOS development setup"
echo ""

# ---- Homebrew ----
if ! command -v brew &>/dev/null; then
    echo "==> Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# ---- Language toolchains ----
echo "==> Installing toolchains via Homebrew..."
# brew install may return non-zero if a formula is already installed but
# can't be linked (e.g. python, composer). The tools are still usable.
brew install node python uv go ruby cmake php composer just openjdk@17 dotnet erlang rebar3 || true

# Make Java 17 available to /usr/libexec/java_home
OPENJDK_PATH="$(brew --prefix openjdk@17)/libexec/openjdk.jdk"
JVM_DIR="/Library/Java/JavaVirtualMachines/openjdk-17.jdk"
if [ -d "$OPENJDK_PATH" ] && [ ! -e "$JVM_DIR" ]; then
    echo "==> Symlinking OpenJDK 17 (requires sudo)..."
    sudo ln -sfn "$OPENJDK_PATH" "$JVM_DIR" || \
        echo "   Skipped (run manually: sudo ln -sfn $OPENJDK_PATH $JVM_DIR)"
fi

# Rust via rustup (consistent across platforms, avoids conflicts with brew rust)
if ! command -v rustc &>/dev/null; then
    echo "==> Installing Rust via rustup..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    # shellcheck source=/dev/null
    source "$HOME/.cargo/env"
fi

# Ensure Homebrew's Ruby is available (macOS system Ruby is too old)
BREW_RUBY="$(brew --prefix ruby)/bin"
if [ -d "$BREW_RUBY" ]; then
    export PATH="$BREW_RUBY:$PATH"
fi

# Ensure Homebrew's OpenJDK is available
BREW_JDK="$(brew --prefix openjdk@17)/bin"
if [ -d "$BREW_JDK" ]; then
    export PATH="$BREW_JDK:$PATH"
fi

# ---- Verify toolchains ----
echo "==> Verifying toolchains..."
MISSING=()
command -v node &>/dev/null    || MISSING+=(node)
command -v python3 &>/dev/null || MISSING+=(python3)
command -v uv &>/dev/null      || MISSING+=(uv)
command -v go &>/dev/null      || MISSING+=(go)
command -v ruby &>/dev/null    || MISSING+=(ruby)
command -v rustc &>/dev/null   || MISSING+=(rustc)
command -v cmake &>/dev/null   || MISSING+=(cmake)
command -v php &>/dev/null     || MISSING+=(php)
command -v composer &>/dev/null || MISSING+=(composer)
command -v java &>/dev/null    || MISSING+=(java)
command -v dotnet &>/dev/null  || MISSING+=(dotnet)
command -v swift &>/dev/null   || MISSING+=(swift)
command -v erl &>/dev/null     || MISSING+=(erl)
command -v rebar3 &>/dev/null  || MISSING+=(rebar3)
command -v just &>/dev/null    || MISSING+=(just)

if [ ${#MISSING[@]} -gt 0 ]; then
    echo ""
    echo "WARNING: These tools are not on your PATH: ${MISSING[*]}"
    echo "You may need to add Homebrew paths to your shell profile (~/.zshrc):"
    echo "  export PATH=\"$(brew --prefix ruby)/bin:\$PATH\""
    echo "  export PATH=\"$(brew --prefix openjdk@17)/bin:\$PATH\""
    echo ""
    exit 1
fi

# ---- Project dependencies ----
echo "==> Installing project dependencies..."
(cd src/typescript && npm install)
(cd src/python && uv sync --extra dev)
(cd src/ruby && bundle install)
(cd src/php && composer install)

echo ""
echo "==> Setup complete! Verify with: just test"
