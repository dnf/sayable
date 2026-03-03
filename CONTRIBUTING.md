# Contributing to parent-time

Thanks for your interest in contributing! This project maintains identical implementations across many languages, so contributions follow a few specific patterns.

## Getting started

1. Fork and clone the repository
2. Install [just](https://github.com/casey/just) (the task runner)
3. Run `just test` to verify everything works — this runs all test suites in parallel

## Project structure

```
src/
  ada/  c/  clojure/  cobol/  cpp/  csharp/  dart/  elixir/  elm/  erlang/  fsharp/  fortran/  gleam/  go/  groovy/  haskell/
  java/  kotlin/  lua/  ocaml/  perl/  php/  python/  ruby/  rust/  scala/  swift/  typescript/  zig/
locales/       # 71 JSON files — single source of truth for locale data
codegen/
  targets/     # One emitter + plural rules per target language
  generate.py  # Orchestrator: loads JSON, runs emitters, writes files
tests/         # Canonical test specification
docs/          # Shared documentation
```

## Development workflow

The `justfile` is the primary task runner. With no arguments, commands run all languages in parallel:

```
just test          # all test suites + codegen check
just build         # all compiled languages
just lint          # all linters
just clean         # remove build artifacts
just disable hs    # temporarily skip a language from parallel runs
just enable --all  # re-enable all disabled languages
```

### Single-language commands

All commands below are prefixed with `just` (e.g., `just test cpp`):

| Language   | test                           | build                            | lint                           | clean                            |
| ---------- | ------------------------------ | -------------------------------- | ------------------------------ | -------------------------------- |
| Ada        | `test ada`<br>`test ad`        | `build ada`<br>`build ad`        | 🛠️                             | `clean ada`<br>`clean ad`        |
| C          | `test c`                       | `build c`                        | 🛠️                             | `clean c`                        |
| C#         | `test csharp`<br>`test cs`     | `build csharp`<br>`build cs`     | 🛠️                             | `clean csharp`<br>`clean cs`     |
| C++        | `test cpp`<br>`test c++`       | `build cpp`<br>`build c++`       | 🛠️                             | `clean cpp`<br>`clean c++`       |
| Clojure    | `test clojure`<br>`test clj`   | ⚡                                | 🛠️                             | `clean clojure`<br>`clean clj`   |
| COBOL      | `test cobol`<br>`test cb`      | `build cobol`<br>`build cb`      | 🛠️                             | `clean cobol`<br>`clean cb`      |
| Dart       | `test dart`<br>`test dt`       | ⚡                                | `lint dart`<br>`lint dt`       | `clean dart`<br>`clean dt`       |
| Elixir     | `test elixir`<br>`test ex`     | `build elixir`<br>`build ex`     | 🛠️                             | `clean elixir`<br>`clean ex`     |
| Elm        | `test elm`<br>`test el`        | ⚡                                | 🛠️                             | `clean elm`<br>`clean el`        |
| Erlang     | `test erlang`<br>`test erl`    | `build erlang`<br>`build erl`    | 🛠️                             | `clean erlang`<br>`clean erl`    |
| F#         | `test fsharp`<br>`test fs`     | `build fsharp`<br>`build fs`     | 🛠️                             | `clean fsharp`<br>`clean fs`     |
| Fortran    | `test fortran`<br>`test ft`    | `build fortran`<br>`build ft`    | 🛠️                             | `clean fortran`<br>`clean ft`    |
| Gleam      | `test gleam`<br>`test gm`      | `build gleam`<br>`build gm`      | 🛠️                             | `clean gleam`<br>`clean gm`      |
| Go         | `test go`                      | ⚡                                | `lint go`                      | ⚡                                |
| Groovy     | `test groovy`<br>`test gy`     | `build groovy`<br>`build gy`     | 🛠️                             | `clean groovy`<br>`clean gy`     |
| Haskell    | `test haskell`<br>`test hs`    | `build haskell`<br>`build hs`    | 🛠️                             | `clean haskell`<br>`clean hs`    |
| Java       | `test java`                    | `build java`                     | 🛠️                             | `clean java`                     |
| Kotlin     | `test kotlin`<br>`test kt`     | `build kotlin`<br>`build kt`     | 🛠️                             | `clean kotlin`<br>`clean kt`     |
| Lua        | `test lua`<br>`test lu`        | ⚡                                | `lint lua`<br>`lint lu`        | ⚡                                |
| OCaml      | `test ocaml`<br>`test ml`      | `build ocaml`<br>`build ml`      | 🛠️                             | `clean ocaml`<br>`clean ml`      |
| Perl       | `test perl`<br>`test pl`       | ⚡                                | 🛠️                             | ⚡                                |
| PHP        | `test php`                     | ⚡                                | `lint php`                     | ⚡                                |
| Python     | `test python`<br>`test py`     | ⚡                                | `lint python`<br>`lint py`     | `clean python`<br>`clean py`     |
| Ruby       | `test ruby`<br>`test rb`       | ⚡                                | `lint ruby`<br>`lint rb`       | ⚡                                |
| Rust       | `test rust`<br>`test rs`       | `build rust`<br>`build rs`       | `lint rust`<br>`lint rs`       | `clean rust`<br>`clean rs`       |
| Scala      | `test scala`<br>`test sc`      | `build scala`<br>`build sc`      | 🛠️                             | `clean scala`<br>`clean sc`      |
| Swift      | `test swift`<br>`test sw`      | `build swift`<br>`build sw`      | 🛠️                             | `clean swift`<br>`clean sw`      |
| TypeScript | `test typescript`<br>`test ts` | `build typescript`<br>`build ts` | `lint typescript`<br>`lint ts` | `clean typescript`<br>`clean ts` |
| Zig        | `test zig`<br>`test zg`        | `build zig`<br>`build zg`        | 🛠️                             | `clean zig`<br>`clean zg`        |

⚡ = interpreted, no build step needed · 🛠️ = linted via warnings-as-errors in build

### Logs

Every run captures output to `.logs/<action>/<language>.log` (e.g., `.logs/test/go.log`).

- **Parallel runs** (`just test`): output goes to log files only. The terminal shows a live progress summary. Failed jobs have their full output printed at the end.
- **Single-language runs** (`just test go`): output streams to the terminal and is simultaneously saved to the log file.

## Key principles

- **All implementations produce identical output** for the same inputs. Changes to formatting logic must be applied to all languages.
- **Deterministic tests.** Every test uses explicit `(dateOfBirth, asOf)` date pairs — never "today."
- **Zero dependencies.** No runtime dependencies in any language. Pure date arithmetic.
- **Spec-first testing.** The canonical test specification lives in [`tests/testing.md`](tests/testing.md). Add new test cases there first, then implement in all languages.

## Discuss before implementing

Because every change must work across all languages, please **open an issue before starting work** on anything beyond a small locale correction. This applies to new features, API changes, new locales, and non-trivial bug fixes. A quick discussion upfront prevents 10x wasted effort if the approach needs adjustment.

The only exception: if you're a native speaker fixing a translation or plural rule in a locale you know, go ahead and open a PR directly.

## Types of contributions

### Locale improvements

Native speaker feedback is especially welcome. If a translation sounds unnatural, a plural rule is wrong, or a stage label uses the wrong register, please open an issue or PR.

To fix a locale:

1. Edit the JSON file in `locales/{code}.json`
2. Run `python -m codegen.generate` to regenerate all language implementations
3. Run `just test` to verify

Never edit the generated locale files (e.g. `src/typescript/src/locales/fr.ts`) by hand — they will be overwritten by the generator. See [`codegen/README.md`](codegen/README.md) for full details.

See [`docs/gender-and-stages.md`](docs/gender-and-stages.md) for the gender analysis of stage labels.

### New locales

See [`docs/adding-a-locale.md`](docs/adding-a-locale.md) for a detailed guide. In short:

1. Identify the CLDR plural rule for the language (one of the 23 existing rules usually fits)
2. Create `locales/{code}.json` with the locale data
3. Run `python -m codegen.generate` to generate locale files in all languages
4. Add test cases to `tests/testing.md` and implement them in all test files
5. Run `just test`

### Bug fixes

If you find a discrepancy between implementations, file an issue with the input and the differing outputs. All implementations must match the spec in `tests/testing.md`.

The fastest way to get a bug fixed is to include a failing test case in the format used by [`tests/testing.md`](tests/testing.md). If you can't reproduce it with a specific date pair, we probably can't either.

### New features

Open an issue to discuss before implementing. Features must work across all languages, so design discussions help avoid wasted effort.

## What we won't merge

To save you time, here's what falls outside the project's scope:

- **Features that can't be implemented consistently across all languages.** If it relies on a language-specific capability, it doesn't fit.
- **Runtime dependencies.** The library is zero-dependency in every language. No exceptions.
- **Timezone or system locale detection.** The library takes explicit date strings and locale objects. It does not sniff the environment.
- **Date parsing or manipulation.** This library formats ages, not dates.

## Submitting a pull request

### Native speaker policy

Locale changes require native speaker verification before merging:

- If you're a native speaker, say so in your PR.
- If you're not a native speaker, your PR will be tagged for review by someone who is.
- For locales without an active native speaker reviewer, we may merge with a note and revisit if feedback arrives later.

### Checklist

Before submitting a PR, verify:

- [ ] Tests pass in all affected languages (`just test`)
- [ ] New test cases added to `tests/testing.md` first (if applicable)
- [ ] Locale changes reviewed by a native speaker (or self-attested)
- [ ] Locale changes made in `locales/*.json` and regenerated (not hand-edited)
- [ ] `just check` passes (codegen files up to date)
- [ ] All implementations updated (for logic/feature changes)
- [ ] No runtime dependencies added

### Commit messages

- Use imperative mood: "Add Finnish locale" not "Added Finnish locale"
- For locale PRs, name the locale: "Fix plural rules for Arabic (ar)"
- For cross-language changes, a single commit is preferred over one-per-language

### Code style

Each language follows its community conventions. There are no strict formatting requirements beyond what each language's linter enforces. See [`docs/code-quality.md`](docs/code-quality.md) for details.

CI runs all language test suites on every pull request. PRs that break any language will not be merged.

## License

By contributing, you agree that your contributions will be licensed under the [MIT License](LICENSE.md).
