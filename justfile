# sayable-age task runner
# Run `just --list` to see all available commands.

python := if `which python3 2>/dev/null || true` != "" { "python3" } else { "python" }

# Run all test suites + codegen check
[group('test')]
test *target:
    #!/usr/bin/env bash
    set -euo pipefail
    source .hecatron/tools/language/helpers.sh
    _jflag=""; _sflag=""; _target=""; _prev=""
    for _a in {{target}}; do
        if [ "$_prev" = "-j" ]; then _jflag="$_a"; _prev=""; continue; fi
        if [ "$_prev" = "-s" ]; then _sflag="$_a"; _prev=""; continue; fi
        if [ "$_a" = "-j" ]; then _prev="-j"; continue; fi
        if [ "$_a" = "-s" ]; then _prev="-s"; continue; fi
        _target="${_target:+$_target }$_a"
    done
    if [ "$_target" = "help" ] || [ "$_target" = "--help" ]; then
        printf '%s\n' \
            "Usage: just test [flags] [target]" \
            "" \
            "Run every language's native suites (all four libraries) in parallel, or one target's." \
            ""
        _lang_grid "Languages" "$_ALL_LANGS"
        printf '%s\n' \
            "" \
            "Tools:" \
            "  cli        CLI integration tests" \
            "" \
            "  codegen    Run codegen unit tests only" \
            "" \
            "Flags:" \
            "  -j VALUE   Set concurrency: integer, percentage (default 50%), or 'unlimited'" \
            "  -s MODE    Visualization: scroll (default), full, or zoom" \
            "" \
            "Examples:" \
            "  just test              Run all suites + codegen check in parallel" \
            "  just test go           Run Go's age, date, duration and time suites" \
            "  just test rs           Run Rust's suites (abbreviation)" \
            "  just test cli          Run CLI integration tests" \
            "  just test -j 4         Run all in parallel with 4 job slots" \
            "  just test -j 2 -s full Run with 2 slots, full-width visualization"
        exit 0
    fi
    if [ -z "$_target" ]; then
        _tools="codegen"
        args=("check")
        for target in $_ALL_LANGS; do
            [ -z "$target" ] && continue
            if _is_disabled "$target"; then
                args+=("disable:$target")
            else
                if _dep_available "$target"; then
                    args+=("test $target")
                else
                    args+=("skip:$target")
                fi
            fi
        done
        args+=("---")
        for target in $_tools; do
            if _dep_available "$target"; then
                args+=("test $target")
            else
                args+=("skip:$target")
            fi
        done
        .hecatron/tools/runner/run-parallel.sh ${_jflag:+-j "$_jflag"} ${_sflag:+-s "$_sflag"} test "${args[@]}"
    elif [ "$_target" = "cli" ]; then
        args=()
        for _cli_dir in cli/impl/*/; do
            _cl=$(basename "$_cli_dir")
            _cli_bin="${_cli_dir}sayable"
            if [ ! -x "${_cli_bin}" ]; then
                args+=("skip:${_cl}")
                continue
            fi
            if ! _dep_available "${_cl}"; then
                args+=("skip:${_cl}")
                continue
            fi
            args+=("_test_cli ${_cl}")
        done
        .hecatron/tools/runner/run-parallel.sh ${_jflag:+-j "$_jflag"} ${_sflag:+-s "$_sflag"} cli "${args[@]}"
    else
        name=$(_name "$_target")
        if _is_removed "${name}"; then
            echo "Language '${name}' is not added. Run 'just add ${name}' to add it." >&2
            exit 1
        fi
        mkdir -p .logs/test
        (
            if [[ "$_target" = cli\ * ]]; then
                _cli_lang="${_target#cli }"
                _cli_lang=$(_name "$_cli_lang")
                _cli_bin="cli/impl/${_cli_lang}/sayable"
                if [ ! -x "${_cli_bin}" ]; then
                    echo "error: ${_cli_bin} is not executable or not found" >&2
                    exit 1
                fi
                bash cli/test-harness.sh "${_cli_bin}"
            elif [ "$_target" = "codegen" ]; then
                cd age && {{python}} -m unittest codegen.test_locale_groups -v
            elif printf '%s\n' ${_ALL_LANGS} | grep -qx "${name}"; then
                # Every library's native suite (age, date, duration, time)
                bash .hecatron/tools/language/test.sh "${name}"
            else
                echo "Unknown target: $_target (try 'just test help')" >&2
                exit 1
            fi
        ) 2>&1 | tee ".logs/test/$name.log"
    fi

# Build all compiled targets (languages + tools)
[group('build')]
build *target:
    #!/usr/bin/env bash
    set -euo pipefail
    source .hecatron/tools/language/helpers.sh
    _jflag=""; _sflag=""; _target=""; _prev=""
    for _a in {{target}}; do
        if [ "$_prev" = "-j" ]; then _jflag="$_a"; _prev=""; continue; fi
        if [ "$_prev" = "-s" ]; then _sflag="$_a"; _prev=""; continue; fi
        if [ "$_a" = "-j" ]; then _prev="-j"; continue; fi
        if [ "$_a" = "-s" ]; then _prev="-s"; continue; fi
        _target="${_target:+$_target }$_a"
    done
    if [ "$_target" = "help" ] || [ "$_target" = "--help" ]; then
        printf '%s\n' \
            "Usage: just build [flags] [target]" \
            "" \
            "Build all compiled targets in parallel, or a single target." \
            ""
        _lang_grid "Languages" "$_COMPILED_LANGS"
        printf '%s\n' \
            "" \
            "Tools:" \
            "  cli        CLI tool (links against C library)" \
            "" \
            "  Targets without a build step: $(_lang_csv "$_NO_BUILD_LANGS")" \
            "" \
            "Flags:" \
            "  -j VALUE   Set concurrency: integer, percentage (default 50%), or 'unlimited'" \
            "  -s MODE    Visualization: scroll (default), full, or zoom" \
            "" \
            "Examples:" \
            "  just build             Build all compiled languages + tools in parallel" \
            "  just build rust        Build Rust only" \
            "  just build c++         Build C++ (abbreviation)" \
            "  just build cli         Build the CLI tool only" \
            "  just build -j 2        Build all with 2 job slots"
        exit 0
    fi
    if [ -z "$_target" ]; then
        _tools="cli"
        args=()
        for target in $_COMPILED_LANGS; do
            [ -z "$target" ] && continue
            if _is_disabled "$target"; then
                args+=("disable:$target")
            else
                if _dep_available "$target"; then
                    args+=("build $target")
                else
                    args+=("skip:$target")
                fi
            fi
        done
        args+=("---")
        for target in $_tools; do
            if _dep_available "$target"; then
                args+=("build $target")
            else
                args+=("skip:$target")
            fi
        done
        .hecatron/tools/runner/run-parallel.sh ${_jflag:+-j "$_jflag"} ${_sflag:+-s "$_sflag"} build "${args[@]}"
    else
        name=$(_name "$_target")
        if _is_removed "${name}"; then
            echo "Language '${name}' is not added. Run 'just add ${name}' to add it." >&2
            exit 1
        fi
        mkdir -p .logs/build
        (
            if [ "$_target" = "ada" ] || [ "$_target" = "ad" ]; then
                _ada_env
                cd age/impl/ada && gprbuild -P sayableage.gpr -XBUILD_MODE=build
            elif [ "$_target" = "typescript" ] || [ "$_target" = "ts" ]; then
                cd age/impl/typescript && npm run build
            elif [ "$_target" = "rust" ] || [ "$_target" = "rs" ]; then
                cd age/impl/rust && cargo build
            elif [ "$_target" = "kotlin" ] || [ "$_target" = "kt" ]; then
                cd age/impl/kotlin && ./gradlew build
            elif [ "$_target" = "cpp" ] || [ "$_target" = "c++" ]; then
                cd age/impl/cpp && cmake -B build && cmake --build build
            elif [ "$_target" = "c" ]; then
                cd age/impl/c && cmake -B build && cmake --build build
            elif [ "$_target" = "cobol" ] || [ "$_target" = "cb" ]; then
                cd age/impl/cobol && cmake -B build && cmake --build build
            elif [ "$_target" = "cli" ]; then
                echo "No build step for CLI (language-specific builds handled by each implementation)"
            elif [ "$_target" = "java" ]; then
                cd age/impl/java && ./gradlew build
            elif [ "$_target" = "csharp" ] || [ "$_target" = "cs" ]; then
                cd age/impl/csharp && dotnet build
            elif [ "$_target" = "fsharp" ] || [ "$_target" = "fs" ]; then
                cd age/impl/fsharp && dotnet build
            elif [ "$_target" = "swift" ] || [ "$_target" = "sw" ]; then
                cd age/impl/swift && swift build
            elif [ "$_target" = "haskell" ] || [ "$_target" = "hs" ]; then
                cd age/impl/haskell && cabal build
            elif [ "$_target" = "ocaml" ] || [ "$_target" = "ml" ]; then
                cd age/impl/ocaml && eval "$(opam env 2>/dev/null)" && dune build
            elif [ "$_target" = "elixir" ] || [ "$_target" = "ex" ]; then
                cd age/impl/elixir && mix compile --warnings-as-errors
            elif [ "$_target" = "gleam" ] || [ "$_target" = "gm" ]; then
                cd age/impl/gleam && gleam build
            elif [ "$_target" = "erlang" ] || [ "$_target" = "erl" ]; then
                cd age/impl/erlang && rebar3 compile
            elif [ "$_target" = "fortran" ] || [ "$_target" = "ft" ]; then
                cd age/impl/fortran && cmake -B build && cmake --build build
            elif [ "$_target" = "groovy" ] || [ "$_target" = "gy" ]; then
                cd age/impl/groovy && ./gradlew build
            elif [ "$_target" = "scala" ] || [ "$_target" = "sc" ]; then
                cd age/impl/scala && ./gradlew build
            elif [ "$_target" = "goose" ] || [ "$_target" = "gs" ]; then
                for _c in age date duration time; do bash "${_c}/impl/goose/build.sh"; done
            elif [ "$_target" = "zig" ] || [ "$_target" = "zg" ]; then
                cd age/impl/zig && zig build
            elif [ "$_target" = "pascal" ] || [ "$_target" = "pas" ]; then
                cd age/impl/pascal && mkdir -p build && fpc -FEbuild -FUbuild -Fulocales -o"build/test_format_age" test_format_age.pas
            elif [ "$_target" = "crystal" ] || [ "$_target" = "cr" ]; then
                cd age/impl/crystal && shards build
            elif [ "$_target" = "d" ]; then
                cd age/impl/d && ldc2 -I=source source/sayableage/locale.d source/sayableage/format_age.d source/sayableage/locales.d -of=sayableage.o -c
            elif [ "$_target" = "v" ]; then
                cd age/impl/v && v .
            elif [ "$_target" = "nim" ] || [ "$_target" = "ni" ]; then
                cd age/impl/nim && nim c --noMain --path:src src/sayable_age/formatter.nim
            elif [ "$_target" = "vbnet" ] || [ "$_target" = "vb" ]; then
                cd age/impl/vbnet && dotnet build
            elif [ "$_target" = "mojo" ] || [ "$_target" = "mj" ]; then
                cd age/impl/mojo && mojo build src/
            else
                echo "No build step for: $_target"
            fi
        ) 2>&1 | tee ".logs/build/$name.log"
    fi

# Generate locale source files and documentation from canonical JSON
[group('codegen')]
generate target *args:
    #!/usr/bin/env bash
    set -euo pipefail
    case "{{target}}" in
        compatibility)
            {{python}} tools/generate_compatibility.py {{args}}
            ;;
        geography)
            uv run --with geopandas --with matplotlib {{python}} tools/geography/generate.py {{args}}
            ;;
        locales)
            (cd age && {{python}} -m codegen.generate {{args}})
            (cd date && {{python}} -m codegen.generate {{args}})
            (cd duration && {{python}} -m codegen.generate {{args}})
            (cd time && {{python}} -m codegen.generate {{args}})
            {{python}} tools/generate_locale_docs.py
            ;;
        *)
            echo "error: unknown generate target '{{target}}'" >&2
            echo "Valid targets: compatibility, geography, locales" >&2
            exit 1
            ;;
    esac

# Maintain project documentation (table alignment, formatting)
[group('maintain')]
maintain target *args:
    #!/usr/bin/env bash
    set -euo pipefail
    case "{{target}}" in
        docs)
            # Hand-written docs only: generated pages (docs/locales/, locales/README.md)
            # are rewritten by `just generate locales`.
            _docs=(README.md CLAUDE.md CONTRIBUTING.md docs/*.md)
            for _lib in age date duration time; do
                for _f in "${_lib}"/README.md "${_lib}"/CLAUDE.md "${_lib}"/codegen/README.md \
                          "${_lib}"/config/README.md "${_lib}"/tests/README.md \
                          "${_lib}"/docs/*.md "${_lib}"/impl/*/README.md; do
                    [ -f "${_f}" ] && _docs+=("${_f}")
                done
            done
            (cd age && {{python}} -m codegen.align_tables {{args}} "${_docs[@]/#/../}")
            ;;
        *)
            echo "error: unknown maintain target '{{target}}'" >&2
            echo "Valid targets: docs" >&2
            exit 1
            ;;
    esac

