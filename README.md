# Sayable

<img src="assets/warp-drive.png" alt="Captain, warp drive will be ready in 0 days, 0 hours, 0 minut..." width="400" style="margin-left:50px" align="right">

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE.md)

*A thoughtful collection of libraries for how humans actually speak.*

Sayable is a family of zero-dependency formatting libraries. Each library tackles a different aspect of human-friendly output — the kind of phrasing people use in conversation, not the kind machines produce.

## Libraries

### [sayable-age](age/) — 29 languages, 71 locales

Human-friendly age formatting — how parents actually talk about little ones.

```
"Newborn" · "2 weeks, 4 days" · "14 months" · "2 years, 3 months" · "4½ years"
```

### [sayable-duration](duration/) — Python, TypeScript

Human-friendly duration and relative time formatting.

### [sayable-time](time/) — Python, TypeScript

Human-friendly clock time formatting — tells time the way people talk.

### [sayable-date](date/) — Python, TypeScript

Human-friendly date formatting — how people reference dates in conversation.

## Design principles

Every Sayable library follows these principles:

- **Zero dependencies.** Pure standard-library code in every language. No runtime deps.
- **Polyglot.** Every library is implemented identically across many languages, sharing canonical test cases and locale data.
- **Localization-first.** Not just i18n — genuine localization. Culture-aware output, CLDR-compliant plural rules, and native speaker review for every locale.
- **Deterministic.** All tests use explicit inputs — no flaky tests from system state.

## Development

### Getting started

You can develop and test all implementations either natively on macOS/Linux or inside a Docker container.

#### Option A: Docker (no local toolchain setup)

Requires only [Docker](https://www.docker.com/). Builds a Linux container with all toolchains and runs the full test suite against your local checkout:

```bash
./.hecatron/tools/docker/test.sh          # build image + run all tests
./.hecatron/tools/docker/test.sh bash     # interactive shell inside the container
```

Your repo is bind-mounted into the container. Anonymous volumes keep platform-specific build artifacts isolated, so nothing on your host is modified.

#### Option B: Native setup

Bootstrap scripts install all language toolchains and project dependencies in one step:

```bash
# macOS (uses Homebrew)
./.hecatron/tools/bootstrap/macos.sh

# Ubuntu / Debian
./.hecatron/tools/bootstrap/linux.sh
```

The scripts are idempotent — safe to re-run if you need to pick up a missing tool later.

You can also install or uninstall individual languages:

```bash
just install go          # single language
just install ts py rb    # multiple (aliases work)
just install             # all languages
just uninstall go        # remove a language
```

### Commands

A top-level [`justfile`](https://github.com/casey/just) provides a single entry point for building, testing, and linting across all languages:

```bash
just test                # run all test suites + codegen check
just test go             # run one language's tests
just build               # build all languages with a build step
just lint                # run all available linters
just disable hs ada      # skip languages from parallel runs
just enable --all        # re-enable all disabled languages
just generate            # regenerate locale files from canonical JSON
just check               # verify generated files are up-to-date
just --list              # see all available commands
```

Language shortcuts: `ad`, `cb`, `ts`, `py`, `rb`, `rs`, `kt`, `gy`, `lu`, `ml`, `ft`, `c++`, `cs`, `fs`, `sw`, `hs`, `ex`, `erl`, `clj`, `el`, `gm`, `sc`, `zg` are accepted alongside full names.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines. All implementations share identical test cases — changes to formatting logic must be applied to all languages.

## License

[MIT](LICENSE.md)
