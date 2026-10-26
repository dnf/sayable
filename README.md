# Sayable

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE.md)

*A thoughtful collection of libraries for how humans actually speak.*

Sayable is a family of zero-dependency formatting libraries. Each library tackles a different aspect of human-friendly output — the kind of phrasing people use in conversation, not the kind machines produce.

## Libraries

<table>
<tr>
  <th></th>
  <th><a href="age/">age</a></th>
  <th><a href="date/">date</a></th>
  <th><a href="duration/">duration</a></th>
  <th><a href="time/">time</a></th>
</tr>
<tr>
  <td><strong>What it does</strong></td>
  <td>Formats ages the way parents talk</td>
  <td>Formats dates the way people reference them</td>
  <td>Formats durations and relative time</td>
  <td>Formats clock time conversationally</td>
</tr>
<tr>
  <td><strong>Example</strong></td>
  <td>"14 months" · "4½ years"</td>
  <td>"last Tuesday" · "3 days ago"</td>
  <td>"about 2 hours"</td>
  <td>"quarter past 3"</td>
</tr>
<tr>
  <td><strong>Languages</strong></td>
  <td>51</td>
  <td>51</td>
  <td>51</td>
  <td>51</td>
</tr>
<tr>
  <td><strong>Locales</strong></td>
  <td>168</td>
  <td>168</td>
  <td>168</td>
  <td>168</td>
</tr>
</table>

### Language support

All 51 languages have identical implementations across all 4 libraries:

Ada, Bash, C, C#, C++, Clojure, COBOL, Common Lisp, Crystal, D, Dart, Elixir, Elm, Erlang, F#, Fortran, Gleam, Go, Goose, Groovy, Haskell, Janet, Java, Julia, Kotlin, Lua, Mojo, Nim, OCaml, Octave, Odin, Pascal, Perl, Pharo, PHP, PowerShell, Prolog, Python, R, Racket, Raku, Ruby, Rust, Scala, Swift, Tcl, TypeScript, V, VB.NET, Wren, Zig

See the [full compatibility matrix](docs/compatibility.md).

### Locale coverage

See the [locale coverage maps](docs/geography/README.md) for a visual breakdown of how well Sayable's locales cover each country's languages.

[![World locale coverage](docs/geography/assets/world.png)](docs/geography/README.md)

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