# Verify all generated files and documentation are up-to-date (CI mode)
[group('codegen')]
check:
    #!/usr/bin/env bash
    set -euo pipefail
    (cd age && {{python}} -m codegen.generate --check)
    (cd date && {{python}} -m codegen.generate --check)
    (cd duration && {{python}} -m codegen.generate --check)
    (cd time && {{python}} -m codegen.generate --check)
    {{python}} tools/generate_locale_docs.py --check
    {{python}} .hecatron/tools/codegen/dockerfile.py --check
    {{python}} tools/generate_compatibility.py --check
    {{python}} tools/check_workflow_components.py
    {{python}} tools/check_test_ids.py
    uv run --with geopandas --with matplotlib {{python}} tools/geography/generate.py --check

# Generate Dockerfile from per-language snippets
[group('codegen')]
dockerfile:
    {{python}} .hecatron/tools/codegen/dockerfile.py

# Show or set the library version across all implementations
[group('codegen')]
version *ver:
    #!/usr/bin/env bash
    set -euo pipefail
    source .hecatron/tools/language/helpers.sh

    ver="{{ver}}"
    if [ -z "${ver}" ]; then
        {{python}} -c "import json; print(json.load(open('age/config/version.json'))['version'])"
        exit 0
    fi
    if [[ ! "${ver}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "error: version must be semver (X.Y.Z), got '${ver}'" >&2
        exit 1
    fi

    old="$({{python}} -c "import json; print(json.load(open('age/config/version.json'))['version'])")"
    if [ "${ver}" = "${old}" ]; then
        echo "Version is already ${ver}" >&2
        exit 0
    fi

    echo "Bumping version: ${old} → ${ver}"

    # 1. Update version.json
    printf '{\n  "version": "%s"\n}\n' "${ver}" > age/config/version.json
    echo "  updated age/config/version.json"

    # 2. Update all language implementations via their installer scripts
    for lang in ${_ALL_LANGS}; do
        [ -z "${lang}" ] && continue
        bash ".hecatron/languages/${lang}/version.sh" "${ver}"
        echo "  updated ${lang}"
    done

    # 3. Regenerate C header (uses updated emitter.py)
    (cd age && {{python}} -m codegen.generate)
    {{python}} tools/generate_locale_docs.py
    echo "  regenerated locale files"

    # 4. Update age/docs/versioning.md
    _sed_i() {
        if [ "$(uname -s)" = "Darwin" ]; then
            sed -i '' "$@"
        else
            sed -i "$@"
        fi
    }
    _sed_i "s/\"version\": \"${old}\"/\"version\": \"${ver}\"/" age/docs/versioning.md
    _sed_i "s/#define SAYABLEAGE_VERSION \"${old}\"/#define SAYABLEAGE_VERSION \"${ver}\"/" age/docs/versioning.md
    _sed_i "s/(def version \"${old}\")/(def version \"${ver}\")/" age/docs/versioning.md
    _sed_i "s/version = \"${old}\"/version = \"${ver}\"/g" age/docs/versioning.md
    _sed_i "s/-define(VERSION, \"${old}\")/-define(VERSION, \"${ver}\")/" age/docs/versioning.md
    _sed_i "s/__version__ = \"${old}\"/__version__ = \"${ver}\"/" age/docs/versioning.md
    echo "  updated age/docs/versioning.md"

    echo ""
    echo "Done. Version is now ${ver}."
    echo "Run 'just test' to verify, then commit."

# Update project metadata across all manifests
[group('codegen')]
metadata:
    #!/usr/bin/env bash
    set -euo pipefail
    bash .hecatron/tools/metadata/set.sh

# Run all available linters
[group('lint')]
lint *target:
    #!/usr/bin/env bash
    set -euo pipefail
    source .hecatron/tools/language/helpers.sh
    _jflag=""; _sflag=""; _target=""; _prev=""
    for _a in {{target}}; do
        if [ "$_prev" = "-j" ]; then _jflag="$_a"; _prev=""; continue; fi
        if [ "$_prev" = "-s" ]; then _sflag="$_a"; _prev=""; continue; fi
        if [ "$_a" = "-j" ]; then _prev="-j"; continue; fi
        if [ "$_a" = "-s" ]; then _prev="-s"; continue; fi
        _target="${_target:+$_target }$_a"
    done
    if [ "$_target" = "help" ] || [ "$_target" = "--help" ]; then
        printf '%s\n' \
            "Usage: just lint [flags] [target]" \
            "" \
            "Run all linters in parallel, or a single target's linter." \
            ""
        _lang_grid "Languages with separate linters" "$_LINT_LANGS"
        printf '%s\n' \
            "" \
            "Tools:" \
            "  cli        Warnings-as-errors in build" \
            "  shell      shellcheck on every shell script" \
            "" \
            "  Other languages use warnings-as-errors in their build step (no separate linter)." \
            "" \
            "Flags:" \
            "  -j VALUE   Set concurrency: integer, percentage (default 50%), or 'unlimited'" \
            "  -s MODE    Visualization: scroll (default), full, or zoom" \
            "" \
            "Examples:" \
            "  just lint              Run every linter in parallel" \
            "  just lint python       Run Python linter only (ruff + pyright)" \
            "  just lint rs           Run Rust linter (clippy, abbreviation)" \
            "  just lint -j 3         Run all with 3 job slots"
        exit 0
    fi
    if [ -z "$_target" ]; then
        _dep() { _lint_dep "$@"; }
        args=()
        for target in $_LINT_LANGS; do
            [ -z "$target" ] && continue
            if _is_disabled "$target"; then
                args+=("disable:$target")
            else
                if _dep_available "$target"; then
                    args+=("lint $target")
                else
                    args+=("skip:$target")
                fi
            fi
        done
        args+=("---")
        if command -v shellcheck >/dev/null 2>&1; then
            args+=("lint shell")
        else
            args+=("skip:shell")
        fi
        .hecatron/tools/runner/run-parallel.sh ${_jflag:+-j "$_jflag"} ${_sflag:+-s "$_sflag"} lint "${args[@]}"
    else
        name=$(_name "$_target")
        if _is_removed "${name}"; then
            echo "Language '${name}' is not added. Run 'just add ${name}' to add it." >&2
            exit 1
        fi
        mkdir -p .logs/lint
        (
            if [ "$_target" = "typescript" ] || [ "$_target" = "ts" ]; then
                bash .hecatron/tools/language/lint.sh typescript
            elif [ "$_target" = "dart" ] || [ "$_target" = "dt" ]; then
                bash .hecatron/tools/language/lint.sh dart
            elif [ "$_target" = "python" ] || [ "$_target" = "py" ]; then
                bash .hecatron/tools/language/lint.sh python
            elif [ "$_target" = "go" ]; then
                bash .hecatron/tools/language/lint.sh go
            elif [ "$_target" = "ruby" ] || [ "$_target" = "rb" ]; then
                bash .hecatron/tools/language/lint.sh ruby
            elif [ "$_target" = "rust" ] || [ "$_target" = "rs" ]; then
                bash .hecatron/tools/language/lint.sh rust
            elif [ "$_target" = "php" ]; then
                bash .hecatron/tools/language/lint.sh php
            elif [ "$_target" = "lua" ] || [ "$_target" = "lu" ]; then
                bash .hecatron/tools/language/lint.sh lua
            elif [ "$_target" = "kotlin" ] || [ "$_target" = "kt" ]; then
                echo "Kotlin uses warnings-as-errors in build (no separate linter)"
            elif [ "$_target" = "c" ]; then
                echo "C uses warnings-as-errors in build (no separate linter)"
            elif [ "$_target" = "shell" ]; then
                bash .hecatron/tools/lint/shellcheck.sh
            elif [ "$_target" = "cli" ]; then
                echo "CLI uses warnings-as-errors in build (no separate linter)"
            elif [ "$_target" = "cpp" ] || [ "$_target" = "c++" ]; then
                echo "C++ uses warnings-as-errors in build (no separate linter)"
            elif [ "$_target" = "java" ]; then
                echo "Java uses warnings-as-errors in build (no separate linter)"
            elif [ "$_target" = "csharp" ] || [ "$_target" = "cs" ]; then
                echo "C# uses TreatWarningsAsErrors in build (no separate linter)"
            elif [ "$_target" = "fsharp" ] || [ "$_target" = "fs" ]; then
                echo "F# uses TreatWarningsAsErrors in build (no separate linter)"
            elif [ "$_target" = "swift" ] || [ "$_target" = "sw" ]; then
                echo "Swift uses warnings-as-errors in build (no separate linter)"
            elif [ "$_target" = "haskell" ] || [ "$_target" = "hs" ]; then
                echo "Haskell uses -Wall -Werror in build (no separate linter)"
            elif [ "$_target" = "ocaml" ] || [ "$_target" = "ml" ]; then
                echo "OCaml uses -warn-error in build (no separate linter)"
            elif [ "$_target" = "erlang" ] || [ "$_target" = "erl" ]; then
                echo "Erlang uses warnings-as-errors in build (no separate linter)"
            elif [ "$_target" = "fortran" ] || [ "$_target" = "ft" ]; then
                echo "Fortran uses -Wall -Wextra -Wpedantic -Werror in build (no separate linter)"
            elif [ "$_target" = "groovy" ] || [ "$_target" = "gy" ]; then
                echo "Groovy uses -Werror in build (no separate linter)"
            elif [ "$_target" = "clojure" ] || [ "$_target" = "clj" ]; then
                echo "Clojure uses *warn-on-reflection* in build (no separate linter)"
            elif [ "$_target" = "cobol" ] || [ "$_target" = "cb" ]; then
                echo "COBOL uses -Wall in build (no separate linter)"
            elif [ "$_target" = "scala" ] || [ "$_target" = "sc" ]; then
                echo "Scala uses -Werror in build (no separate linter)"
            elif [ "$_target" = "elixir" ] || [ "$_target" = "ex" ]; then
                echo "Elixir uses warnings-as-errors in build (no separate linter)"
            elif [ "$_target" = "gleam" ] || [ "$_target" = "gm" ]; then
                echo "Gleam uses warnings-as-errors in build (no separate linter)"
            elif [ "$_target" = "elm" ] || [ "$_target" = "el" ]; then
                echo "Elm compiler is warnings-as-errors (no separate linter)"
            elif [ "$_target" = "perl" ] || [ "$_target" = "pl" ]; then
                echo "Perl uses strict/warnings (no separate linter)"
            elif [ "$_target" = "ada" ] || [ "$_target" = "ad" ]; then
                echo "Ada uses -gnatwe (warnings-as-errors) in build (no separate linter)"
            elif [ "$_target" = "goose" ] || [ "$_target" = "gs" ]; then
                bash .hecatron/tools/language/lint.sh goose
            elif [ "$_target" = "zig" ] || [ "$_target" = "zg" ]; then
                echo "Zig uses warnings-as-errors in build (no separate linter)"
            elif [ "$_target" = "nim" ] || [ "$_target" = "ni" ]; then
                echo "Nim uses warnings-as-errors in build (no separate linter)"
            elif [ "$_target" = "crystal" ] || [ "$_target" = "cr" ]; then
                bash .hecatron/tools/language/lint.sh crystal
            elif [ "$_target" = "r" ]; then
                echo "R uses stop() on warnings (no separate linter)"
            elif [ "$_target" = "vbnet" ] || [ "$_target" = "vb" ]; then
                echo "VB.NET uses TreatWarningsAsErrors in build (no separate linter)"
            else
                echo "Unknown target: $_target (try 'just lint help')" >&2
                exit 1
            fi
        ) 2>&1 | tee ".logs/lint/$name.log"
    fi

# Remove build artifacts (keeps installed dependencies)
[group('build')]
clean *target:
    #!/usr/bin/env bash
    set -euo pipefail
    source .hecatron/tools/language/helpers.sh
    _jflag=""; _sflag=""; _target=""; _prev=""
    for _a in {{target}}; do
        if [ "$_prev" = "-j" ]; then _jflag="$_a"; _prev=""; continue; fi
        if [ "$_prev" = "-s" ]; then _sflag="$_a"; _prev=""; continue; fi
        if [ "$_a" = "-j" ]; then _prev="-j"; continue; fi
        if [ "$_a" = "-s" ]; then _prev="-s"; continue; fi
        _target="${_target:+$_target }$_a"
    done
    if [ "$_target" = "help" ] || [ "$_target" = "--help" ]; then
        printf '%s\n' \
            "Usage: just clean [flags] [target]" \
            "" \
            "Remove build artifacts for all targets in parallel, or a single target." \
            "Keeps installed dependencies (node_modules, .venv, etc.)." \
            ""
        _lang_grid "Languages" "$_ALL_LANGS"
        printf '%s\n' \
            "" \
            "Tools:" \
            "  cli        CLI build artifacts" \
            "" \
            "  codegen    Clean codegen __pycache__ directories" \
            "" \
            "Flags:" \
            "  -j VALUE   Set concurrency: integer, percentage (default 50%), or 'unlimited'" \
            "  -s MODE    Visualization: scroll (default), full, or zoom" \
            "" \
            "Examples:" \
            "  just clean             Clean all targets in parallel" \
            "  just clean rust        Clean Rust build artifacts only" \
            "  just clean ts          Clean TypeScript (abbreviation)" \
            "  just clean -j 4        Clean all with 4 job slots"
        exit 0
    fi
    if [ -z "$_target" ]; then
        _tools="cli"
        args=()
        for target in $_CLEAN_LANGS; do
            [ -z "$target" ] && continue
            args+=("clean $target")
        done
        args+=("---")
        for target in $_tools codegen; do
            args+=("clean $target")
        done
        .hecatron/tools/runner/run-parallel.sh ${_jflag:+-j "$_jflag"} ${_sflag:+-s "$_sflag"} clean "${args[@]}"
    else
        _cname=$(_name "$_target")
        if _is_removed "${_cname}"; then
            echo "Language '${_cname}' is not added. Run 'just add ${_cname}' to add it." >&2
            exit 1
        fi
        if [ "$_target" = "ada" ] || [ "$_target" = "ad" ]; then
        rm -rf age/impl/ada/build src/ada/obj
    elif [ "$_target" = "typescript" ] || [ "$_target" = "ts" ]; then
        rm -rf age/impl/typescript/dist
    elif [ "$_target" = "python" ] || [ "$_target" = "py" ]; then
        find age/impl/python -type d -name __pycache__ -not -path '*/\.venv/*' -exec rm -rf {} + 2>/dev/null || true
        rm -rf age/impl/python/.pytest_cache
    elif [ "$_target" = "rust" ] || [ "$_target" = "rs" ]; then
        rm -rf age/impl/rust/target
    elif [ "$_target" = "kotlin" ] || [ "$_target" = "kt" ]; then
        rm -rf age/impl/kotlin/build src/kotlin/.gradle
    elif [ "$_target" = "c" ]; then
        rm -rf age/impl/c/build || rm -rf age/impl/c/build
    elif [ "$_target" = "cli" ]; then
        echo "No build artifacts for: cli"
    elif [ "$_target" = "cpp" ] || [ "$_target" = "c++" ]; then
        rm -rf age/impl/cpp/build || rm -rf age/impl/cpp/build
    elif [ "$_target" = "java" ]; then
        rm -rf age/impl/java/build src/java/.gradle
    elif [ "$_target" = "csharp" ] || [ "$_target" = "cs" ]; then
        rm -rf age/impl/csharp/SayableAge/bin src/csharp/SayableAge/obj src/csharp/SayableAge.Tests/bin src/csharp/SayableAge.Tests/obj
    elif [ "$_target" = "fsharp" ] || [ "$_target" = "fs" ]; then
        rm -rf age/impl/fsharp/SayableAge/bin src/fsharp/SayableAge/obj src/fsharp/SayableAge.Tests/bin src/fsharp/SayableAge.Tests/obj
    elif [ "$_target" = "swift" ] || [ "$_target" = "sw" ]; then
        rm -rf age/impl/swift/.build
    elif [ "$_target" = "haskell" ] || [ "$_target" = "hs" ]; then
        rm -rf age/impl/haskell/dist-newstyle
    elif [ "$_target" = "ocaml" ] || [ "$_target" = "ml" ]; then
        rm -rf age/impl/ocaml/_build
    elif [ "$_target" = "erlang" ] || [ "$_target" = "erl" ]; then
        rm -rf age/impl/erlang/_build
    elif [ "$_target" = "clojure" ] || [ "$_target" = "clj" ]; then
        rm -rf age/impl/clojure/.cpcache
    elif [ "$_target" = "cobol" ] || [ "$_target" = "cb" ]; then
        rm -rf age/impl/cobol/build
    elif [ "$_target" = "scala" ] || [ "$_target" = "sc" ]; then
        rm -rf age/impl/scala/build src/scala/.gradle
    elif [ "$_target" = "goose" ] || [ "$_target" = "gs" ]; then
        rm -rf age/impl/goose/build date/impl/goose/build duration/impl/goose/build time/impl/goose/build
    elif [ "$_target" = "zig" ] || [ "$_target" = "zg" ]; then
        rm -rf age/impl/zig/zig-out src/zig/.zig-cache
    elif [ "$_target" = "elixir" ] || [ "$_target" = "ex" ]; then
        rm -rf age/impl/elixir/_build
    elif [ "$_target" = "gleam" ] || [ "$_target" = "gm" ]; then
        rm -rf age/impl/gleam/build
    elif [ "$_target" = "elm" ] || [ "$_target" = "el" ]; then
        rm -rf age/impl/elm/elm-stuff
    elif [ "$_target" = "fortran" ] || [ "$_target" = "ft" ]; then
        rm -rf age/impl/fortran/build
    elif [ "$_target" = "groovy" ] || [ "$_target" = "gy" ]; then
        rm -rf age/impl/groovy/build src/groovy/.gradle
    elif [ "$_target" = "dart" ] || [ "$_target" = "dt" ]; then
        rm -rf age/impl/dart/.dart_tool
    elif [ "$_target" = "codegen" ]; then
        find codegen -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
    elif [ "$_target" = "pascal" ] || [ "$_target" = "pas" ]; then
        rm -rf age/impl/pascal/build age/impl/pascal/*.o age/impl/pascal/*.ppu
    elif [ "$_target" = "d" ]; then
        rm -rf age/impl/d/.dub age/impl/d/*.o age/impl/d/test_runner
    elif [ "$_target" = "racket" ] || [ "$_target" = "rkt" ]; then
        find age/impl/racket -type d -name compiled -exec rm -rf {} + 2>/dev/null || true
    elif [ "$_target" = "prolog" ] || [ "$_target" = "swi" ]; then
        rm -f age/impl/prolog/*.qlf
    elif [ "$_target" = "raku" ] || [ "$_target" = "rk" ]; then
        rm -rf age/impl/raku/.precomp
    elif [ "$_target" = "v" ]; then
        rm -rf age/impl/v/v
    elif [ "$_target" = "lisp" ] || [ "$_target" = "cl" ]; then
        rm -f age/impl/lisp/*.fasl
    elif [ "$_target" = "crystal" ] || [ "$_target" = "cr" ]; then
        rm -rf age/impl/crystal/lib age/impl/crystal/bin age/impl/crystal/.shards
    elif [ "$_target" = "nim" ] || [ "$_target" = "ni" ]; then
        rm -rf age/impl/nim/nimcache age/impl/nim/tests/nimcache age/impl/nim/src/nimcache
        find age/impl/nim -type d -name nimcache -exec rm -rf {} + 2>/dev/null || true
    elif [ "$_target" = "vbnet" ] || [ "$_target" = "vb" ]; then
        rm -rf age/impl/vbnet/SayableAge/bin age/impl/vbnet/SayableAge/obj age/impl/vbnet/SayableAge.Tests/bin age/impl/vbnet/SayableAge.Tests/obj
    elif [ "$_target" = "mojo" ] || [ "$_target" = "mj" ]; then
        rm -rf age/impl/mojo/.mojopkg age/impl/mojo/build
    elif [ "$_target" = "pharo" ] || [ "$_target" = "ph" ]; then
        rm -f age/impl/pharo/Pharo.image age/impl/pharo/Pharo.changes age/impl/pharo/*.sources
        rm -rf age/impl/pharo/pharo-local
    elif [ "$_target" = "go" ] || [ "$_target" = "julia" ] || [ "$_target" = "jl" ] || [ "$_target" = "lua" ] || [ "$_target" = "lu" ] || [ "$_target" = "ruby" ] || [ "$_target" = "rb" ] || [ "$_target" = "perl" ] || [ "$_target" = "pl" ] || [ "$_target" = "php" ] || [ "$_target" = "tcl" ] || [ "$_target" = "wren" ] || [ "$_target" = "janet" ] || [ "$_target" = "jt" ] || [ "$_target" = "r" ] || [ "$_target" = "bash" ] || [ "$_target" = "sh" ] || [ "$_target" = "odin" ] || [ "$_target" = "od" ] || [ "$_target" = "octave" ] || [ "$_target" = "oct" ] || [ "$_target" = "powershell" ] || [ "$_target" = "ps1" ]; then
        echo "No build artifacts for: $_target"
    else
        echo "Unknown target: $_target (try 'just clean help')" >&2
        exit 1
    fi
    fi

# Install language toolchains (all if no args, or specific languages)
[group('setup')]
install *langs:
    #!/usr/bin/env bash
    set -euo pipefail
    source .hecatron/tools/language/helpers.sh

    langs="{{langs}}"
    if [ "$langs" = "help" ] || [ "$langs" = "--help" ]; then
        printf '%s\n' \
            "Usage: just install [language ...]" \
            "" \
            "Install language toolchains. With no arguments, installs all." \
            ""
        _lang_grid "Languages" "$_ALL_LANGS"
        printf '%s\n' \
            "" \
            "Examples:" \
            "  just install           Install every language toolchain" \
            "  just install go rust   Install Go and Rust only" \
            "  just install rs        Install Rust (abbreviation)"
        exit 0
    fi
    {{python}} .hecatron/tools/language/install.py $langs

# Check every language's toolchain (or the ones named) and say how to repair it
[group('setup')]
doctor *langs:
    #!/usr/bin/env bash
    set -euo pipefail
    source .hecatron/tools/language/helpers.sh
    _args=({{langs}})
    if [ "${_args[0]:-}" = "help" ] || [ "${_args[0]:-}" = "--help" ]; then
        printf '%s\n' \
            "Usage: just doctor [--fix] [language ...]" \
            "" \
            "Check that each language's toolchain works: its build and lint tools run," \
            "and known breakages are absent (a linter built with an older Go, luacheck on" \
            "Lua 5.5, a moved virtualenv, a missing test package...). With no languages," \
            "checks every added, enabled one." \
            ""
        _lang_grid "Languages" "$_ALL_LANGS"
        printf '%s\n' \
            "" \
            "Flags:" \
            "  --fix      Run each unhealthy language's installer, then check it again" \
            "" \
            "Examples:" \
            "  just doctor            Check every toolchain" \
            "  just doctor go lua     Check Go and Lua only" \
            "  just doctor --fix      Check everything and repair what's broken"
        exit 0
    fi
    for _a in ${_args[@]+"${_args[@]}"}; do
        [ "${_a}" = "--fix" ] && continue
        if ! _check "${_a}" >/dev/null 2>&1; then
            echo "Unknown language: ${_a} (try 'just doctor help')" >&2
            exit 1
        fi
    done
    bash .hecatron/tools/language/doctor.sh ${_args[@]+"${_args[@]}"}

# Run CLI test harness (all languages or specify one: just cli python)
[group('test')]
cli *lang:
    just test cli {{lang}}

# Compare every CLI's answers to random requests (see docs/testing.md)
[group('test')]
fuzz *args:
    #!/usr/bin/env bash
    set -euo pipefail
    _args=({{args}})
    if [ "${_args[0]:-}" = "help" ]; then
        _args=(--help)
    fi
    {{python}} cli/fuzz.py ${_args[@]+"${_args[@]}"}

# Internal: test a single CLI language
[private]
_test_cli lang:
    #!/usr/bin/env bash
    set -euo pipefail
    source .hecatron/tools/language/helpers.sh
    if [ "{{lang}}" = "ada" ]; then _ada_env; fi
    _cli_bin="cli/impl/{{lang}}/sayable"
    if [ ! -x "${_cli_bin}" ]; then
        echo "error: ${_cli_bin} is not executable or not found" >&2
        exit 1
    fi
    bash cli/test-harness.sh "${_cli_bin}"

# Internal: clean then build a single target
[private]
_rebuild target:
    just clean {{target}} && just build {{target}}

# Internal: clean then test a single target
[private]
_retest target:
    just clean {{target}} && just test {{target}}

# Clean then build all compiled targets, or a single target
[group('build')]
rebuild *target:
    #!/usr/bin/env bash
    set -euo pipefail
    source .hecatron/tools/language/helpers.sh
    _jflag=""; _sflag=""; _target=""; _prev=""
    for _a in {{target}}; do
        if [ "$_prev" = "-j" ]; then _jflag="$_a"; _prev=""; continue; fi
        if [ "$_prev" = "-s" ]; then _sflag="$_a"; _prev=""; continue; fi
        if [ "$_a" = "-j" ]; then _prev="-j"; continue; fi
        if [ "$_a" = "-s" ]; then _prev="-s"; continue; fi
        _target="${_target:+$_target }$_a"
    done
    if [ "$_target" = "help" ] || [ "$_target" = "--help" ]; then
        printf '%s\n' \
            "Usage: just rebuild [flags] [target]" \
            "" \
            "Clean then build all compiled targets in parallel, or a single target." \
            ""
        _lang_grid "Languages" "$_COMPILED_LANGS"
        printf '%s\n' \
            "" \
            "Tools:" \
            "  cli        CLI tool (links against C library)" \
            "" \
            "Flags:" \
            "  -j VALUE   Set concurrency: integer, percentage (default 50%), or 'unlimited'" \
            "  -s MODE    Visualization: scroll (default), full, or zoom" \
            "" \
            "Examples:" \
            "  just rebuild           Clean + build all compiled targets in parallel" \
            "  just rebuild rust      Clean + build Rust only" \
            "  just rebuild -j 2      Clean + build all with 2 job slots"
        exit 0
    fi
    if [ -z "$_target" ]; then
        _tools="cli"
        args=()
        for target in $_COMPILED_LANGS; do
            [ -z "$target" ] && continue
            if _is_disabled "$target"; then
                args+=("disable:$target")
            else
                if _dep_available "$target"; then
                    args+=("_rebuild $target")
                else
                    args+=("skip:$target")
                fi
            fi
        done
        args+=("---")
        for target in $_tools; do
            if _dep_available "$target"; then
                args+=("_rebuild $target")
            else
                args+=("skip:$target")
            fi
        done
        .hecatron/tools/runner/run-parallel.sh ${_jflag:+-j "$_jflag"} ${_sflag:+-s "$_sflag"} rebuild "${args[@]}"
    else
        name=$(_name "$_target")
        just clean "$_target" && just build "$_target"
    fi

# Clean then test all targets, or a single target
[group('test')]
retest *target:
    #!/usr/bin/env bash
    set -euo pipefail
    source .hecatron/tools/language/helpers.sh
    _jflag=""; _sflag=""; _target=""; _prev=""
    for _a in {{target}}; do
        if [ "$_prev" = "-j" ]; then _jflag="$_a"; _prev=""; continue; fi
        if [ "$_prev" = "-s" ]; then _sflag="$_a"; _prev=""; continue; fi
        if [ "$_a" = "-j" ]; then _prev="-j"; continue; fi
        if [ "$_a" = "-s" ]; then _prev="-s"; continue; fi
        _target="${_target:+$_target }$_a"
    done
    if [ "$_target" = "help" ] || [ "$_target" = "--help" ]; then
        printf '%s\n' \
            "Usage: just retest [flags] [target]" \
            "" \
            "Clean then test all targets in parallel, or a single target." \
            ""
        _lang_grid "Languages" "$_ALL_LANGS"
        printf '%s\n' \
            "" \
            "Tools:" \
            "  cli        CLI integration tests" \
            "" \
            "Flags:" \
            "  -j VALUE   Set concurrency: integer, percentage (default 50%), or 'unlimited'" \
            "  -s MODE    Visualization: scroll (default), full, or zoom" \
            "" \
            "Examples:" \
            "  just retest            Clean + test all targets in parallel" \
            "  just retest go         Clean + test Go only" \
            "  just retest -j 4       Clean + test all with 4 job slots"
        exit 0
    fi
    if [ -z "$_target" ]; then
        _tools="codegen"
        args=("check")
        for target in $_ALL_LANGS; do
            [ -z "$target" ] && continue
            if _is_disabled "$target"; then
                args+=("disable:$target")
            else
                if _dep_available "$target"; then
                    args+=("_retest $target")
                else
                    args+=("skip:$target")
                fi
            fi
        done
        args+=("---")
        for target in $_tools; do
            if _dep_available "$target"; then
                args+=("_retest $target")
            else
                args+=("skip:$target")
            fi
        done
        .hecatron/tools/runner/run-parallel.sh ${_jflag:+-j "$_jflag"} ${_sflag:+-s "$_sflag"} retest "${args[@]}"
    else
        if [ "$_target" = "check" ]; then
            just check
        elif [ "$_target" = "codegen" ]; then
            just test codegen
        else
            just clean "$_target" && just test "$_target"
        fi
    fi

# Interactive onboarding: show project info, installed languages, and install menu
[group('setup')]
get-started *args:
    @bash .hecatron/tools/onboarding/get-started.sh {{args}}

# Uninstall language toolchains
[group('setup')]
uninstall *langs:
    #!/usr/bin/env bash
    set -euo pipefail
    source .hecatron/tools/language/helpers.sh

    langs="{{langs}}"
    if [ "$langs" = "help" ] || [ "$langs" = "--help" ]; then
        printf '%s\n' \
            "Usage: just uninstall <language> [language ...]" \
            "" \
            "Uninstall language toolchains." \
            ""
        _lang_grid "Languages" "$_ALL_LANGS"
        printf '%s\n' \
            "" \
            "Examples:" \
            "  just uninstall go rust   Uninstall Go and Rust" \
            "  just uninstall rs        Uninstall Rust (abbreviation)"
        exit 0
    fi
    {{python}} .hecatron/tools/language/uninstall.py $langs

# Temporarily disable languages from parallel runs (test, build, lint, etc.)
[group('setup')]
disable *langs:
    #!/usr/bin/env bash
    set -euo pipefail
    source .hecatron/tools/language/helpers.sh

    langs="{{langs}}"
    if [ "$langs" = "help" ] || [ "$langs" = "--help" ]; then
        printf '%s\n' \
            "Usage: just disable <language> [language ...]" \
            "" \
            "Temporarily disable languages from parallel runs (test, build, lint, etc.)." \
            "Disabled languages show as orange '⊘ disabled' in runner output." \
            "Does not affect single-language runs, clean, install, or uninstall." \
            ""
        _lang_grid "Languages" "$_ALL_LANGS"
        printf '%s\n' \
            "" \
            "Examples:" \
            "  just disable haskell ada   Disable Haskell and Ada" \
            "  just disable hs            Disable Haskell (abbreviation)"
        if [ -n "${_DISABLED_LANGS}" ]; then
            printf '\n%s\n' "Currently disabled:"
            while read -r _l; do
                [ -n "${_l}" ] && printf '  %s\n' "${_l}"
            done <<< "${_DISABLED_LANGS}"
        fi
        exit 0
    fi
    {{python}} .hecatron/tools/language/disable.py $langs

# Re-enable previously disabled languages
[group('setup')]
enable *langs:
    #!/usr/bin/env bash
    set -euo pipefail
    source .hecatron/tools/language/helpers.sh

    langs="{{langs}}"
    if [ "$langs" = "help" ] || [ "$langs" = "--help" ]; then
        printf '%s\n' \
            "Usage: just enable <language> [language ...] | --all" \
            "" \
            "Re-enable previously disabled languages." \
            ""
        _lang_grid "Languages" "$_ALL_LANGS"
        printf '%s\n' \
            "" \
            "Flags:" \
            "  --all      Re-enable all disabled languages" \
            "" \
            "Examples:" \
            "  just enable haskell       Re-enable Haskell" \
            "  just enable hs            Re-enable Haskell (abbreviation)" \
            "  just enable --all         Re-enable everything"
        if [ -n "${_DISABLED_LANGS}" ]; then
            printf '\n%s\n' "Currently disabled:"
            while read -r _l; do
                [ -n "${_l}" ] && printf '  %s\n' "${_l}"
            done <<< "${_DISABLED_LANGS}"
        fi
        exit 0
    fi
    {{python}} .hecatron/tools/language/enable.py $langs

# Add language(s) to the project's active set
[group('manage')]
add *langs:
    #!/usr/bin/env bash
    set -euo pipefail
    if [ -z "{{langs}}" ] || [ "{{langs}}" = "help" ] || [ "{{langs}}" = "--help" ]; then
        printf '%s\n' \
            "Usage: just add <language> [language...]" \
            "" \
            "Add language(s) to the project's active set." \
            "Abbreviations are accepted." \
            "" \
            "Examples:" \
            "  just add go" \
            "  just add rs py ts"
        exit 0
    fi
    {{python}} .hecatron/tools/language/add.py {{langs}}

# Remove language(s) from the project's active set
[group('manage')]
remove *langs:
    #!/usr/bin/env bash
    set -euo pipefail
    if [ -z "{{langs}}" ] || [ "{{langs}}" = "help" ] || [ "{{langs}}" = "--help" ]; then
        printf '%s\n' \
            "Usage: just remove <language> [language...]" \
            "" \
            "Remove language(s) from the project's active set." \
            "Abbreviations are accepted." \
            "" \
            "Examples:" \
            "  just remove go" \
            "  just remove rs py ts"
        exit 0
    fi
    {{python}} .hecatron/tools/language/remove.py {{langs}}

# List project languages
[group('manage')]
list *what:
    #!/usr/bin/env bash
    set -euo pipefail
    if [ "{{what}}" = "help" ] || [ "{{what}}" = "--help" ]; then
        printf '%s\n' \
            "Usage: just list languages [--all]" \
            "" \
            "List active project languages. Use --all to see all known languages."
        exit 0
    fi
    if [ "{{what}}" = "languages" ] || [ "{{what}}" = "langs" ]; then
        {{python}} .hecatron/tools/language/list.py
    elif [ "{{what}}" = "languages --all" ] || [ "{{what}}" = "langs --all" ]; then
        {{python}} .hecatron/tools/language/list.py --all
    else
        echo "Usage: just list languages [--all]" >&2
        exit 1
    fi

# Run benchmarks across all or individual language implementations
[group('benchmark')]
benchmark type="cpu" *target:
    #!/usr/bin/env bash
    set -euo pipefail
    source .hecatron/tools/language/helpers.sh
    # Benchmark-eligible languages (all except elm — no native timing primitives)
    _BENCH_LANGS=$(echo "$_ALL_LANGS" | grep -vx elm)
    # If type looks like a flag, treat it as part of target with default type (cpu)
    _type="{{type}}"
    _extra_target=""
    case "${_type}" in
        -*) _extra_target="${_type}"; _type="cpu" ;;
    esac
    if [ "${_type}" = "report" ]; then
        set -- {{target}}
        _rtype="${1:-cpu}"; shift 2>/dev/null || true
        case "$_rtype" in
            cpu)   uv run --with matplotlib python3 age/benchmarks/cpu/report.py "$@" ;;
            build) uv run --with matplotlib python3 age/benchmarks/build/report.py "$@" ;;
            *)     echo "error: unknown report type '$_rtype'" >&2; exit 1 ;;
        esac
        exit 0
    fi
    if [ "${_type}" = "build" ]; then
        _jflag="pcores"; _nflag="-20"; _sflag=""; _target=""; _prev=""
        for _a in ${_extra_target} {{target}}; do
            if [ "$_prev" = "-j" ]; then _jflag="$_a"; _prev=""; continue; fi
            if [ "${_prev}" = "-n" ]; then _nflag="${_a}"; _prev=""; continue; fi
            if [ "$_prev" = "-s" ]; then _sflag="$_a"; _prev=""; continue; fi
            if [ "$_a" = "-j" ]; then _prev="-j"; continue; fi
            if [ "${_a}" = "-n" ]; then _prev="-n"; continue; fi
            if [ "$_a" = "-s" ]; then _prev="-s"; continue; fi
            _target="${_target:+$_target }$_a"
        done
        if [ "$_target" = "help" ] || [ "$_target" = "--help" ]; then
            printf '%s\n' \
                "Usage: just benchmark build [flags] [target]" \
                "" \
                "Measure clean build time for compiled languages." \
                ""
            _lang_grid "Compiled languages" "$_COMPILED_LANGS"
            printf '%s\n' \
                "" \
                "Flags:" \
                "  -j VALUE   Concurrency (default pcores = P-cores minus 1)" \
                "  -n NICE    Nice priority (default -20, highest CPU priority; requires sudo)" \
                "  -s MODE    Visualization: scroll (default), full, or zoom" \
                "" \
                "Examples:" \
                "  just benchmark build          Run all (P-cores minus 1 slots, nice -20)" \
                "  just benchmark build zig      Run Zig build benchmark only" \
                "  just benchmark build rs       Run Rust build benchmark (abbreviation)" \
                "  just benchmark build -j 1     Run serial (one at a time)" \
                "  just benchmark build -n 0     Run without elevated priority"
            exit 0
        fi
        if [ -z "$_target" ]; then
            args=()
            while read -r lang; do
                [ -z "$lang" ] && continue
                if _dep_available "$lang"; then
                    args+=("benchmark build $lang")
                else
                    args+=("skip:$lang")
                fi
            done <<< "$_COMPILED_LANGS"
            .hecatron/tools/runner/run-parallel.sh -j "${_jflag}" -n "${_nflag}" ${_sflag:+-s "${_sflag}"} benchmark "${args[@]}"
        else
            name=$(_name "$_target")
            if ! echo "$_COMPILED_LANGS" | grep -qx "$name"; then
                echo "error: '$_target' is not a compiled language (try 'just benchmark build help')" >&2
                exit 1
            fi
            mkdir -p .logs/benchmark
            if [ -n "${SUDO_USER:-}" ]; then chown "${SUDO_USER}" .logs/benchmark; fi
            _nice_cmd=""
            if [ "${_nflag}" != "0" ] && sudo -n true 2>/dev/null; then
                _nice_cmd="sudo -n nice -n ${_nflag}"
            fi
            ${_nice_cmd} python3 age/benchmarks/build/bench_build.py "${name}" 2>&1 | tee ".logs/benchmark/build-${name}.log"
            if [ -n "${SUDO_USER:-}" ]; then chown -R "${SUDO_USER}" .logs/benchmark age/benchmarks/build/results 2>/dev/null; fi
        fi
        exit 0
    fi
    if [ "${_type}" != "cpu" ]; then
        echo "error: unknown benchmark type '${_type}'" >&2
        echo "Valid types: build, cpu, report" >&2
        exit 1
    fi
    _jflag="pcores"; _nflag="-20"; _sflag=""; _target=""; _prev=""
    for _a in ${_extra_target} {{target}}; do
        if [ "$_prev" = "-j" ]; then _jflag="$_a"; _prev=""; continue; fi
        if [ "${_prev}" = "-n" ]; then _nflag="${_a}"; _prev=""; continue; fi
        if [ "$_prev" = "-s" ]; then _sflag="$_a"; _prev=""; continue; fi
        if [ "$_a" = "-j" ]; then _prev="-j"; continue; fi
        if [ "${_a}" = "-n" ]; then _prev="-n"; continue; fi
        if [ "$_a" = "-s" ]; then _prev="-s"; continue; fi
        _target="${_target:+$_target }$_a"
    done
    if [ "$_target" = "help" ] || [ "$_target" = "--help" ]; then
        printf '%s\n' \
            "Usage: just benchmark cpu [flags] [target]" \
            "" \
            "Run CPU benchmarks for all languages, or a single language." \
            ""
        _lang_grid "Languages" "$_BENCH_LANGS"
        printf '%s\n' \
            "" \
            "  Elm is excluded (no native timing primitives)." \
            "" \
            "Flags:" \
            "  -j VALUE   Concurrency (default pcores = P-cores minus 1)" \
            "  -n NICE    Nice priority (default -20, highest CPU priority; requires sudo)" \
            "  -s MODE    Visualization: scroll (default), full, or zoom" \
            "" \
            "Examples:" \
            "  just benchmark cpu          Run all (P-cores minus 1 slots, nice -20)" \
            "  just benchmark cpu go       Run Go benchmark only" \
            "  just benchmark cpu rs       Run Rust benchmark (abbreviation)" \
            "  just benchmark cpu -j 4     Run all with 4 job slots" \
            "  just benchmark cpu -n 0     Run without elevated priority"
        exit 0
    fi
    if [ -z "$_target" ]; then
        args=()
        while read -r lang; do
            [ -z "$lang" ] && continue
            if _dep_available "$lang"; then
                args+=("benchmark cpu $lang")
            else
                args+=("skip:$lang")
            fi
        done <<< "$_BENCH_LANGS"
        .hecatron/tools/runner/run-parallel.sh -j "${_jflag}" -n "${_nflag}" ${_sflag:+-s "${_sflag}"} benchmark "${args[@]}"
    else
        name=$(_name "$_target")
        mkdir -p .logs/benchmark
        if [ -n "${SUDO_USER:-}" ]; then chown "${SUDO_USER}" .logs/benchmark; fi
        (
            if [ "${_nflag}" != "0" ] && sudo -n true 2>/dev/null; then
                sudo -n renice -n "${_nflag}" -p "${BASHPID:-$$}" > /dev/null 2>&1 || true
            fi
            case "$name" in
                ada)
                    _ada_env
                    _largs=""
                    if [ "$(uname -s)" = "Darwin" ]; then
                        _sdk="$(xcrun --show-sdk-path 2>/dev/null)"
                        [ -n "$_sdk" ] && _largs="-largs -L$_sdk/usr/lib"
                    fi
                    cd age/impl/ada && gprbuild -P sayableage.gpr -XBUILD_MODE=bench $_largs && ./build/bench_sayableage
                    ;;
                c)
                    cd age/impl/c && cmake -B build -DCMAKE_BUILD_TYPE=Release && cmake --build build --target bench_sayableage && ./build/bench_sayableage
                    ;;
                clojure)
                    cd age/impl/clojure && clojure -M:bench -m bench-sayableage
                    ;;
                cobol)
                    cd age/impl/cobol && cmake -B build && cmake --build build --target cobol_bench_target && ./build/bench_sayableage_cobol
                    ;;
                cpp)
                    cd age/impl/cpp && cmake -B build -DCMAKE_BUILD_TYPE=Release && cmake --build build --target bench_sayableage && ./build/bench_sayableage
                    ;;
                csharp)
                    cd age/impl/csharp && dotnet run --project SayableAge.Bench -c Release
                    ;;
                dart)
                    cd age/impl/dart && dart run benchmark/bench_sayableage.dart
                    ;;
                elixir)
                    cd age/impl/elixir && mix run bench/bench_sayableage.exs
                    ;;
                elm)
                    echo "Elm benchmarking is not supported (no native timing primitives)."
                    ;;
                erlang)
                    cd age/impl/erlang && rebar3 compile && erlc -pa _build/default/lib/sayableage/ebin -o _build/default/lib/sayableage/ebin bench/bench_sayableage.erl && erl -pa _build/default/lib/sayableage/ebin -noshell -eval 'bench_sayableage:main()' -s init stop
                    ;;
                fortran)
                    cd age/impl/fortran && cmake -B build -DCMAKE_BUILD_TYPE=Release && cmake --build build --target bench_sayableage && ./build/bench_sayableage
                    ;;
                fsharp)
                    cd age/impl/fsharp && dotnet run --project SayableAge.Bench -c Release
                    ;;
                gleam)
                    cd age/impl/gleam && gleam build && erl -pa build/dev/erlang/sayableage/ebin -pa build/dev/erlang/gleam_stdlib/ebin -noshell -eval 'bench_sayableage:main()' -s init stop
                    ;;
                go)
                    cd age/impl/go && go run ./cmd/bench/
                    ;;
                groovy)
                    cd age/impl/groovy && ./gradlew -q classes && groovy -cp build/classes/groovy/main src/main/groovy/sayableage/bench/Benchmark.groovy
                    ;;
                haskell)
                    cd age/impl/haskell && cabal run bench-sayableage
                    ;;
                java)
                    cd age/impl/java && ./gradlew -q classes && java -cp build/classes/java/main sayableage.bench.Benchmark
                    ;;
                kotlin)
                    cd age/impl/kotlin && ./gradlew -q classes && java -cp "build/classes/kotlin/main:$(find ~/.gradle/caches -name 'kotlin-stdlib-*.jar' 2>/dev/null | head -1)" sayableage.bench.BenchmarkKt
                    ;;
                lua)
                    cd age/impl/lua && lua5.4 bench/bench_sayableage.lua
                    ;;
                ocaml)
                    cd age/impl/ocaml && eval "$(opam env 2>/dev/null)" && dune exec bench/bench_sayableage.exe
                    ;;
                perl)
                    cd age/impl/perl && perl bench/bench_sayableage.pl
                    ;;
                php)
                    cd age/impl/php && php bench/bench_sayableage.php
                    ;;
                python)
                    cd age/impl/python && uv run python benchmarks/bench_sayableage.py
                    ;;
                ruby)
                    cd age/impl/ruby && ruby bench/bench_sayableage.rb
                    ;;
                rust)
                    cd age/impl/rust && cargo run --release --bin bench_sayableage
                    ;;
                scala)
                    cd age/impl/scala && ./gradlew -q classes && java -cp "build/classes/scala/main:$(find ~/.gradle/caches -name 'scala3-library_3-*.jar' 2>/dev/null | head -1):$(find ~/.gradle/caches -name 'scala-library-*.jar' 2>/dev/null | head -1)" sayableage.bench.Benchmark
                    ;;
                swift)
                    cd age/impl/swift && swift run -c release Benchmark
                    ;;
                typescript)
                    cd age/impl/typescript && npx tsx bench/bench_sayableage.ts
                    ;;
                zig)
                    cd age/impl/zig && zig build -Doptimize=ReleaseFast && ./zig-out/bin/bench_sayableage
                    ;;
                *)
                    echo "Unknown target: $_target (try 'just benchmark cpu help')" >&2
                    exit 1
                    ;;
            esac
        ) 2>&1 | tee ".logs/benchmark/$name.log"
        if [ -n "${SUDO_USER:-}" ]; then chown -R "${SUDO_USER}" .logs/benchmark 2>/dev/null; fi
    fi
