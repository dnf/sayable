# CLAUDE.md

## What this project is

Sayable is a family of zero-dependency formatting libraries for how humans actually speak. There are four libraries, and they are peers built the same way: **sayable-age** ("6 weeks", "14 months", "3½ years"), **sayable-date** ("March 15th", "tomorrow"), **sayable-duration** ("about 2 hours", "3 days ago") and **sayable-time** ("a quarter past three"). Each has 51 identical implementations (Ada, Bash, C, C#, C++, Clojure, COBOL, Common Lisp, Crystal, D, Dart, Elixir, Elm, Erlang, F#, Fortran, Gleam, Go, Goose, Groovy, Haskell, Janet, Java, Julia, Kotlin, Lua, Mojo, Nim, OCaml, Octave, Odin, Pascal, Perl, Pharo, PHP, PowerShell, Prolog, Python, R, Racket, Raku, Ruby, Rust, Scala, Swift, Tcl, TypeScript, V, VB.NET, Wren, Zig) and 168 locales, shared across all four.

## Build and test commands

The `justfile` is the primary task runner. Running `just test`, `just build`, or `just lint` with no arguments runs all languages **in parallel**, capturing output to log files and printing a summary:

```
just test          # all test suites + codegen check, in parallel
just build         # all compiled languages, in parallel
just lint          # all linters, in parallel
```

Single-language commands stream to terminal and save to a log file:

```
just test go       # one language, all four libraries → .logs/test/go.log
just build rust    # one language, all four libraries → .logs/build/rust.log
just lint python   # one language, all four libraries → .logs/lint/python.log
```

All output is captured to `.logs/<command>/<language>.log` — both parallel and single-language runs.

| Shortcut           | Command                             |
| ------------------ | ----------------------------------- |
| Onboarding         | `just get-started`                  |
| Install langs      | `just install` or `just install go` |
| Check toolchains   | `just doctor` (`--fix` repairs)     |
| Uninstall langs    | `just uninstall go rust`            |
| Add languages      | `just add go rust`                  |
| Remove languages   | `just remove go rust`               |
| List languages     | `just list languages [--all]`       |
| Gen locales        | `just generate locales`             |
| Gen age/Dockerfile | `just dockerfile`                   |
| Quality check      | `just check`                        |
| Codegen tests      | `just test codegen`                 |
| CLI harness        | `just test cli` or `just test cli go` |
| Cross-language fuzz | `just fuzz` (`just fuzz help`)     |
| Update metadata    | `just metadata`                     |
| Maintain docs      | `just maintain docs`                |
| Clean artifacts    | `just clean` or `just clean <lang>` |

## Key rules

- **All implementations must produce identical output.** Changes to formatting logic must be applied to all languages.
- **Spec-first testing.** New test cases go in the library's `<library>/config/tests.json` first, then get implemented in all languages. Every test uses explicit inputs and reference dates — never "today."
- **Don't trust per-language test suites alone.** The generated CLI harness (`cli/test-harness.sh`, from `cli/generate-test-harness.py`) runs the canonical tests against every language's CLI through a single `sayable --repl` process, and `just fuzz` (`cli/fuzz.py`) sends random requests to every CLI and fails on any disagreement. Regenerate the harness after changing a `tests.json`. Every CLI must implement the REPL protocol in `cli/SPEC.md`. See [`docs/testing.md`](docs/testing.md).
- **Strict input parsing.** Dates, clock times and timestamps follow the exact grammar in [`docs/input-formats.md`](docs/input-formats.md) (real calendar days only, no unpadded or whitespace-padded input), and durations over 500 years have no value. Lenient parsing in one language is a cross-language divergence.
- **Canonical test IDs.** Every test must be annotated with the ID(s) from its library's `tests.json` that it implements — as a comment above the test or inline. `tools/check_test_ids.py` (part of `just check`) fails when a native suite never mentions a canonical ID. A test a language truly can't express gets a `<ID>: not applicable — <reason>` comment instead.
- **Zero runtime dependencies.** No exceptions in any language.
- **Locale data lives in `locales/<code>.json`, one file per language.** Each file holds the shared `code`, `name` and `pluralRule`, then a section per library (`age`, `date`, `duration`, `time`). It is the single source of truth for that language in every library and every programming language. To change a locale, edit its JSON file and run `just generate locales`. Never edit generated locale files by hand.
- **Generated locale files must be in their own subdirectory.** Every implementation (`<library>/impl/<lang>/`) places generated locale files in a dedicated `locales/` (or language-idiomatic equivalent) subdirectory, separate from hand-written source files.
- **Generated locale files and docs must be current.** `just generate locales` regenerates every library's locale code in every language, plus the generated docs: `docs/locales/<code>.md` (each locale's real output from all four libraries) and the `locales/README.md` index. `just check` verifies all of it in CI.
- **Generated files carry a prominent banner.** Every generated source file starts with a 9-line double-line box-frame `DO NOT EDIT` banner (from `tools/codegen_util.py`, re-exported by each `<library>/codegen/banner.py`; hecatron puts the same banner on the files it generates) referencing the generator. Locale files also include a `Source: locales/{code}.json` comment linking to the canonical JSON. Workflow files in `.github/workflows/` and the `age/Dockerfile` also carry this banner.
- **Every implementation must have a `<library>/impl/<lang>/README.md`** with API docs and a `## License` section linking to `LICENSE.md`. Each library's `README.md` table must link to it in the Docs column.
- **Every language must have a CI workflow** at `.github/workflows/<lang>.yml` that runs tests on push and PR to `main`. Use a version matrix when the language supports it.
- **Toolchains and per-language runs are hecatron's.** [hecatron](https://github.com/dnf/hecatron) (`brew install dnf/tap/hecatron`) installs, checks and repairs every language's toolchain and runs the per-language commands; the justfile delegates to it. Sayable's side is `.hecatron/config.json` (components, `implPath`, languages, tools, generated files, tasks) and its hooks in `.hecatron/languages/<lang>/`: `test.sh`, `lint.sh`, `build.sh`, `clean.sh`, `version.sh`, `metadata.sh` and `workflow.yml`. Installers, doctors and Dockerfile snippets come from hecatron; to change one, change it there (or override it with a file of the same name in `.hecatron/languages/<lang>/`). Key points:
  - `just doctor` checks every toolchain works; `just doctor --fix` runs the installer of each one that doesn't.
  - Shared toolchains (cmake→C/C++, .NET→C#/F#, JDK→Java/Kotlin/Scala/Groovy, Node→TypeScript/Elm) mean uninstalling one language can break another.
  - `just install` (all) continues past individual failures and reports them at the end.
- **Generated infrastructure.** Never edit `age/Dockerfile` or `.github/workflows/<lang>.yml` by hand: `just dockerfile` (`hecatron dockerfile`) builds the Dockerfile from each language's snippet, and `hecatron workflows` copies each `.hecatron/languages/<lang>/workflow.yml`. `just add` and `just remove` regenerate both; `just check` (`hecatron check`) verifies they're current and that every workflow tests every library.
- **A `just` command for one language acts on all four libraries.** `just test|lint|build|clean <lang>` run the language's hook once per library; `-c <library>` limits a run to one library (`just test go -c age`, or `just test` from inside `date/`). Never hard-code `age/impl/<lang>` in a recipe or hook.
- **Justfile recipes must support `help`/`--help`.** Recipes that delegate to hecatron get its help; sayable's own recipes must handle `help` and `--help` as a first argument the same way: Usage line, description, choices, flags and examples. Error messages print to stderr and point to help.

## Versioning

- **Each library's `<library>/config/version.json` is the single source of truth** for that library's version (all four are 0.5.0). All implementations and their package manifests must match it.
- **Every implementation exposes a version constant** using the idiomatic pattern for that language. See [`age/docs/versioning.md`](age/docs/versioning.md) for the full list.
- **The C version define lives in each library's C codegen emitter** (`<library>/codegen/targets/c/emitter.py`), because the C headers are generated. Run `just generate locales` after changing it.
- `just version <ver>` currently bumps **age only** (`age/config/version.json` and the per-language `version.sh` scripts); the other three libraries are bumped by hand until it covers them.

## Metadata

- **Each library's `<library>/config/metadata.json` is the source of truth** for its package metadata (description, author, license, repository URL). See [`age/docs/metadata.md`](age/docs/metadata.md) for details.
- Run `just metadata` to interactively update metadata across package manifests.
- `just metadata` and `just version` are separate commands: different concerns, different sources of truth, different change frequencies.

## Language management

- **`.hecatron/config.json`** lists the project's languages; `just add <lang>` / `just remove <lang>` edit it and regenerate the workflows and Dockerfile. Languages not in the list are refused by every command.
- **`.hecatron/local.json`** (gitignored) holds languages you've disabled for yourself: `just disable <lang>` skips them in parallel runs, `just enable` brings them back.
- `just list` shows the project's languages; `just list --all` shows every language hecatron knows, and whether its files come from hecatron or the project.
- Sayable's own recipes (benchmarks, the CLI harness) load hecatron's language lists and helpers with `eval "$(hecatron env)"` and run job lists with `hecatron parallel`.

## Project layout

```
locales/          # One JSON file per language (shared by all four libraries) + README index
age/              # sayable-age        } each library has the same layout:
date/             # sayable-date       }   config/   version.json, metadata.json, tests.json
duration/         # sayable-duration   }   codegen/  generate.py, banner.py, docgen.py, targets/<lang>/
time/             # sayable-time       }   impl/     <lang>/ (51 implementations) and impl/.gitignore
                  #                    }   docs/     library-specific docs
cli/              # sayable CLI for every language (REPL mode), test harness, fuzzer
docs/             # Cross-library docs: testing, input formats, compatibility, locales/<code>.md
tools/            # Repo-wide generators and checks (locale docs, compatibility, geography, workflow guard)
.hecatron/        # Build tooling and per-language definitions (installers, CI templates)
.github/          # CI workflows (generated from .hecatron/languages/<lang>/workflow.yml)
justfile          # Primary task runner
```

Each implementation follows the same pattern in every library: a formatter, a types/locale module, and a generated `locales/` subdirectory with one file (or one block) per locale. For example, sayable-age's formatter is `format_age.py` in Python, `formatter.rs` in Rust and `sayableage.zig` in Zig.

## Code style

- Each language follows its community conventions — no cross-language style mandates.
- Zero warnings in CI. When suppressing a lint, document why.
- **Name over comment.** When a line needs a comment to explain *what* it does, extract it into a named function or variable instead. The name replaces the comment. Comments should explain "why", not "what."
- Locale data files will have long lines — that's expected.
- **Markdown table alignment is optional.** `just maintain docs` can auto-align tables if desired, but it is not enforced in CI.
- Language-specific build artifacts (e.g., `_build/`, `dist-newstyle/`, `build/`) go in the library's `<library>/impl/.gitignore`, not the root `.gitignore`. The root `.gitignore` is for cross-language patterns only (e.g., `__pycache__/`, `.logs/`).
- **Gitignore sections must be alphabetically ordered.** In each `<library>/impl/.gitignore`, language sections are ordered alphabetically by language name (C, C#, C++, Clojure, …, Zig). In the root `.gitignore`, entries are also kept in alphabetical order.
- **Language properties live in hecatron's language definitions** (abbreviation, dependency, detection), so adding a language never means editing shared lists. Help text grids are generated from them too — never hardcode multi-language grid rows.
- **ANSI colors use two layers of named variables** in any script with colored output (hecatron's runner follows the same rule): raw ANSI escape codes are defined as `_c_*` base color variables (e.g., `_c_green`, `_c_red`, `_c_orange`), and semantic `_s_*` variables are built from them (e.g., `_s_pass="$_c_green"`, `_s_fail="$_c_red"`, `_s_run="$_c_yellow"`). Printf statements must use semantic `$_s_*` variables — never raw `\033[` codes or base `$_c_*` colors directly (except `$_c_reset`, `$_c_erase`, `$_c_bg256`, `$_c_fg256`, and `$_c_lane_idle` which are structural). To change a color, update the semantic variable; to add a new status, add a new `_s_*` variable.
- **Shell scripts pass shellcheck.** `just lint shell` (hecatron's shellcheck runner, also run in the Codegen workflow) checks every tracked bash/sh script at warning level. Generated scripts name their shell with a `# shellcheck shell=bash` directive; any `disable` carries a comment saying why.
- **Always brace-delimit shell variables.** Use `${var}` not `$var` in all shell scripts (justfile recipes, runner scripts, installer scripts). This ensures consistent style and prevents ambiguous variable boundaries. The only exception is positional parameters `$1`, `$2`, etc. and special variables `$?`, `$!`, `$$`, `$@`, `$*`, `$#` which remain unbraced.
- **Brace-delimit variables before Unicode characters in shell scripts.** Bash 3.2 (macOS default) treats many Unicode characters (⊘, ⚙, ✓, ✗, ◌, ▲, ▼, etc.) as valid identifier characters. Under `set -u`, `$_s_pass✓` is parsed as the variable `_s_pass✓` (unbound → crash), not `$_s_pass` followed by `✓`. Always use `${_s_pass}✓` with explicit braces when a variable is followed by a non-ASCII character. ASCII symbols (`-`, `%`, ` `, etc.) are safe delimiters.

## Adding a new locale

See [`docs/adding-a-locale.md`](docs/adding-a-locale.md) for the full guide. Summary:

1. Identify the CLDR plural rule — one of the 23 existing rules covers every CLDR cardinal pattern
2. Create `locales/{code}.json` with the shared fields and a section for each library (`age`, `date`, `duration`, `time`)
3. Run `just generate locales` — regenerates locale code in every library and language, and the docs
4. Run `just test && just test cli && just lint` to verify
5. Optionally add locale-specific test cases to the libraries' `tests.json` files

## Adding a new language

A language implements **all four libraries**, so for each `<library>` in age, date, duration and time:

1. Create `<library>/codegen/targets/<lang>/emitter.py` (and `plural_rules.py` with all 23 patterns for age and duration), and register it in `<library>/codegen/generate.py` (`_GENERATORS`)
2. Implement the types and formatter in `<library>/impl/<lang>/` (port from an existing implementation), with generated locales in a `locales/` subdirectory
3. Implement every case in `<library>/config/tests.json`, annotated with its ID
4. Create `<library>/impl/<lang>/README.md` with a `## License` section linking to `LICENSE.md`, and add a row to the library's README table

Then, once for the language:

5. Make sure hecatron has a definition for the language (installer, doctor, Dockerfile snippet; see [hecatron's guide](https://github.com/dnf/hecatron/blob/main/docs/adding-a-language.md)), then create sayable's hooks in `.hecatron/languages/<lang>/`: `test.sh` (runs one library's native suite), `build.sh` and `clean.sh` if it has a build, `lint.sh` if it has a separate linter, `version.sh` (optionally `metadata.sh`), and `workflow.yml` testing every library (`hecatron check` enforces this)
6. No justfile arms are needed: `just test|lint|build|clean <lang>` run those scripts once per library. Configure the language's linter with zero warnings, with the same config in every library
7. Add a CLI in `cli/impl/<lang>/` implementing `--repl` (`cli/SPEC.md`)
8. Run `just add <lang>` (adds it to `.hecatron/config.json`, generates its workflow, regenerates `age/Dockerfile`) and `python3 tools/generate_compatibility.py`
9. Update the language counts and lists (keep rows sorted alphabetically)
10. Verify: `just generate locales && just check && just test && just lint && just test cli <lang> && just fuzz --langs <lang>`

## Commit conventions

- Imperative mood: "Add Finnish locale" not "Added Finnish locale"
- For cross-language changes, prefer a single commit over one-per-language
- For locale PRs, name the locale: "Fix plural rules for Arabic (ar)"

## metaswarm

This project uses [metaswarm](https://github.com/dsifry/metaswarm) for multi-agent orchestration with Claude Code. It provides 18 specialized agents, a 9-phase development workflow, and quality gates that enforce TDD, coverage thresholds, and spec-driven development.

### Workflow

- **Most tasks**: `/start-task` — primes context, guides scoping, picks the right level of process
- **Complex features** (multi-file, spec-driven): Describe what you want built with a Definition of Done, then tell Claude: `Use the full metaswarm orchestration workflow.`

### Available Commands

| Command               | Purpose                                        |
| --------------------- | ---------------------------------------------- |
| `/start-task`         | Begin tracked work on a task                   |
| `/prime`              | Load relevant knowledge before starting        |
| `/review-design`      | Trigger parallel design review gate (5 agents) |
| `/pr-shepherd <pr>`   | Monitor a PR through to merge                  |
| `/self-reflect`       | Extract learnings after a PR merge             |
| `/handle-pr-comments` | Handle PR review comments                      |
| `/brainstorm`         | Refine an idea before implementation           |
| `/create-issue`       | Create a well-structured GitHub Issue          |

### Quality Gates

- **Design Review Gate** — Parallel 5-agent review after design is drafted (`/review-design`)
- **Plan Review Gate** — Automatic adversarial review after any implementation plan is drafted. Spawns 3 independent reviewers (Feasibility, Completeness, Scope & Alignment) in parallel — ALL must PASS before presenting the plan. See `skills/plan-review-gate/SKILL.md`
- **Coverage Gate** — `.coverage-thresholds.json` defines thresholds. BLOCKING gate before PR creation

### Team Mode

When `TeamCreate` and `SendMessage` tools are available, the orchestrator uses Team Mode for parallel agent dispatch. Otherwise it falls back to Task Mode (existing workflow, unchanged). See `guides/agent-coordination.md` for details.

### Guides

Development patterns and standards are documented in `guides/` — covering agent coordination, build validation, coding standards, git workflow, testing patterns, and worktree development.

### Testing & Quality

- **TDD is mandatory** — Write tests first, watch them fail, then implement
- **100% test coverage required** — Enforced via `.coverage-thresholds.json` as a blocking gate before PR creation and task completion
- **Coverage source of truth** — `.coverage-thresholds.json` defines thresholds. Update it if your spec requires different values. The orchestrator reads it during validation — this is a BLOCKING gate.

### Workflow Enforcement (MANDATORY)

These rules override any conflicting instructions from third-party skills:

- **After brainstorming** → MUST run Design Review Gate (5 agents) before writing-plans or implementation
- **After any plan is created** → MUST run Plan Review Gate (3 adversarial reviewers) before presenting to user
- **Execution method choice** → ALWAYS ask the user whether to use metaswarm orchestrated execution (more thorough, uses more tokens) or superpowers execution skills (faster, lighter-weight). Never auto-select.
- **Before finishing a branch** → MUST run `/self-reflect` and commit knowledge base updates before PR creation
- **Complex tasks** → Use `/start-task` instead of `EnterPlanMode` for tasks touching 3+ files. EnterPlanMode bypasses all quality gates.
- **Standalone TDD on 3+ files** → Ask user if they want adversarial review before committing
- **Coverage** → `.coverage-thresholds.json` is the single source of truth. All skills must check it, including `verification-before-completion`.
- **Subagents** → NEVER use `--no-verify`, ALWAYS follow TDD, NEVER self-certify, STAY within file scope
- **Context recovery** → Approved plans and execution state persist to `.beads/`. After compaction, run `bd prime --work-type recovery` to reload.
