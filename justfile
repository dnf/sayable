# parent-time task runner
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
            "Run all test suites in parallel, or a single target's tests." \
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
            "  just test go           Run Go tests only" \
            "  just test rs           Run Rust tests (abbreviation)" \
            "  just test cli          Run CLI integration tests" \
            "  just test -j 4         Run all in parallel with 4 job slots" \
            "  just test -j 2 -s full Run with 2 slots, full-width visualization"
        exit 0
    fi
    if [ -z "$_target" ]; then
        _tools="cli codegen"
        args=("check")
        for target in $_ALL_LANGS; do
            [ -z "$target" ] && continue
            if _is_disabled "$target"; then
                args+=("disable:$target")
            else
                dep=$(_dep "$target")
                if [ -z "$dep" ] || command -v "$dep" &>/dev/null; then
                    args+=("test $target")
                else
                    args+=("skip:$target")
                fi
            fi
        done
        args+=("---")
        for target in $_tools; do
            dep=$(_dep "$target")
            if [ -z "$dep" ] || command -v "$dep" &>/dev/null; then
                args+=("test $target")
            else
                args+=("skip:$target")
            fi
        done
        .hecatron/tools/runner/run-parallel.sh ${_jflag:+-j "$_jflag"} ${_sflag:+-s "$_sflag"} test "${args[@]}"
    else
        name=$(_name "$_target")
        if _is_removed "${name}"; then
            echo "Language '${name}' is not added. Run 'just add ${name}' to add it." >&2
            exit 1
        fi
        mkdir -p .logs/test
        (
            if [ "$_target" = "typescript" ] || [ "$_target" = "ts" ]; then
                cd src/typescript && npx vitest run
            elif [ "$_target" = "python" ] || [ "$_target" = "py" ]; then
                cd src/python && uv run --extra dev pytest tests/
            elif [ "$_target" = "go" ]; then
                cd src/go && go test ./...
            elif [ "$_target" = "ruby" ] || [ "$_target" = "rb" ]; then
                cd src/ruby && ruby -Ilib test/test_formatter.rb
            elif [ "$_target" = "rust" ] || [ "$_target" = "rs" ]; then
                cd src/rust && cargo test
            elif [ "$_target" = "kotlin" ] || [ "$_target" = "kt" ]; then
                cd src/kotlin && ./gradlew test
            elif [ "$_target" = "cpp" ] || [ "$_target" = "c++" ]; then
                just build cpp
                cd src/cpp/build && ctest --output-on-failure
            elif [ "$_target" = "c" ]; then
                just build c
                cd src/c/build && ctest --output-on-failure
            elif [ "$_target" = "cli" ]; then
                just build cli
                bash cli/test.sh
            elif [ "$_target" = "php" ]; then
                cd src/php && php vendor/bin/phpunit tests/
            elif [ "$_target" = "java" ]; then
                cd src/java && ./gradlew test
            elif [ "$_target" = "csharp" ] || [ "$_target" = "cs" ]; then
                cd src/csharp && dotnet test
            elif [ "$_target" = "dart" ] || [ "$_target" = "dt" ]; then
                cd src/dart && dart test
            elif [ "$_target" = "fsharp" ] || [ "$_target" = "fs" ]; then
                cd src/fsharp && dotnet test
            elif [ "$_target" = "swift" ] || [ "$_target" = "sw" ]; then
                cd src/swift && swift test
            elif [ "$_target" = "haskell" ] || [ "$_target" = "hs" ]; then
                cd src/haskell && cabal test
            elif [ "$_target" = "erlang" ] || [ "$_target" = "erl" ]; then
                cd src/erlang && rebar3 eunit
            elif [ "$_target" = "fortran" ] || [ "$_target" = "ft" ]; then
                just build fortran
                cd src/fortran/build && ctest --output-on-failure
            elif [ "$_target" = "groovy" ] || [ "$_target" = "gy" ]; then
                cd src/groovy && ./gradlew test
            elif [ "$_target" = "clojure" ] || [ "$_target" = "clj" ]; then
                cd src/clojure && clojure -M:test
            elif [ "$_target" = "cobol" ] || [ "$_target" = "cb" ]; then
                just build cobol
                cd src/cobol/build && ctest --output-on-failure
            elif [ "$_target" = "scala" ] || [ "$_target" = "sc" ]; then
                cd src/scala && ./gradlew test
            elif [ "$_target" = "elixir" ] || [ "$_target" = "ex" ]; then
                cd src/elixir && mix test
            elif [ "$_target" = "gleam" ] || [ "$_target" = "gm" ]; then
                cd src/gleam && gleam test
            elif [ "$_target" = "elm" ] || [ "$_target" = "el" ]; then
                cd src/elm && elm-test
            elif [ "$_target" = "lua" ] || [ "$_target" = "lu" ]; then
                cd src/lua && busted test_parenttime.lua
            elif [ "$_target" = "ocaml" ] || [ "$_target" = "ml" ]; then
                cd src/ocaml && eval "$(opam env 2>/dev/null)" && dune runtest
            elif [ "$_target" = "perl" ] || [ "$_target" = "pl" ]; then
                cd src/perl && prove -Ilib t/
            elif [ "$_target" = "ada" ] || [ "$_target" = "ad" ]; then
                _ada_env
                _largs=""
                if [ "$(uname -s)" = "Darwin" ]; then
                    _sdk="$(xcrun --show-sdk-path 2>/dev/null)"
                    [ -n "$_sdk" ] && _largs="-largs -L$_sdk/usr/lib"
                fi
                cd src/ada && gprbuild -P parenttime.gpr -XBUILD_MODE=test $_largs && ./build/test_format_age
            elif [ "$_target" = "zig" ] || [ "$_target" = "zg" ]; then
                cd src/zig && zig build test
            elif [ "$_target" = "codegen" ]; then
                {{python}} -m unittest codegen.test_locale_groups -v
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
                dep=$(_dep "$target")
                if [ -z "$dep" ] || command -v "$dep" &>/dev/null; then
                    args+=("build $target")
                else
                    args+=("skip:$target")
                fi
            fi
        done
        args+=("---")
        for target in $_tools; do
            dep=$(_dep "$target")
            if [ -z "$dep" ] || command -v "$dep" &>/dev/null; then
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
                cd src/ada && gprbuild -P parenttime.gpr -XBUILD_MODE=build
            elif [ "$_target" = "typescript" ] || [ "$_target" = "ts" ]; then
                cd src/typescript && npm run build
            elif [ "$_target" = "rust" ] || [ "$_target" = "rs" ]; then
                cd src/rust && cargo build
            elif [ "$_target" = "kotlin" ] || [ "$_target" = "kt" ]; then
                cd src/kotlin && ./gradlew build
            elif [ "$_target" = "cpp" ] || [ "$_target" = "c++" ]; then
                cd src/cpp && cmake -B build && cmake --build build
            elif [ "$_target" = "c" ]; then
                cd src/c && cmake -B build && cmake --build build
            elif [ "$_target" = "cobol" ] || [ "$_target" = "cb" ]; then
                cd src/cobol && cmake -B build && cmake --build build
            elif [ "$_target" = "cli" ]; then
                cd cli && cmake -B build -DCMAKE_BUILD_TYPE=Release && cmake --build build
            elif [ "$_target" = "java" ]; then
                cd src/java && ./gradlew build
            elif [ "$_target" = "csharp" ] || [ "$_target" = "cs" ]; then
                cd src/csharp && dotnet build
            elif [ "$_target" = "fsharp" ] || [ "$_target" = "fs" ]; then
                cd src/fsharp && dotnet build
            elif [ "$_target" = "swift" ] || [ "$_target" = "sw" ]; then
                cd src/swift && swift build
            elif [ "$_target" = "haskell" ] || [ "$_target" = "hs" ]; then
                cd src/haskell && cabal build
            elif [ "$_target" = "ocaml" ] || [ "$_target" = "ml" ]; then
                cd src/ocaml && eval "$(opam env 2>/dev/null)" && dune build
            elif [ "$_target" = "elixir" ] || [ "$_target" = "ex" ]; then
                cd src/elixir && mix compile --warnings-as-errors
            elif [ "$_target" = "gleam" ] || [ "$_target" = "gm" ]; then
                cd src/gleam && gleam build
            elif [ "$_target" = "erlang" ] || [ "$_target" = "erl" ]; then
                cd src/erlang && rebar3 compile
            elif [ "$_target" = "fortran" ] || [ "$_target" = "ft" ]; then
                cd src/fortran && cmake -B build && cmake --build build
            elif [ "$_target" = "groovy" ] || [ "$_target" = "gy" ]; then
                cd src/groovy && ./gradlew build
            elif [ "$_target" = "scala" ] || [ "$_target" = "sc" ]; then
                cd src/scala && ./gradlew build
            elif [ "$_target" = "zig" ] || [ "$_target" = "zg" ]; then
                cd src/zig && zig build
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
        locales)
            {{python}} -m codegen.generate {{args}}
            uv run --project src/python {{python}} -m codegen.docgen {{args}}
            ;;
        *)
            echo "error: unknown generate target '{{target}}'" >&2
            echo "Valid targets: locales" >&2
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
            {{python}} -m codegen.align_tables {{args}} \
                README.md CLAUDE.md CONTRIBUTING.md \
                codegen/README.md config/README.md locales/README.md tests/README.md \
                docs/*.md src/*/README.md
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
    {{python}} -m codegen.generate --check
    uv run --project src/python {{python}} -m codegen.docgen --check
    {{python}} .hecatron/tools/codegen/dockerfile.py --check

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
        {{python}} -c "import json; print(json.load(open('config/version.json'))['version'])"
        exit 0
    fi
    if [[ ! "${ver}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "error: version must be semver (X.Y.Z), got '${ver}'" >&2
        exit 1
    fi

    old="$({{python}} -c "import json; print(json.load(open('config/version.json'))['version'])")"
    if [ "${ver}" = "${old}" ]; then
        echo "Version is already ${ver}" >&2
        exit 0
    fi

    echo "Bumping version: ${old} → ${ver}"

    # 1. Update version.json
    printf '{\n  "version": "%s"\n}\n' "${ver}" > config/version.json
    echo "  updated config/version.json"

    # 2. Update all language implementations via their installer scripts
    for lang in ${_ALL_LANGS}; do
        [ -z "${lang}" ] && continue
        bash ".hecatron/languages/${lang}/version.sh" "${ver}"
        echo "  updated ${lang}"
    done

    # 3. Regenerate C header (uses updated emitter.py)
    {{python}} -m codegen.generate
    uv run --project src/python {{python}} -m codegen.docgen
    echo "  regenerated locale files"

    # 4. Update docs/versioning.md
    _sed_i() {
        if [ "$(uname -s)" = "Darwin" ]; then
            sed -i '' "$@"
        else
            sed -i "$@"
        fi
    }
    _sed_i "s/\"version\": \"${old}\"/\"version\": \"${ver}\"/" docs/versioning.md
    _sed_i "s/#define PARENTTIME_VERSION \"${old}\"/#define PARENTTIME_VERSION \"${ver}\"/" docs/versioning.md
    _sed_i "s/(def version \"${old}\")/(def version \"${ver}\")/" docs/versioning.md
    _sed_i "s/version = \"${old}\"/version = \"${ver}\"/g" docs/versioning.md
    _sed_i "s/-define(VERSION, \"${old}\")/-define(VERSION, \"${ver}\")/" docs/versioning.md
    _sed_i "s/__version__ = \"${old}\"/__version__ = \"${ver}\"/" docs/versioning.md
    echo "  updated docs/versioning.md"

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
            "" \
            "  Other languages use warnings-as-errors in their build step (no separate linter)." \
            "" \
            "Flags:" \
            "  -j VALUE   Set concurrency: integer, percentage (default 50%), or 'unlimited'" \
            "  -s MODE    Visualization: scroll (default), full, or zoom" \
            "" \
            "Examples:" \
            "  just lint              Run all 12 linters in parallel" \
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
                dep=$(_dep "$target")
                if [ -z "$dep" ] || command -v "$dep" &>/dev/null; then
                    args+=("lint $target")
                else
                    args+=("skip:$target")
                fi
            fi
        done
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
                cd src/typescript && npm run lint
            elif [ "$_target" = "dart" ] || [ "$_target" = "dt" ]; then
                cd src/dart && dart analyze
            elif [ "$_target" = "python" ] || [ "$_target" = "py" ]; then
                cd src/python && uv run --extra dev ruff check . && uv run --extra dev pyright
            elif [ "$_target" = "go" ]; then
                cd src/go && golangci-lint run
            elif [ "$_target" = "ruby" ] || [ "$_target" = "rb" ]; then
                cd src/ruby && bundle exec rubocop
            elif [ "$_target" = "rust" ] || [ "$_target" = "rs" ]; then
                cd src/rust && cargo clippy
            elif [ "$_target" = "php" ]; then
                cd src/php && composer analyse && composer cs-check
            elif [ "$_target" = "lua" ] || [ "$_target" = "lu" ]; then
                cd src/lua && luacheck parenttime.lua locales/
            elif [ "$_target" = "kotlin" ] || [ "$_target" = "kt" ]; then
                echo "Kotlin uses warnings-as-errors in build (no separate linter)"
            elif [ "$_target" = "c" ]; then
                echo "C uses warnings-as-errors in build (no separate linter)"
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
            elif [ "$_target" = "zig" ] || [ "$_target" = "zg" ]; then
                echo "Zig uses warnings-as-errors in build (no separate linter)"
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
        rm -rf src/ada/build src/ada/obj
    elif [ "$_target" = "typescript" ] || [ "$_target" = "ts" ]; then
        rm -rf src/typescript/dist
    elif [ "$_target" = "python" ] || [ "$_target" = "py" ]; then
        find src/python -type d -name __pycache__ -not -path '*/\.venv/*' -exec rm -rf {} + 2>/dev/null || true
        rm -rf src/python/.pytest_cache
    elif [ "$_target" = "rust" ] || [ "$_target" = "rs" ]; then
        rm -rf src/rust/target
    elif [ "$_target" = "kotlin" ] || [ "$_target" = "kt" ]; then
        rm -rf src/kotlin/build src/kotlin/.gradle
    elif [ "$_target" = "c" ]; then
        rm -rf src/c/build || rm -rf src/c/build
    elif [ "$_target" = "cli" ]; then
        rm -rf cli/build || rm -rf cli/build
    elif [ "$_target" = "cpp" ] || [ "$_target" = "c++" ]; then
        rm -rf src/cpp/build || rm -rf src/cpp/build
    elif [ "$_target" = "java" ]; then
        rm -rf src/java/build src/java/.gradle
    elif [ "$_target" = "csharp" ] || [ "$_target" = "cs" ]; then
        rm -rf src/csharp/ParentTime/bin src/csharp/ParentTime/obj src/csharp/ParentTime.Tests/bin src/csharp/ParentTime.Tests/obj
    elif [ "$_target" = "fsharp" ] || [ "$_target" = "fs" ]; then
        rm -rf src/fsharp/ParentTime/bin src/fsharp/ParentTime/obj src/fsharp/ParentTime.Tests/bin src/fsharp/ParentTime.Tests/obj
    elif [ "$_target" = "swift" ] || [ "$_target" = "sw" ]; then
        rm -rf src/swift/.build
    elif [ "$_target" = "haskell" ] || [ "$_target" = "hs" ]; then
        rm -rf src/haskell/dist-newstyle
    elif [ "$_target" = "ocaml" ] || [ "$_target" = "ml" ]; then
        rm -rf src/ocaml/_build
    elif [ "$_target" = "erlang" ] || [ "$_target" = "erl" ]; then
        rm -rf src/erlang/_build
    elif [ "$_target" = "clojure" ] || [ "$_target" = "clj" ]; then
        rm -rf src/clojure/.cpcache
    elif [ "$_target" = "cobol" ] || [ "$_target" = "cb" ]; then
        rm -rf src/cobol/build
    elif [ "$_target" = "scala" ] || [ "$_target" = "sc" ]; then
        rm -rf src/scala/build src/scala/.gradle
    elif [ "$_target" = "zig" ] || [ "$_target" = "zg" ]; then
        rm -rf src/zig/zig-out src/zig/.zig-cache
    elif [ "$_target" = "elixir" ] || [ "$_target" = "ex" ]; then
        rm -rf src/elixir/_build
    elif [ "$_target" = "gleam" ] || [ "$_target" = "gm" ]; then
        rm -rf src/gleam/build
    elif [ "$_target" = "elm" ] || [ "$_target" = "el" ]; then
        rm -rf src/elm/elm-stuff
    elif [ "$_target" = "fortran" ] || [ "$_target" = "ft" ]; then
        rm -rf src/fortran/build
    elif [ "$_target" = "groovy" ] || [ "$_target" = "gy" ]; then
        rm -rf src/groovy/build src/groovy/.gradle
    elif [ "$_target" = "dart" ] || [ "$_target" = "dt" ]; then
        rm -rf src/dart/.dart_tool
    elif [ "$_target" = "codegen" ]; then
        find codegen -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
    elif [ "$_target" = "go" ] || [ "$_target" = "lua" ] || [ "$_target" = "lu" ] || [ "$_target" = "ruby" ] || [ "$_target" = "rb" ] || [ "$_target" = "perl" ] || [ "$_target" = "pl" ] || [ "$_target" = "php" ]; then
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
            "  just install           Install all 29 language toolchains" \
            "  just install go rust   Install Go and Rust only" \
            "  just install rs        Install Rust (abbreviation)"
        exit 0
    fi
    {{python}} .hecatron/tools/language/install.py $langs

# Build the CLI tool
[group('build')]
cli:
    cd cli && cmake -B build -DCMAKE_BUILD_TYPE=Release && cmake --build build

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
                dep=$(_dep "$target")
                if [ -z "$dep" ] || command -v "$dep" &>/dev/null; then
                    args+=("_rebuild $target")
                else
                    args+=("skip:$target")
                fi
            fi
        done
        args+=("---")
        for target in $_tools; do
            dep=$(_dep "$target")
            if [ -z "$dep" ] || command -v "$dep" &>/dev/null; then
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
        _tools="cli codegen"
        args=("check")
        for target in $_ALL_LANGS; do
            [ -z "$target" ] && continue
            if _is_disabled "$target"; then
                args+=("disable:$target")
            else
                dep=$(_dep "$target")
                if [ -z "$dep" ] || command -v "$dep" &>/dev/null; then
                    args+=("_retest $target")
                else
                    args+=("skip:$target")
                fi
            fi
        done
        args+=("---")
        for target in $_tools; do
            dep=$(_dep "$target")
            if [ -z "$dep" ] || command -v "$dep" &>/dev/null; then
                args+=("_retest $target")
            else
                args+=("skip:$target")
            fi
        done
        .hecatron/tools/runner/run-parallel.sh ${_jflag:+-j "$_jflag"} ${_sflag:+-s "$_sflag"} retest "${args[@]}"
    else
        just clean "$_target" && just test "$_target"
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
            cpu)   uv run --with matplotlib python3 benchmarks/cpu/report.py "$@" ;;
            build) uv run --with matplotlib python3 benchmarks/build/report.py "$@" ;;
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
                dep=$(_dep "$lang")
                if [ -z "$dep" ] || command -v "$dep" &>/dev/null; then
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
            ${_nice_cmd} python3 benchmarks/build/bench_build.py "${name}" 2>&1 | tee ".logs/benchmark/build-${name}.log"
            if [ -n "${SUDO_USER:-}" ]; then chown -R "${SUDO_USER}" .logs/benchmark benchmarks/build/results 2>/dev/null; fi
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
            dep=$(_dep "$lang")
            if [ -z "$dep" ] || command -v "$dep" &>/dev/null; then
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
                    cd src/ada && gprbuild -P parenttime.gpr -XBUILD_MODE=bench $_largs && ./build/bench_parenttime
                    ;;
                c)
                    cd src/c && cmake -B build -DCMAKE_BUILD_TYPE=Release && cmake --build build --target bench_parenttime && ./build/bench_parenttime
                    ;;
                clojure)
                    cd src/clojure && clojure -M:bench -m bench-parenttime
                    ;;
                cobol)
                    cd src/cobol && cmake -B build && cmake --build build --target cobol_bench_target && ./build/bench_parenttime_cobol
                    ;;
                cpp)
                    cd src/cpp && cmake -B build -DCMAKE_BUILD_TYPE=Release && cmake --build build --target bench_parenttime && ./build/bench_parenttime
                    ;;
                csharp)
                    cd src/csharp && dotnet run --project ParentTime.Bench -c Release
                    ;;
                dart)
                    cd src/dart && dart run benchmark/bench_parenttime.dart
                    ;;
                elixir)
                    cd src/elixir && mix run bench/bench_parenttime.exs
                    ;;
                elm)
                    echo "Elm benchmarking is not supported (no native timing primitives)."
                    ;;
                erlang)
                    cd src/erlang && rebar3 compile && erlc -pa _build/default/lib/parenttime/ebin -o _build/default/lib/parenttime/ebin bench/bench_parenttime.erl && erl -pa _build/default/lib/parenttime/ebin -noshell -eval 'bench_parenttime:main()' -s init stop
                    ;;
                fortran)
                    cd src/fortran && cmake -B build -DCMAKE_BUILD_TYPE=Release && cmake --build build --target bench_parenttime && ./build/bench_parenttime
                    ;;
                fsharp)
                    cd src/fsharp && dotnet run --project ParentTime.Bench -c Release
                    ;;
                gleam)
                    cd src/gleam && gleam build && erl -pa build/dev/erlang/parenttime/ebin -pa build/dev/erlang/gleam_stdlib/ebin -noshell -eval 'bench_parenttime:main()' -s init stop
                    ;;
                go)
                    cd src/go && go run ./cmd/bench/
                    ;;
                groovy)
                    cd src/groovy && ./gradlew -q classes && groovy -cp build/classes/groovy/main src/main/groovy/parenttime/bench/Benchmark.groovy
                    ;;
                haskell)
                    cd src/haskell && cabal run bench-parenttime
                    ;;
                java)
                    cd src/java && ./gradlew -q classes && java -cp build/classes/java/main parenttime.bench.Benchmark
                    ;;
                kotlin)
                    cd src/kotlin && ./gradlew -q classes && java -cp "build/classes/kotlin/main:$(find ~/.gradle/caches -name 'kotlin-stdlib-*.jar' 2>/dev/null | head -1)" parenttime.bench.BenchmarkKt
                    ;;
                lua)
                    cd src/lua && lua5.4 bench/bench_parenttime.lua
                    ;;
                ocaml)
                    cd src/ocaml && eval "$(opam env 2>/dev/null)" && dune exec bench/bench_parenttime.exe
                    ;;
                perl)
                    cd src/perl && perl bench/bench_parenttime.pl
                    ;;
                php)
                    cd src/php && php bench/bench_parenttime.php
                    ;;
                python)
                    cd src/python && uv run python benchmarks/bench_parenttime.py
                    ;;
                ruby)
                    cd src/ruby && ruby bench/bench_parenttime.rb
                    ;;
                rust)
                    cd src/rust && cargo run --release --bin bench_parenttime
                    ;;
                scala)
                    cd src/scala && ./gradlew -q classes && java -cp "build/classes/scala/main:$(find ~/.gradle/caches -name 'scala3-library_3-*.jar' 2>/dev/null | head -1):$(find ~/.gradle/caches -name 'scala-library-*.jar' 2>/dev/null | head -1)" parenttime.bench.Benchmark
                    ;;
                swift)
                    cd src/swift && swift run -c release Benchmark
                    ;;
                typescript)
                    cd src/typescript && npx tsx bench/bench_parenttime.ts
                    ;;
                zig)
                    cd src/zig && zig build -Doptimize=ReleaseFast && ./zig-out/bin/bench_parenttime
                    ;;
                *)
                    echo "Unknown target: $_target (try 'just benchmark cpu help')" >&2
                    exit 1
                    ;;
            esac
        ) 2>&1 | tee ".logs/benchmark/$name.log"
        if [ -n "${SUDO_USER:-}" ]; then chown -R "${SUDO_USER}" .logs/benchmark 2>/dev/null; fi
    fi
