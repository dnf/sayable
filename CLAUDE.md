# CLAUDE.md

## What this project is

Sayable is a family of zero-dependency formatting libraries for how humans actually speak. The first component is **sayable-age**, which formats ages the way parents talk ("6 weeks", "14 months", "3½ years"). It has 29 identical implementations (Ada, C, C#, C++, Clojure, COBOL, Dart, Elixir, Elm, Erlang, F#, Fortran, Gleam, Go, Groovy, Haskell, Java, Kotlin, Lua, OCaml, Perl, PHP, Python, Ruby, Rust, Scala, Swift, TypeScript, Zig) and 71 locales.

## Build and test commands

The `justfile` is the primary task runner. Running `just test`, `just build`, or `just lint` with no arguments runs all languages **in parallel**, capturing output to log files and printing a summary:

```
just test          # all test suites + codegen check, in parallel
just build         # all compiled languages, in parallel
just lint          # all linters, in parallel
```

Single-language commands stream to terminal and save to a log file:

```
just test go       # run one suite   → .logs/test/go.log
just build rust    # build one       → .logs/build/rust.log
just lint python   # lint one        → .logs/lint/python.log
```

All output is captured to `.logs/<command>/<language>.log` — both parallel and single-language runs.

| Shortcut           | Command                             |
| ------------------ | ----------------------------------- |
| Onboarding         | `just get-started`                  |
| Install langs      | `just install` or `just install go` |
| Uninstall langs    | `just uninstall go rust`            |
| Add languages      | `just add go rust`                  |
| Remove languages   | `just remove go rust`               |
| List languages     | `just list languages [--all]`       |
| Gen locales        | `just generate locales`             |
| Gen age/Dockerfile | `just dockerfile`                   |
| Quality check      | `just check`                        |
| Codegen tests      | `just test codegen`                 |
| Update metadata    | `just metadata`                     |
| Maintain docs      | `just maintain docs`                |
| Clean artifacts    | `just clean` or `just clean <lang>` |

## Key rules

- **All implementations must produce identical output.** Changes to formatting logic must be applied to all languages.
- **Spec-first testing.** New test cases go in `age/config/tests.json` first, then get implemented in all languages. Every test uses explicit `(dateOfBirth, asOf)` date pairs — never "today."
- **Canonical test IDs.** Every test must be annotated with the ID(s) from `age/config/tests.json` that it implements — as a comment above the test or inline. This enables cross-language verification that all tests map to their canonical definition.
- **Zero runtime dependencies.** No exceptions in any language.
- **Locale data lives in `age/locales/*.json`.** These JSON files are the single source of truth. To change a locale, edit the JSON file and run `just generate locales` to regenerate all language implementations. Never edit generated locale files by hand.
- **Generated locale files must be in their own subdirectory.** Every language implementation must place generated locale files in a dedicated `age/locales/` (or language-idiomatic equivalent) subdirectory, separate from hand-written source files.
- **Generated locale files and docs must be current.** Run `just generate locales` after editing `age/locales/*.json`. `just check` verifies this in CI.
- **Generated files carry a prominent banner.** Every generated file starts with a 9-line double-line box-frame `DO NOT EDIT` banner (from `.hecatron/tools/age/codegen/util.py`, re-exported by `age/codegen/banner.py`) referencing the generator and source path. Locale files also include a `Source: age/locales/{code}.json` comment linking to the canonical JSON. Workflow files in `.github/workflows/` and the `age/Dockerfile` also carry this banner.
- **Every language must have a `age/impl/<lang>/README.md`** with API docs and a `## License` section linking to `LICENSE.md`. The root `README.md` table must link to it in the Docs column.
- **Every language must have a CI workflow** at `.github/workflows/<lang>.yml` that runs tests on push and PR to `main`. Use a version matrix when the language supports it.
- **Installer scripts** live in `.hecatron/languages/<lang>/` as separate single-purpose files (`install.sh`, `uninstall.sh`, `version.sh`, and optionally `metadata.sh`). See [`.hecatron/age/docs/installers.md`](.hecatron/age/docs/installers.md) for the full reference. Key points:
  - Shared toolchains (cmake→C/C++, .NET→C#/F#, JDK→Java/Kotlin/Scala/Groovy, Node→TypeScript/Elm) mean uninstalling one language can break another.
  - JDK uninstall is a no-op (shared by 4 languages). Perl and Swift on macOS are also no-ops (system-provided).
  - `just install` (all) continues past individual failures and reports them at the end.
  - Elm has no arm64 Linux binary; the installer detects this and skips with a message.
- **The age/Dockerfile is generated.** Never edit `age/Dockerfile` by hand. Each language has a `.hecatron/languages/<lang>/dockerfile` snippet with `# apt:` directives (collected, deduplicated, sorted into one `apt-get install`), optional `# after:` ordering constraints, and literal `RUN`/`ENV` blocks. Run `just dockerfile` to regenerate. `just add` and `just remove` regenerate automatically. `just check` verifies the age/Dockerfile is current.
- **Justfile recipes must support `help`/`--help`.** Every recipe that accepts language arguments (test, build, lint, clean, install, uninstall) must handle `help` and `--help` as a first argument, printing usage with a consistent structure: Usage line, description, language list (alphabetical, with abbreviations), flags (if applicable), and examples. Error messages for unknown languages should print to stderr and point to help (e.g. `"try 'just test help'"`), not dump inline language lists.

## Versioning

- **`age/config/version.json` is the single source of truth** for the library version. All implementations and their package manifests must match it.
- **Every implementation exposes a version constant** using the idiomatic pattern for that language. See [`age/docs/versioning.md`](age/docs/versioning.md) for the full list.
- **The C version define lives in the codegen emitter** (`age/codegen/targets/c/emitter.py`) because `sayableage.h` is auto-generated. Run `just generate locales` after changing it.
- When bumping the version, update `age/config/version.json`, all source constants, all package manifests, and the C codegen emitter.

## Metadata

- **`age/config/metadata.json` is the single source of truth** for project metadata (description, author, license, repository URL). See [`age/docs/metadata.md`](age/docs/metadata.md) for details.
- Run `just metadata` to interactively update metadata across all package manifests.
- `just metadata` and `just version` are separate commands — different concerns, different sources of truth (`age/config/metadata.json` and `age/config/version.json`), different change frequencies.

## Language management

- **Per-language config** lives in `.hecatron/languages/<lang>/config.json` (abbreviation, dependency, compiled, hasClean, hasLint). **`.hecatron/config/languages/added.json`** is the active language list. **`.hecatron/config/languages/disabled.json`** is a gitignored array for temporarily disabling languages from parallel runs. **`.hecatron/config/languages.json`** holds only the `tools` object.
- The `added` array controls which languages are targets for all commands (test, build, lint, clean, install, uninstall). Removed languages are refused by all commands, including explicit single-language runs like `just test go`.
- `just add <lang>` and `just remove <lang>` modify the `added` array and sync CI workflows (add copies `.hecatron/languages/<lang>/workflow.yml` to `.github/workflows/<lang>.yml`; remove deletes it). Abbreviations are accepted.
- `just list languages` shows active languages. `just list languages --all` shows all known languages with added/removed status.
- `.hecatron/tools/language/emit-config.py` reads language configs and emits shell variables + functions for `eval` in `.hecatron/tools/language/helpers.sh`. Language management scripts (add, remove, list, install, uninstall, enable, disable) live in `.hecatron/tools/language/`.

## Project layout

```
age/                (first component)
  src/
    ada/       # Ada        cpp/       # C++       gleam/     # Gleam
    c/         # C          csharp/    # C#        go/        # Go
    clojure/   # Clojure    dart/      # Dart      groovy/    # Groovy
    cobol/     # COBOL      elixir/    # Elixir    haskell/   # Haskell
    ...        (29 languages total)
  config/      # Project configuration (version.json, metadata.json, tests.json)
  tests/       # Test documentation
  locales/     # Canonical locale JSON files (single source of truth)
  codegen/     # Locale code generator (JSON → all languages)
  docs/        # Shared docs, locale docs
.hecatron/     # Build tooling (stays at root, shared across future components)
.github/       # CI workflows
justfile       # Primary task runner
```

Core files per language follow a consistent pattern:
- Formatter: `sayableage.adb`, `sayableage.c` (generated), `formatter.clj`, `sayableage.cpp`, `SayableAge.cs`, `format_age.dart`, `formatter.ex`, `Formatter.elm`, `sayableage_formatter.erl`, `Formatter.fs`, `sayableage.f90`, `formatter.gleam`, `sayableage.go`, `SayableAge.groovy`, `Formatter.hs`, `SayableAge.java`, `SayableAge.kt`, `sayableage.lua`, `formatter.ml`, `Formatter.pm`, `SayableAge.php`, `format_age.py`, `formatter.rb`, `formatter.rs`, `SayableAge.scala`, `SayableAge.swift`, `format-age.ts`, `sayableage.zig`
- Types/Locale: `sayableage_types.ads`, `sayableage.h` (generated), (maps), `types.hpp`, `AgeLocale.cs`, `types.dart`, `locale.ex`, `Types.elm`, `sayableage.hrl`, `Types.fs`, `sayableage_types.f90`, `types.gleam`, `locale.go`, `AgeLocale.groovy`, `Types.hs`, `AgeLocale.java`, `Types.kt`, (tables), `types.ml`, `Locale.pm`, `AgeLocale.php`, `locale.py`, `locale.rb`, `types.rs`, `Types.scala`, `AgeLocale.swift`, `locale.ts`, `locales.zig` (generated)
- Locale data files: `locales/` subdirectory (one file per locale)

## Code style

- Each language follows its community conventions — no cross-language style mandates.
- Zero warnings in CI. When suppressing a lint, document why.
- **Name over comment.** When a line needs a comment to explain *what* it does, extract it into a named function or variable instead. The name replaces the comment. Comments should explain "why", not "what."
- Locale data files will have long lines — that's expected.
- **Markdown table alignment is optional.** `just maintain docs` can auto-align tables if desired, but it is not enforced in CI.
- Language-specific build artifacts (e.g., `_build/`, `dist-newstyle/`, `build/`) go in `age/impl/.gitignore`, not the root `.gitignore`. The root `.gitignore` is for cross-language patterns only (e.g., `__pycache__/`, `.logs/`).
- **Gitignore sections must be alphabetically ordered.** In `age/impl/.gitignore`, language sections are ordered alphabetically by language name (C, C#, C++, Clojure, …, Zig). In the root `.gitignore`, entries are also kept in alphabetical order.
- **One language per line in justfile lists.** Language lists (`_ALL_LANGS`, `_COMPILED_LANGS`, etc.), abbreviation maps (`_name()`, `_abbr()`), and dependency maps (`_dep()`) all live in `.hecatron/tools/language/helpers.sh` with one entry per `case` arm. This prevents merge conflicts when multiple branches add languages concurrently. Help text grids are generated dynamically from these lists — never hardcode multi-language grid rows.
- **ANSI colors use two layers of named variables.** In `.hecatron/tools/runner/run-parallel.sh`, raw ANSI escape codes are defined as `_c_*` base color variables (e.g., `_c_green`, `_c_red`, `_c_orange`), and semantic `_s_*` variables are built from them (e.g., `_s_pass="$_c_green"`, `_s_fail="$_c_red"`, `_s_run="$_c_yellow"`). Printf statements must use semantic `$_s_*` variables — never raw `\033[` codes or base `$_c_*` colors directly (except `$_c_reset`, `$_c_erase`, `$_c_bg256`, `$_c_fg256`, and `$_c_lane_idle` which are structural). To change a color, update the semantic variable; to add a new status, add a new `_s_*` variable.
- **Always brace-delimit shell variables.** Use `${var}` not `$var` in all shell scripts (justfile recipes, runner scripts, installer scripts). This ensures consistent style and prevents ambiguous variable boundaries. The only exception is positional parameters `$1`, `$2`, etc. and special variables `$?`, `$!`, `$$`, `$@`, `$*`, `$#` which remain unbraced.
- **Brace-delimit variables before Unicode characters in shell scripts.** Bash 3.2 (macOS default) treats many Unicode characters (⊘, ⚙, ✓, ✗, ◌, ▲, ▼, etc.) as valid identifier characters. Under `set -u`, `$_s_pass✓` is parsed as the variable `_s_pass✓` (unbound → crash), not `$_s_pass` followed by `✓`. Always use `${_s_pass}✓` with explicit braces when a variable is followed by a non-ASCII character. ASCII symbols (`-`, `%`, ` `, etc.) are safe delimiters.

## Adding a new locale

See [`age/docs/adding-a-locale.md`](age/docs/adding-a-locale.md) for the full guide. Summary:

1. Identify the CLDR plural rule — one of the 23 existing rules covers every CLDR cardinal pattern
2. Create `age/locales/{code}.json` with units, half marker, delimiter, justBorn, and stages
3. Run `just generate locales` — generates locale files and docs in all languages
4. Run `just test && just lint` to verify
5. Optionally add locale-specific test cases to `age/config/tests.json`

## Adding a new language

See [`.hecatron/age/docs/adding-a-language.md`](.hecatron/age/docs/adding-a-language.md) for the full guide. Summary:

1. Create `age/codegen/targets/<lang>/emitter.py` — emits locale source files from JSON
2. Create `age/codegen/targets/<lang>/plural_rules.py` with all 23 plural patterns
3. Register the generator in `age/codegen/generate.py` (`_GENERATORS` dict)
4. Implement types (`AgeLocale`, `PluralCategory`, etc.) and the core formatter (port from an existing implementation)
5. Implement all test cases from `age/config/tests.json`
6. Add to `.hecatron/tools/language/helpers.sh` (language lists, abbreviation, dependency) and `justfile` (test, build, lint, clean recipe handlers)
7. Configure the language's standard linter with zero warnings
8. Create installer scripts at `.hecatron/languages/<lang>/` (`install.sh`, `uninstall.sh`, `version.sh`, and optionally `metadata.sh`) and a `dockerfile` snippet for the age/Dockerfile generator
9. Create `age/impl/<lang>/README.md` with a `## License` section linking to `LICENSE.md`
10. Create `.github/workflows/<lang>.yml` CI workflow with a version matrix
11. Update cross-language doc tables (keep rows sorted alphabetically; don't hardcode counts in prose — update only the `CLAUDE.md` project description)
12. Verify: `just generate locales && just check && just test && just lint`

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
