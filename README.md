# parent-time

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE.md)

*A thoughtful time formatting library that reflects how we think about little ones.*

```
"Newborn" · "2 weeks, 4 days" · "14 months" · "2 years, 3 months" · "4½ years"
```

Most age-formatting libraries just give you years, or maybe years and months. But parents of young children don't say "0 years" — they say "she's 6 weeks old" or "he just turned 14 months." `parent-time` formats ages the way parents and pediatricians actually talk, with human-friendly output in 22 languages, 71 locales, and three compactness levels.

## Implementations

| Language   | CI                                                                                                                                                                              | Package                                                                                                                                                                          | Install                                     | Docs                               |
| ---------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------- | ---------------------------------- |
| C          | [![C](https://github.com/dnf/parent-time/actions/workflows/c.yml/badge.svg?branch=main)](https://github.com/dnf/parent-time/actions/workflows/c.yml)                            | —                                                                                                                                                                                | CMake (freestanding)                        | [README](src/c/README.md)          |
| C#         | [![C#](https://github.com/dnf/parent-time/actions/workflows/csharp.yml/badge.svg?branch=main)](https://github.com/dnf/parent-time/actions/workflows/csharp.yml)                 | —                                                                                                                                                                                | NuGet                                       | [README](src/csharp/README.md)     |
| C++        | [![C++](https://github.com/dnf/parent-time/actions/workflows/cpp.yml/badge.svg?branch=main)](https://github.com/dnf/parent-time/actions/workflows/cpp.yml)                      | —                                                                                                                                                                                | CMake ([`FetchContent`](src/cpp/README.md)) | [README](src/cpp/README.md)        |
| Clojure    | [![Clojure](https://github.com/dnf/parent-time/actions/workflows/clojure.yml/badge.svg?branch=main)](https://github.com/dnf/parent-time/actions/workflows/clojure.yml)          | —                                                                                                                                                                                | deps.edn                                    | [README](src/clojure/README.md)    |
| Dart       | [![Dart](https://github.com/dnf/parent-time/actions/workflows/dart.yml/badge.svg?branch=main)](https://github.com/dnf/parent-time/actions/workflows/dart.yml)                   | —                                                                                                                                                                                | pub.dev                                     | [README](src/dart/README.md)       |
| Elixir     | [![Elixir](https://github.com/dnf/parent-time/actions/workflows/elixir.yml/badge.svg?branch=main)](https://github.com/dnf/parent-time/actions/workflows/elixir.yml)             | —                                                                                                                                                                                | Mix                                         | [README](src/elixir/README.md)     |
| Elm        | [![Elm](https://github.com/dnf/parent-time/actions/workflows/elm.yml/badge.svg?branch=main)](https://github.com/dnf/parent-time/actions/workflows/elm.yml)                      | —                                                                                                                                                                                | elm.json (application)                      | [README](src/elm/README.md)        |
| Erlang     | [![Erlang](https://github.com/dnf/parent-time/actions/workflows/erlang.yml/badge.svg?branch=main)](https://github.com/dnf/parent-time/actions/workflows/erlang.yml)             | —                                                                                                                                                                                | Rebar3                                      | [README](src/erlang/README.md)     |
| Go         | [![Go](https://github.com/dnf/parent-time/actions/workflows/go.yml/badge.svg?branch=main)](https://github.com/dnf/parent-time/actions/workflows/go.yml)                         | [![Go](https://img.shields.io/github/go-mod/go-version/dnf/parent-time?filename=src%2Fgo%2Fgo.mod&logo=go&label=go)](https://pkg.go.dev/github.com/dnf/parent-time/src/go)       | `go get github.com/dnf/parent-time/src/go`  | [README](src/go/README.md)         |
| Haskell    | [![Haskell](https://github.com/dnf/parent-time/actions/workflows/haskell.yml/badge.svg?branch=main)](https://github.com/dnf/parent-time/actions/workflows/haskell.yml)          | —                                                                                                                                                                                | Cabal                                       | [README](src/haskell/README.md)    |
| Java       | [![Java](https://github.com/dnf/parent-time/actions/workflows/java.yml/badge.svg?branch=main)](https://github.com/dnf/parent-time/actions/workflows/java.yml)                   | [![Maven Central](https://img.shields.io/maven-central/v/com.github.dnf/parent-time?logo=openjdk&label=maven)](https://central.sonatype.com/artifact/com.github.dnf/parent-time) | Gradle/Maven                                | [README](src/java/README.md)       |
| Kotlin     | [![Kotlin](https://github.com/dnf/parent-time/actions/workflows/kotlin.yml/badge.svg?branch=main)](https://github.com/dnf/parent-time/actions/workflows/kotlin.yml)             | [![Maven Central](https://img.shields.io/maven-central/v/com.github.dnf/parent-time?logo=kotlin&label=maven)](https://central.sonatype.com/artifact/com.github.dnf/parent-time)  | Gradle/Maven                                | [README](src/kotlin/README.md)     |
| OCaml      | [![OCaml](https://github.com/dnf/parent-time/actions/workflows/ocaml.yml/badge.svg?branch=main)](https://github.com/dnf/parent-time/actions/workflows/ocaml.yml)                | —                                                                                                                                                                                | Dune                                        | [README](src/ocaml/README.md)      |
| Perl       | [![Perl](https://github.com/dnf/parent-time/actions/workflows/perl.yml/badge.svg?branch=main)](https://github.com/dnf/parent-time/actions/workflows/perl.yml)                   | —                                                                                                                                                                                | `prove -Ilib`                               | [README](src/perl/README.md)       |
| PHP        | [![PHP](https://github.com/dnf/parent-time/actions/workflows/php.yml/badge.svg?branch=main)](https://github.com/dnf/parent-time/actions/workflows/php.yml)                      | [![Packagist](https://img.shields.io/packagist/v/dnf/parent-time?logo=packagist&label=packagist)](https://packagist.org/packages/dnf/parent-time)                                | `composer require dnf/parent-time`          | [README](src/php/README.md)        |
| Python     | [![Python](https://github.com/dnf/parent-time/actions/workflows/python.yml/badge.svg?branch=main)](https://github.com/dnf/parent-time/actions/workflows/python.yml)             | [![PyPI](https://img.shields.io/pypi/v/parent-time?logo=python&label=pypi)](https://pypi.org/project/parent-time/)                                                               | `pip install parent-time`                   | [README](src/python/README.md)     |
| Ruby       | [![Ruby](https://github.com/dnf/parent-time/actions/workflows/ruby.yml/badge.svg?branch=main)](https://github.com/dnf/parent-time/actions/workflows/ruby.yml)                   | [![Gem](https://img.shields.io/gem/v/parent_time?logo=rubygems&label=gem)](https://rubygems.org/gems/parent_time)                                                                | `gem install parent_time`                   | [README](src/ruby/README.md)       |
| Rust       | [![Rust](https://github.com/dnf/parent-time/actions/workflows/rust.yml/badge.svg?branch=main)](https://github.com/dnf/parent-time/actions/workflows/rust.yml)                   | [![Crates.io](https://img.shields.io/crates/v/parent-time?logo=rust&label=crates.io)](https://crates.io/crates/parent-time)                                                      | `parent-time = "0.1"`                       | [README](src/rust/README.md)       |
| Scala      | [![Scala](https://github.com/dnf/parent-time/actions/workflows/scala.yml/badge.svg?branch=main)](https://github.com/dnf/parent-time/actions/workflows/scala.yml)                | —                                                                                                                                                                                | Gradle                                      | [README](src/scala/README.md)      |
| Swift      | [![Swift](https://github.com/dnf/parent-time/actions/workflows/swift.yml/badge.svg?branch=main)](https://github.com/dnf/parent-time/actions/workflows/swift.yml)                | —                                                                                                                                                                                | SPM                                         | [README](src/swift/README.md)      |
| TypeScript | [![TypeScript](https://github.com/dnf/parent-time/actions/workflows/typescript.yml/badge.svg?branch=main)](https://github.com/dnf/parent-time/actions/workflows/typescript.yml) | [![npm](https://img.shields.io/npm/v/parent-time?logo=npm&label=npm)](https://www.npmjs.com/package/parent-time)                                                                 | `npm install parent-time`                   | [README](src/typescript/README.md) |
| Zig        | [![Zig](https://github.com/dnf/parent-time/actions/workflows/zig.yml/badge.svg?branch=main)](https://github.com/dnf/parent-time/actions/workflows/zig.yml)                      | —                                                                                                                                                                                | Zig build system                            | [README](src/zig/README.md)        |

All implementations produce identical output for the same inputs. See each language's README for installation, usage, and API details.

## CLI

A command-line tool for quick lookups, built on the C library:

```bash
just cli                                    # build cli/build/parent-time
```

```bash
parent-time age 2020-06-15                  # "5½ years"
parent-time age 2020-06-15 -l fr            # "5 ans et demi"
parent-time age 2020-06-15 --compact        # "5½y"
parent-time age 2020-06-15 -d 2021-01-01    # "6 months"
parent-time stage 2024-01-10 -l es -g f     # "Niña pequeña"
parent-time locales                         # list all 71 locale codes
```

| Flag              | Short | Default | Description                   |
| ----------------- | ----- | ------- | ----------------------------- |
| `--locale <code>` | `-l`  | `en`    | Locale code (e.g. `fr`, `ja`) |
| `--as-of <date>`  | `-d`  | today   | Reference date (YYYY-MM-DD)   |
| `--short`         |       |         | Short format                  |
| `--compact`       |       |         | Compact format                |
| `--gender <m\|f>` | `-g`  |         | Gender for stage labels       |

## Functions

### `formatAge` / `format_age` / `FormatAge`

Returns a human-readable age string with granularity that matches the child's developmental stage:

| Age range          | Format                     | Examples                    |
| ------------------ | -------------------------- | --------------------------- |
| Born today         | `"Newborn"`                | Newborn                     |
| 1–6 days           | `"N days"`                 | 1 day, 5 days               |
| 1 week – <3 months | `"N weeks, N days"`        | 2 weeks, 3 weeks, 4 days    |
| 3–23 months        | `"N months"`               | 3 months, 14 months         |
| 24–35 months       | `"N years, N months"`      | 2 years, 2 years, 7 months  |
| 3–6 years          | `"N years"` / `"N½ years"` | 3 years, 3½ years, 5½ years |
| 7+ years           | `"N years"`                | 7 years, 45 years           |

Calendar-month boundaries use **day-of-month clamping**: a child born on the 31st turns N months old on the last day of a shorter month (e.g., Feb 28/29, Apr 30).

### `formatStage` / `format_stage` / `FormatStage`

Returns the developmental stage label (AAP/CDC consensus boundaries):

| Stage    | Age range   |
| -------- | ----------- |
| Newborn  | 0–1 months  |
| Infant   | 2–11 months |
| Toddler  | 1–2 years   |
| Child    | 3–12 years  |
| Teenager | 13–17 years |
| Adult    | 18+ years   |

## Localization

71 built-in locales with CLDR-compliant plural rules. See the [locale documentation](docs/locales.md) for details on each language.

A core goal of this project is **localization**, not just internationalization. The library seeks to respect and align with the culture of each language — local customs about children may not always be reflected in sources such as CLDR. We actively welcome feedback and pull requests from native speakers of languages we support, or from native speakers who wish to add languages we do not currently support.

| Language                | Code  | Language   | Code | Language        | Code  |
| ----------------------- | ----- | ---------- | ---- | --------------- | ----- |
| Albanian                | `sq`  | German     | `de` | Polish          | `pl`  |
| Amharic                 | `am`  | Greek      | `el` | Portuguese      | `pt`  |
| Arabic                  | `ar`  | Gujarati   | `gu` | Punjabi         | `pa`  |
| Azerbaijani             | `az`  | Hebrew     | `he` | Romanian        | `ro`  |
| Basque                  | `eu`  | Hindi      | `hi` | Russian         | `ru`  |
| Bengali                 | `bn`  | Hungarian  | `hu` | Scottish Gaelic | `gd`  |
| Bosnian                 | `bs`  | Indonesian | `id` | Serbian         | `sr`  |
| Breton                  | `br`  | Irish      | `ga` | Sinhala         | `si`  |
| Bulgarian               | `bg`  | Italian    | `it` | Slovak          | `sk`  |
| Burmese                 | `my`  | Japanese   | `ja` | Slovenian       | `sl`  |
| Catalan                 | `ca`  | Javanese   | `jv` | Spanish         | `es`  |
| Central Atlas Tamazight | `tzm` | Kazakh     | `kk` | Swahili         | `sw`  |
| Chinese                 | `zh`  | Khmer      | `km` | Swedish         | `sv`  |
| Cornish                 | `kw`  | Korean     | `ko` | Tachelhit       | `shi` |
| Croatian                | `hr`  | Latvian    | `lv` | Tamil           | `ta`  |
| Czech                   | `cs`  | Lithuanian | `lt` | Telugu          | `te`  |
| Danish                  | `da`  | Macedonian | `mk` | Thai            | `th`  |
| Dutch                   | `nl`  | Malay      | `ms` | Turkish         | `tr`  |
| English                 | `en`  | Maltese    | `mt` | Ukrainian       | `uk`  |
| Estonian                | `et`  | Manx       | `gv` | Urdu            | `ur`  |
| Filipino                | `fil` | Marathi    | `mr` | Uzbek           | `uz`  |
| Finnish                 | `fi`  | Nepali     | `ne` | Vietnamese      | `vi`  |
| French                  | `fr`  | Norwegian  | `nb` | Welsh           | `cy`  |
| Georgian                | `ka`  | Persian    | `fa` |                 |       |

### Compactness

Each implementation supports three compactness levels:

| Level   | Example output                 |
| ------- | ------------------------------ |
| Normal  | "3 months", "2 years, 1 month" |
| Short   | "3 mo", "2 yr, 1 mo"           |
| Compact | "3m", "2y1m"                   |

Currently only the English locale defines distinct short/compact forms. Other locales return normal output for all three levels; you can add overrides via the locale's `short` and `compact` fields.

### Custom locales

Every implementation supports user-defined locale objects. See your language's README for the locale interface definition.

## Design decisions

- **Zero dependencies.** Pure date arithmetic — no runtime deps in any language.
- **Deterministic.** Every test uses explicit `(dob, asOf)` pairs. No flaky tests from "today."
- **Calendar-month clamping.** Born Jan 31 → turns 1 month on Feb 28 (or 29 in a leap year). This matches how hospitals and pediatricians count months.
- **"Months" not "1 year" at 12 months.** Parents say "he's 14 months" until about 2 years. The library follows this convention.
- **½ marker for 3–6 year olds.** Parents say "she's four and a half." The ½ character (U+00BD) kicks in at 6+ months and drops off at age 7.
- **"Newborn" at 0 days.** Because nobody says "0 days old."
- **Stage boundaries follow AAP/CDC.** Newborn (<2 mo), Infant (2–11 mo), Toddler (1–2 yr), Child (3–12 yr), Teenager (13–17 yr), Adult (18+).
- **Localization via locale objects.** No framework, no dependency — just a plain data object with a pluralization callback. Supports any language's plural rules, number formatting, and word order. Culture-aware, not just translation-aware.

## Testing

All implementations share a [canonical set of 212 test cases](tests/testing.md) covering null handling, all six age tiers, month-boundary clamping (including February and leap years), born-on-31st progression, stage labels, compactness levels, and i18n locale support.

The test specification in `tests/testing.md` is the single source of truth. Each implementation translates these cases into its native test framework. When adding a new test case, add it to the specification first, then implement it in all languages.

## Documentation

- [Test cases](tests/testing.md) — canonical test specification for all implementations
- [Locale configuration](docs/locales.md) — CLDR plural rules, per-language details
- [Code generator](codegen/README.md) — how locale files are generated from canonical JSON
- [Code quality](docs/code-quality.md) — linting, type checking, and static analysis configuration

## Development

### Getting started

You can develop and test all implementations either natively on macOS/Linux or inside a Docker container.

#### Option A: Docker (no local toolchain setup)

Requires only [Docker](https://www.docker.com/). Builds a Linux container with all toolchains and runs the full test suite against your local checkout:

```bash
./scripts/docker-test.sh          # build image + run all tests
./scripts/docker-test.sh bash     # interactive shell inside the container
```

Your repo is bind-mounted into the container. Anonymous volumes keep platform-specific build artifacts isolated, so nothing on your host is modified.

#### Option B: Native setup

Bootstrap scripts install all language toolchains and project dependencies in one step:

```bash
# macOS (uses Homebrew)
./scripts/bootstrap-macos.sh

# Ubuntu / Debian
./scripts/bootstrap-linux.sh
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
just generate            # regenerate locale files from canonical JSON
just check               # verify generated files are up-to-date
just lint                # run all available linters
just --list              # see all available commands
```

Language shortcuts: `ts`, `py`, `rb`, `rs`, `kt`, `ml`, `c++`, `cs`, `sw`, `hs`, `ex`, `erl`, `clj`, `el`, `sc`, `zg` are accepted alongside full names.

## Contributing

All implementations share identical test cases. If you add a test, add it in all directories. See each language's README for build and test commands, or use `just test <lang>` from the project root.

## License

[MIT](LICENSE.md)
