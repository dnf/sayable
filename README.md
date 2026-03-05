# Sayable

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE.md)

*A thoughtful collection of libraries for how humans actually speak.*

<table width="100%" frame="2">
<tr>
<td valign="top" style="width:50%">
Sayable is a family of zero-dependency formatting libraries. Each library tackles a different aspect of human-friendly output — the kind of phrasing people use in conversation, not the kind machines produce.
</td>
<td style="width:50%">
<img style="text-align: center; width:300px;", src="assets/warp-drive.png" alt="Captain, warp drive will be ready in 0 days, 0 hours, 0 minut...">
</td>
</tr>
</table>

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
  <td>29</td>
  <td>15</td>
  <td>15</td>
  <td>15</td>
</tr>
<tr>
  <td><strong>Locales</strong></td>
  <td>71</td>
  <td>71</td>
  <td>71</td>
  <td>71</td>
</tr>
</table>

### Language support

<table>
<tr>
  <th>Language</th>
  <th align="center">Age</th>
  <th align="center">Date</th>
  <th align="center">Duration</th>
  <th align="center">Time</th>
</tr>
<tr>
  <td>C++</td>
  <td align="center"><a href="age/impl/cpp/">✅</a></td>
  <td align="center"><a href="date/impl/cpp/">✅</a></td>
  <td align="center"><a href="duration/impl/cpp/">✅</a></td>
  <td align="center"><a href="time/impl/cpp/">✅</a></td>
</tr>
<tr>
  <td>Go</td>
  <td align="center"><a href="age/impl/go/">✅</a></td>
  <td align="center"><a href="date/impl/go/">✅</a></td>
  <td align="center"><a href="duration/impl/go/">✅</a></td>
  <td align="center"><a href="time/impl/go/">✅</a></td>
</tr>
<tr>
  <td>Java</td>
  <td align="center"><a href="age/impl/java/">✅</a></td>
  <td align="center"><a href="date/impl/java/">✅</a></td>
  <td align="center"><a href="duration/impl/java/">✅</a></td>
  <td align="center"><a href="time/impl/java/">✅</a></td>
</tr>
<tr>
  <td>Kotlin</td>
  <td align="center"><a href="age/impl/kotlin/">✅</a></td>
  <td align="center"><a href="date/impl/kotlin/">✅</a></td>
  <td align="center"><a href="duration/impl/kotlin/">✅</a></td>
  <td align="center"><a href="time/impl/kotlin/">✅</a></td>
</tr>
<tr>
  <td>Python</td>
  <td align="center"><a href="age/impl/python/">✅</a></td>
  <td align="center"><a href="date/impl/python/">✅</a></td>
  <td align="center"><a href="duration/impl/python/">✅</a></td>
  <td align="center"><a href="time/impl/python/">✅</a></td>
</tr>
<tr>
  <td>Ruby</td>
  <td align="center"><a href="age/impl/ruby/">✅</a></td>
  <td align="center"><a href="date/impl/ruby/">✅</a></td>
  <td align="center"><a href="duration/impl/ruby/">✅</a></td>
  <td align="center"><a href="time/impl/ruby/">✅</a></td>
</tr>
<tr>
  <td>Rust</td>
  <td align="center"><a href="age/impl/rust/">✅</a></td>
  <td align="center"><a href="date/impl/rust/">✅</a></td>
  <td align="center"><a href="duration/impl/rust/">✅</a></td>
  <td align="center"><a href="time/impl/rust/">✅</a></td>
</tr>
<tr>
  <td>TypeScript</td>
  <td align="center"><a href="age/impl/typescript/">✅</a></td>
  <td align="center"><a href="date/impl/typescript/">✅</a></td>
  <td align="center"><a href="duration/impl/typescript/">✅</a></td>
  <td align="center"><a href="time/impl/typescript/">✅</a></td>
</tr>
</table>

Plus Ada, C, C#, Clojure, COBOL, Dart, Elixir, Elm, Erlang, F#, Fortran, Gleam, Groovy, Haskell, Lua, OCaml, Perl, PHP, Scala, Swift, and Zig. See the [full compatibility matrix](Compatibility.md).

### Locale coverage

See the [locale coverage maps](docs/geography/README.md) for a visual breakdown of how well Sayable's locales cover each country's languages.

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
