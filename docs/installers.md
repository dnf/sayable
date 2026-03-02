# Language Installers

Per-language installer scripts live in `scripts/installers/`. Each script handles both macOS and Linux, and accepts `install` or `uninstall` subcommands.

## Commands

```bash
just install                # install all available languages
just install go rust        # install specific languages
just uninstall go rust      # uninstall specific languages
just get-started            # interactive onboarding with status + install menu
just get-started --status   # print language status table
just get-started --check    # exit 0 if all installed, 1 if missing
```

Short aliases work everywhere: `just install ts py rb rs kt c++ cs sw hs ex erl clj sc zg el pl`

Misspelled names get a "did you mean?" prompt (e.g. `just install elixer` suggests `elixir`).

## Shared toolchains

Some languages share a toolchain. Uninstalling one affects the others.

| Toolchain  | Languages       | Effect of uninstalling any one                                   |
| ---------- | --------------- | ---------------------------------------------------------------- |
| cmake      | C, C++          | Both lose build capability until reinstalled                     |
| JDK 17     | Java, Kt, Scala | Protected: `just uninstall java` is a no-op (prints a message)   |
| Node.js    | TypeScript, Elm | Elm depends on npm; Elm installer auto-installs Node if missing  |
| Erlang/OTP | Erlang, Elixir  | Elixir depends on Erlang runtime; uninstall Erlang breaks Elixir |

## Architecture limitations

Some languages lack pre-built binaries on certain architectures. The installer system detects this and skips unavailable languages with a clear message.

| Language   | x86_64 Linux | arm64 Linux | macOS (any) | Notes                                     |
| ---------- | ------------ | ----------- | ----------- | ----------------------------------------- |
| Elm        | Yes          | No          | Yes         | No arm64 Linux binary (elm/compiler#2292) |
| All others | Yes          | Yes         | Yes         |                                           |

`just get-started` shows unavailable languages with `–` instead of `✓`/`✗` in the status table.

## Platform behavior

### macOS

Most languages install via Homebrew. Exceptions:
- **Perl** — uses system Perl (no install needed)
- **Swift** — uses Xcode Swift (no install needed)
- **Rust** — installed via rustup (not Homebrew, to avoid conflicts)
- **Haskell** — installed via ghcup (GHC + cabal)
- **Elm** — installed via `npm install -g` (requires Node.js)

### Linux

Languages install via a mix of apt packages and direct downloads:

| Method           | Languages                                                   |
| ---------------- | ----------------------------------------------------------- |
| apt packages     | C/C++ (cmake), C# (dotnet), Elixir, Erlang, Perl, PHP, Ruby |
| Direct download  | Go, Swift, Zig                                              |
| Installer script | Clojure, Haskell (ghcup), Rust (rustup), Python (uv)        |
| npm global       | Elm, TypeScript (Node via NodeSource apt)                   |
| Shared           | Java/Kotlin/Scala (OpenJDK 17 via apt)                      |

### Uninstall caveats

| Language      | Caveat                                                                 |
| ------------- | ---------------------------------------------------------------------- |
| Java/Kt/Scala | No-op — JDK is shared; prints message instead of removing              |
| Perl          | No-op on macOS (system Perl); removed on Linux                         |
| Swift (Linux) | No-op — Swift installs many files in /usr/local; manual cleanup needed |

## Installer script structure

Each script sources `scripts/installers/_common.sh` for shared helpers:

- `has()` — check if a command exists
- `apt_install()` — apt-get install with auto cache refresh
- `brew_install()` — brew install with `|| true`
- `$OS` — `"macos"` or `"linux"`
- `$SUDO` — `"sudo"` or `""` (when root)

Template:

```bash
#!/usr/bin/env bash
source "$(dirname "$0")/_common.sh"

install_macos() { ... }
install_linux() { ... }
uninstall_macos() { ... }
uninstall_linux() { ... }
deps() { ... }  # project-specific setup (npm install, etc.)

case "${1:-}" in
    install)   log "Installing Foo..."; "install_${OS}"; deps ;;
    uninstall) log "Uninstalling Foo..."; "uninstall_${OS}" ;;
    *)         echo "Usage: $0 {install|uninstall}" >&2; exit 1 ;;
esac
```
