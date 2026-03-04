# Sayable

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE.md)

*A thoughtful collection of libraries for how humans actually speak.*

Sayable is a family of zero-dependency formatting libraries. Each library tackles a different aspect of human-friendly output — the kind of phrasing people use in conversation, not the kind machines produce.

## Libraries

### [sayable-age](age/)

Human-friendly age formatting — how parents actually talk about little ones.

```
"Newborn" · "2 weeks, 4 days" · "14 months" · "2 years, 3 months" · "4½ years"
```

Most age-formatting libraries just give you years, or maybe years and months. But parents of young children don't say "0 years" — they say "she's 6 weeks old" or "he just turned 14 months." `sayable-age` formats ages the way parents and pediatricians actually talk, with human-friendly output in 29 languages, 71 locales, and three compactness levels.

| Language   | CI                                                                                                                                                                              | Package                                                                                                                                                                          | Install                                     | Docs                               |
| ---------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------- | ---------------------------------- |
| Ada        | [![Ada](https://github.com/dnf/sayable/actions/workflows/ada.yml/badge.svg?branch=main)](https://github.com/dnf/sayable/actions/workflows/ada.yml)                      | —                                                                                                                                                                                | GPRbuild                                    | [README](age/impl/ada/README.md)        |
| C          | [![C](https://github.com/dnf/sayable/actions/workflows/c.yml/badge.svg?branch=main)](https://github.com/dnf/sayable/actions/workflows/c.yml)                            | —                                                                                                                                                                                | CMake (freestanding)                        | [README](age/impl/c/README.md)          |
| C#         | [![C#](https://github.com/dnf/sayable/actions/workflows/csharp.yml/badge.svg?branch=main)](https://github.com/dnf/sayable/actions/workflows/csharp.yml)                 | —                                                                                                                                                                                | NuGet                                       | [README](age/impl/csharp/README.md)     |
| C++        | [![C++](https://github.com/dnf/sayable/actions/workflows/cpp.yml/badge.svg?branch=main)](https://github.com/dnf/sayable/actions/workflows/cpp.yml)                      | —                                                                                                                                                                                | CMake ([`FetchContent`](age/impl/cpp/README.md)) | [README](age/impl/cpp/README.md)        |
| Clojure    | [![Clojure](https://github.com/dnf/sayable/actions/workflows/clojure.yml/badge.svg?branch=main)](https://github.com/dnf/sayable/actions/workflows/clojure.yml)          | —                                                                                                                                                                                | deps.edn                                    | [README](age/impl/clojure/README.md)    |
| COBOL      | [![COBOL](https://github.com/dnf/sayable/actions/workflows/cobol.yml/badge.svg?branch=main)](https://github.com/dnf/sayable/actions/workflows/cobol.yml)                | —                                                                                                                                                                                | CMake (GnuCOBOL)                            | [README](age/impl/cobol/README.md)      |
| Dart       | [![Dart](https://github.com/dnf/sayable/actions/workflows/dart.yml/badge.svg?branch=main)](https://github.com/dnf/sayable/actions/workflows/dart.yml)                   | —                                                                                                                                                                                | pub.dev                                     | [README](age/impl/dart/README.md)       |
| Elixir     | [![Elixir](https://github.com/dnf/sayable/actions/workflows/elixir.yml/badge.svg?branch=main)](https://github.com/dnf/sayable/actions/workflows/elixir.yml)             | —                                                                                                                                                                                | Mix                                         | [README](age/impl/elixir/README.md)     |
| Elm        | [![Elm](https://github.com/dnf/sayable/actions/workflows/elm.yml/badge.svg?branch=main)](https://github.com/dnf/sayable/actions/workflows/elm.yml)                      | —                                                                                                                                                                                | elm.json (application)                      | [README](age/impl/elm/README.md)        |
| Erlang     | [![Erlang](https://github.com/dnf/sayable/actions/workflows/erlang.yml/badge.svg?branch=main)](https://github.com/dnf/sayable/actions/workflows/erlang.yml)             | —                                                                                                                                                                                | Rebar3                                      | [README](age/impl/erlang/README.md)     |
| F#         | [![F#](https://github.com/dnf/sayable/actions/workflows/fsharp.yml/badge.svg?branch=main)](https://github.com/dnf/sayable/actions/workflows/fsharp.yml)                 | —                                                                                                                                                                                | NuGet                                       | [README](age/impl/fsharp/README.md)     |
| Fortran    | [![Fortran](https://github.com/dnf/sayable/actions/workflows/fortran.yml/badge.svg?branch=main)](https://github.com/dnf/sayable/actions/workflows/fortran.yml)          | —                                                                                                                                                                                | CMake (Modern Fortran 2008+)                | [README](age/impl/fortran/README.md)    |
| Gleam      | [![Gleam](https://github.com/dnf/sayable/actions/workflows/gleam.yml/badge.svg?branch=main)](https://github.com/dnf/sayable/actions/workflows/gleam.yml)                | —                                                                                                                                                                                | Gleam build system                          | [README](age/impl/gleam/README.md)      |
| Go         | [![Go](https://github.com/dnf/sayable/actions/workflows/go.yml/badge.svg?branch=main)](https://github.com/dnf/sayable/actions/workflows/go.yml)                         | [![Go](https://img.shields.io/github/go-mod/go-version/dnf/sayable?filename=age%2Fimpl%2Fgo%2Fgo.mod&logo=go&label=go)](https://pkg.go.dev/github.com/dnf/sayable/age/impl/go)       | `go get github.com/dnf/sayable/age/impl/go`  | [README](age/impl/go/README.md)         |
| Groovy     | [![Groovy](https://github.com/dnf/sayable/actions/workflows/groovy.yml/badge.svg?branch=main)](https://github.com/dnf/sayable/actions/workflows/groovy.yml)             | —                                                                                                                                                                                | Gradle                                      | [README](age/impl/groovy/README.md)     |
| Haskell    | [![Haskell](https://github.com/dnf/sayable/actions/workflows/haskell.yml/badge.svg?branch=main)](https://github.com/dnf/sayable/actions/workflows/haskell.yml)          | —                                                                                                                                                                                | Cabal                                       | [README](age/impl/haskell/README.md)    |
| Java       | [![Java](https://github.com/dnf/sayable/actions/workflows/java.yml/badge.svg?branch=main)](https://github.com/dnf/sayable/actions/workflows/java.yml)                   | [![Maven Central](https://img.shields.io/maven-central/v/com.github.dnf/sayable-age?logo=openjdk&label=maven)](https://central.sonatype.com/artifact/com.github.dnf/sayable-age) | Gradle/Maven                                | [README](age/impl/java/README.md)       |
| Kotlin     | [![Kotlin](https://github.com/dnf/sayable/actions/workflows/kotlin.yml/badge.svg?branch=main)](https://github.com/dnf/sayable/actions/workflows/kotlin.yml)             | [![Maven Central](https://img.shields.io/maven-central/v/com.github.dnf/sayable-age?logo=kotlin&label=maven)](https://central.sonatype.com/artifact/com.github.dnf/sayable-age)  | Gradle/Maven                                | [README](age/impl/kotlin/README.md)     |
| Lua        | [![Lua](https://github.com/dnf/sayable/actions/workflows/lua.yml/badge.svg?branch=main)](https://github.com/dnf/sayable/actions/workflows/lua.yml)                      | —                                                                                                                                                                                | Plain module (local)                        | [README](age/impl/lua/README.md)        |
| OCaml      | [![OCaml](https://github.com/dnf/sayable/actions/workflows/ocaml.yml/badge.svg?branch=main)](https://github.com/dnf/sayable/actions/workflows/ocaml.yml)                | —                                                                                                                                                                                | Dune                                        | [README](age/impl/ocaml/README.md)      |
| Perl       | [![Perl](https://github.com/dnf/sayable/actions/workflows/perl.yml/badge.svg?branch=main)](https://github.com/dnf/sayable/actions/workflows/perl.yml)                   | —                                                                                                                                                                                | `prove -Ilib`                               | [README](age/impl/perl/README.md)       |
| PHP        | [![PHP](https://github.com/dnf/sayable/actions/workflows/php.yml/badge.svg?branch=main)](https://github.com/dnf/sayable/actions/workflows/php.yml)                      | [![Packagist](https://img.shields.io/packagist/v/dnf/sayable-age?logo=packagist&label=packagist)](https://packagist.org/packages/dnf/sayable-age)                                | `composer require dnf/sayable-age`          | [README](age/impl/php/README.md)        |
| Python     | [![Python](https://github.com/dnf/sayable/actions/workflows/python.yml/badge.svg?branch=main)](https://github.com/dnf/sayable/actions/workflows/python.yml)             | [![PyPI](https://img.shields.io/pypi/v/sayable-age?logo=python&label=pypi)](https://pypi.org/project/age/)                                                               | `pip install sayable-age`                   | [README](age/impl/python/README.md)     |
| Ruby       | [![Ruby](https://github.com/dnf/sayable/actions/workflows/ruby.yml/badge.svg?branch=main)](https://github.com/dnf/sayable/actions/workflows/ruby.yml)                   | [![Gem](https://img.shields.io/gem/v/sayable_age?logo=rubygems&label=gem)](https://rubygems.org/gems/sayable_age)                                                                | `gem install sayable_age`                   | [README](age/impl/ruby/README.md)       |
| Rust       | [![Rust](https://github.com/dnf/sayable/actions/workflows/rust.yml/badge.svg?branch=main)](https://github.com/dnf/sayable/actions/workflows/rust.yml)                   | [![Crates.io](https://img.shields.io/crates/v/sayable-age?logo=rust&label=crates.io)](https://crates.io/crates/sayable-age)                                                      | `sayable-age = "0.1"`                       | [README](age/impl/rust/README.md)       |
| Scala      | [![Scala](https://github.com/dnf/sayable/actions/workflows/scala.yml/badge.svg?branch=main)](https://github.com/dnf/sayable/actions/workflows/scala.yml)                | —                                                                                                                                                                                | Gradle                                      | [README](age/impl/scala/README.md)      |
| Swift      | [![Swift](https://github.com/dnf/sayable/actions/workflows/swift.yml/badge.svg?branch=main)](https://github.com/dnf/sayable/actions/workflows/swift.yml)                | —                                                                                                                                                                                | SPM                                         | [README](age/impl/swift/README.md)      |
| TypeScript | [![TypeScript](https://github.com/dnf/sayable/actions/workflows/typescript.yml/badge.svg?branch=main)](https://github.com/dnf/sayable/actions/workflows/typescript.yml) | [![npm](https://img.shields.io/npm/v/sayable-age?logo=npm&label=npm)](https://www.npmjs.com/package/sayable-age)                                                                 | `npm install sayable-age`                   | [README](age/impl/typescript/README.md) |
| Zig        | [![Zig](https://github.com/dnf/sayable/actions/workflows/zig.yml/badge.svg?branch=main)](https://github.com/dnf/sayable/actions/workflows/zig.yml)                      | —                                                                                                                                                                                | Zig build system                            | [README](age/impl/zig/README.md)        |

All 29 implementations produce identical output for the same inputs. See each language's README for installation, usage, and API details.

#### CLI

A command-line tool for quick lookups, built on the C library:

```bash
just cli                                    # build cli/build/sayable-age
```

```bash
sayable-age age 2020-06-15                  # "5½ years"
sayable-age age 2020-06-15 -l fr            # "5 ans et demi"
sayable-age age 2020-06-15 --compact        # "5½y"
sayable-age age 2020-06-15 -d 2021-01-01    # "6 months"
sayable-age stage 2024-01-10 -l es -g f     # "Niña pequeña"
sayable-age locales                         # list all 71 locale codes
```

| Flag              | Short | Default | Description                   |
| ----------------- | ----- | ------- | ----------------------------- |
| `--locale <code>` | `-l`  | `en`    | Locale code (e.g. `fr`, `ja`) |
| `--as-of <date>`  | `-d`  | today   | Reference date (YYYY-MM-DD)   |
| `--short`         |       |         | Short format                  |
| `--compact`       |       |         | Compact format                |
| `--gender <m\|f>` | `-g`  |         | Gender for stage labels       |

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
