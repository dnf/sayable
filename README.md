# Sayable

<img src="assets/warp-drive.png" alt="Captain, warp drive will be ready in 0 days, 0 hours, 0 minut..." width="400" style="margin-left:50px" align="right">

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE.md)

*A thoughtful collection of libraries for how humans actually speak.*

Sayable is a family of zero-dependency formatting libraries. Each library tackles a different aspect of human-friendly output — the kind of phrasing people use in conversation, not the kind machines produce.

## Libraries

| | [age](age/) | [date](date/) | [duration](duration/) | [time](time/) |
|---|---|---|---|---|
| **What it does** | Formats ages the way parents talk | Formats dates the way people reference them | Formats durations and relative time | Formats clock time conversationally |
| **Example** | "14 months" · "4½ years" | "last Tuesday" · "3 days ago" | "about 2 hours" | "quarter past 3" |
| **Languages** | 29 | 15 | 15 | 15 |
| **Locales** | 71 | — | — | — |

### Language support

| Language   | age | date | duration | time |
|------------|-----|------|----------|------|
| C++        | [✅](age/impl/cpp/) | [✅](date/impl/cpp/) | [✅](duration/impl/cpp/) | [✅](time/impl/cpp/) |
| Go         | [✅](age/impl/go/) | [✅](date/impl/go/) | [✅](duration/impl/go/) | [✅](time/impl/go/) |
| Java       | [✅](age/impl/java/) | [✅](date/impl/java/) | [✅](duration/impl/java/) | [✅](time/impl/java/) |
| Kotlin     | [✅](age/impl/kotlin/) | [✅](date/impl/kotlin/) | [✅](duration/impl/kotlin/) | [✅](time/impl/kotlin/) |
| Python     | [✅](age/impl/python/) | [✅](date/impl/python/) | [✅](duration/impl/python/) | [✅](time/impl/python/) |
| Ruby       | [✅](age/impl/ruby/) | [✅](date/impl/ruby/) | [✅](duration/impl/ruby/) | [✅](time/impl/ruby/) |
| Rust       | [✅](age/impl/rust/) | [✅](date/impl/rust/) | [✅](duration/impl/rust/) | [✅](time/impl/rust/) |
| TypeScript | [✅](age/impl/typescript/) | [✅](date/impl/typescript/) | [✅](duration/impl/typescript/) | [✅](time/impl/typescript/) |

Plus Ada, C, C#, Clojure, COBOL, Dart, Elixir, Elm, Erlang, F#, Fortran, Gleam, Groovy, Haskell, Lua, OCaml, Perl, PHP, Scala, Swift, and Zig. See the [full compatibility matrix](Compatibility.md).

## Design principles

- **Zero dependencies.** Pure standard-library code in every language.
- **Polyglot.** Identical implementations across languages, sharing canonical test cases and locale data.
- **Localization-first.** Culture-aware output with CLDR-compliant plural rules.
- **Deterministic.** All tests use explicit inputs — no flaky tests from system state.

## Development

### Getting started

Develop and test natively on macOS/Linux or inside a Docker container.

#### Docker (no local toolchain setup)

```bash
./.hecatron/tools/docker/test.sh          # build image + run all tests
./.hecatron/tools/docker/test.sh bash     # interactive shell inside the container
```

#### Native setup

```bash
# macOS (uses Homebrew)
./.hecatron/tools/bootstrap/macos.sh

# Ubuntu / Debian
./.hecatron/tools/bootstrap/linux.sh
```

Install or uninstall individual languages:

```bash
just install go          # single language
just install ts py rb    # multiple (aliases work)
just install             # all languages
just uninstall go        # remove a language
```

### Commands

A top-level [`justfile`](https://github.com/casey/just) provides a single entry point:

```bash
just test                # run all test suites + codegen check
just test go             # run one language's tests
just build               # build all compiled languages
just lint                # run all linters
just generate locales    # regenerate locale files from canonical JSON
just check               # verify generated files are up-to-date
just --list              # see all available commands
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines. All implementations share identical test cases — changes to formatting logic must be applied to all languages.

## License

[MIT](LICENSE.md)
