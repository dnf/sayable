# Contributing to Sayable

Thanks for your interest in contributing! Sayable maintains identical implementations across many languages, so contributions follow a few specific patterns.

## Getting started

1. Fork and clone the repository
2. Install [just](https://github.com/casey/just) (the task runner)
3. Run `just test` to verify everything works — this runs all test suites in parallel

## Project structure

```
locales/           # One JSON file per language, shared by all four libraries: the single source of truth for locale data
age/               # sayable-age       } each library has the same layout:
date/              # sayable-date      }   config/   version.json, metadata.json, tests.json (canonical test spec)
duration/          # sayable-duration  }   codegen/  generate.py + targets/<lang>/ (one emitter per language)
time/              # sayable-time      }   impl/     <lang>/ for every language (ada/, bash/, c/, ... zig/)
                   #                   }   docs/     library-specific docs
cli/               # sayable CLI for every language, the generated test harness, the fuzzer
docs/              # Cross-library docs: testing, input formats, adding a locale, docs/locales/<code>.md examples
tools/             # Repo-wide generators and checks
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

`just test <lang>`, `just build <lang>`, `just lint <lang>` and `just clean <lang>` act on one language across all four libraries (`-c age` limits a run to one library). `just test help` lists every language with its short alias (`cs` for C#, `hs` for Haskell, ...). `just build` and `just lint` cover only the languages that have a build or a separate linter; the others are interpreted, or are linted by building with warnings as errors.

These commands are delegated to [hecatron](https://github.com/dnf/hecatron), which runs sayable's hooks in [`.hecatron/languages/<lang>/`](.hecatron/). See the [README](README.md#getting-started) to set it up.

### Logs

Every run captures output to `.logs/<action>/<language>.log` (e.g., `.logs/test/go.log`).

- **Parallel runs** (`just test`): output goes to log files only. The terminal shows a live progress summary. Failed jobs have their full output printed at the end.
- **Single-language runs** (`just test go`): output streams to the terminal and is simultaneously saved to the log file.

## Key principles

- **All implementations produce identical output** for the same inputs. Changes to formatting logic must be applied to all languages.
- **Deterministic tests.** Every test uses explicit `(dateOfBirth, asOf)` date pairs — never "today."
- **Zero dependencies.** No runtime dependencies in any language. Pure date arithmetic.
- **Spec-first testing.** Each library's canonical test specification lives in its `config/tests.json` (for example [`age/config/tests.json`](age/config/tests.json)). Add new test cases there first, then implement in all languages.
- **Don't trust a language's own tests.** Native suites are hand-written per language and can drift. The CLI harness (`just test cli`) runs the canonical spec against every language's CLI from one generated script, and the fuzz test (`just fuzz`) checks that every language gives the same answer to thousands of random requests. See [`docs/testing.md`](docs/testing.md).

## Discuss before implementing

Because every change must work across all languages, please **open an issue before starting work** on anything beyond a small locale correction. This applies to new features, API changes, new locales, and non-trivial bug fixes. A quick discussion upfront prevents 10x wasted effort if the approach needs adjustment.

The only exception: if you're a native speaker fixing a translation or plural rule in a locale you know, go ahead and open a PR directly.

## Types of contributions

### Locale improvements

Native speaker feedback is especially welcome. If a translation sounds unnatural, a plural rule is wrong, or a stage label uses the wrong register, please open an issue or PR.

Each language's data for all four libraries is in one file, `locales/{code}.json`: the shared `code`, `name` and `pluralRule`, then an `age`, `date`, `duration` and `time` section. The generated example page, [`docs/locales/{code}.md`](docs/locales/), shows what every library currently outputs for that locale, which is usually the quickest way to spot what sounds wrong.

To fix a locale:

1. Edit its section in `locales/{code}.json`
2. Run `just generate locales` to regenerate the locale code in every library and language, and the example pages
3. Run `just check`, `just test` and `just test cli` to verify

Never edit the generated locale files (e.g. `age/impl/typescript/src/locales/fr.ts`) or `docs/locales/*.md` by hand — they will be overwritten by the generator. See [`docs/adding-a-locale.md`](docs/adding-a-locale.md) for every field and [`age/codegen/README.md`](age/codegen/README.md) for how the generator works.

See [`age/docs/gender-and-stages.md`](age/docs/gender-and-stages.md) for the gender analysis of stage labels.

### New locales

See [`docs/adding-a-locale.md`](docs/adding-a-locale.md) for a detailed guide. In short:

1. Identify the CLDR plural rule for the language (one of the 23 existing rules covers every CLDR pattern)
2. Create `locales/{code}.json` with the shared fields and a section for each library (`age`, `date`, `duration`, `time`)
3. Run `just generate locales` to generate locale code in every library and language, plus `docs/locales/{code}.md`
4. Add test cases to the libraries' `config/tests.json` files and implement them in all test files
5. Run `just check`, `just test`, `just test cli` and `just fuzz`

### Bug fixes

If you find a discrepancy between implementations, file an issue with the input and the differing outputs. `just fuzz` finds these automatically and prints a reproducible seed. All implementations must match the spec in each library's `config/tests.json`.

The fastest way to get a bug fixed is to include a failing test case in the format used by [`age/config/tests.json`](age/config/tests.json). If you can't reproduce it with a specific date pair, we probably can't either.

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
- [ ] The CLI harness passes for affected languages (`just test cli <lang>`) and `just fuzz` reports no disagreements
- [ ] New test cases added to the library's `config/tests.json` first (if applicable), and the CLI harness regenerated (`python3 cli/generate-test-harness.py`)
- [ ] Locale changes reviewed by a native speaker (or self-attested)
- [ ] Locale changes made in `locales/*.json` and regenerated with `just generate locales` (not hand-edited)
- [ ] `just check` passes (generated code and locale docs up to date)
- [ ] All implementations updated (for logic/feature changes)
- [ ] No runtime dependencies added

### Commit messages

- Use imperative mood: "Add Finnish locale" not "Added Finnish locale"
- For locale PRs, name the locale: "Fix plural rules for Arabic (ar)"
- For cross-language changes, a single commit is preferred over one-per-language

### Code style

Each language follows its community conventions. There are no strict formatting requirements beyond what each language's linter enforces. See [`age/docs/code-quality.md`](age/docs/code-quality.md) for details.

CI runs all language test suites on every pull request. PRs that break any language will not be merged.

## License

By contributing, you agree that your contributions will be licensed under the [MIT License](LICENSE.md).
