# parent-time task runner
# Run `just --list` to see all available commands.

python := if `which python3 2>/dev/null || true` != "" { "python3" } else { "python" }

# Run all test suites + codegen check
[group('test')]
test *target:
    #!/usr/bin/env bash
    set -euo pipefail
    source scripts/_lang-helpers.sh
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
            dep=$(_dep "$target")
            if [ -z "$dep" ] || command -v "$dep" &>/dev/null; then
                args+=("test $target")
            else
                args+=("skip:$target")
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
        scripts/runner/run-parallel.sh ${_jflag:+-j "$_jflag"} ${_sflag:+-s "$_sflag"} test "${args[@]}"
    else
        name=$(_name "$_target")
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
    source scripts/_lang-helpers.sh
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
            dep=$(_dep "$target")
            if [ -z "$dep" ] || command -v "$dep" &>/dev/null; then
                args+=("build $target")
            else
                args+=("skip:$target")
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
        scripts/runner/run-parallel.sh ${_jflag:+-j "$_jflag"} ${_sflag:+-s "$_sflag"} build "${args[@]}"
    else
        name=$(_name "$_target")
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
                codegen/README.md locales/README.md tests/README.md tests/testing.md \
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
    {{python}} -m codegen.align_tables --check \
        README.md CLAUDE.md CONTRIBUTING.md \
        codegen/README.md locales/README.md tests/README.md tests/testing.md \
        docs/*.md src/*/README.md

# Run all available linters
[group('lint')]
lint *target:
    #!/usr/bin/env bash
    set -euo pipefail
    source scripts/_lang-helpers.sh
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
            dep=$(_dep "$target")
            if [ -z "$dep" ] || command -v "$dep" &>/dev/null; then
                args+=("lint $target")
            else
                args+=("skip:$target")
            fi
        done
        scripts/runner/run-parallel.sh ${_jflag:+-j "$_jflag"} ${_sflag:+-s "$_sflag"} lint "${args[@]}"
    else
        name=$(_name "$_target")
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
        scripts/runner/run-parallel.sh ${_jflag:+-j "$_jflag"} ${_sflag:+-s "$_sflag"} clean "${args[@]}"
    elif [ "$_target" = "ada" ] || [ "$_target" = "ad" ]; then
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
        rm -rf src/c/build
    elif [ "$_target" = "cli" ]; then
        rm -rf cli/build
    elif [ "$_target" = "cpp" ] || [ "$_target" = "c++" ]; then
        rm -rf src/cpp/build
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

# Install language toolchains (all if no args, or specific languages)
[group('setup')]
install *langs:
    #!/usr/bin/env bash
    set -euo pipefail
    source scripts/_lang-helpers.sh

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
            "  just install           Install all 28 language toolchains" \
            "  just install go rust   Install Go and Rust only" \
            "  just install rs        Install Rust (abbreviation)"
        exit 0
    fi
    install_all=false
    if [ -z "$langs" ]; then
        langs="$_ALL_LANGS"
        install_all=true
    fi
    failed=""
    for lang in $langs; do
        name=$(_check "$lang" "install")
        if $install_all; then
            bash "scripts/installers/${name}.sh" install || failed="$failed $lang"
        else
            bash "scripts/installers/${name}.sh" install
        fi
    done
    if [ -n "$failed" ]; then
        echo "" >&2
        echo "Failed to install:$failed" >&2
        exit 1
    fi

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
    source scripts/_lang-helpers.sh
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
            dep=$(_dep "$target")
            if [ -z "$dep" ] || command -v "$dep" &>/dev/null; then
                args+=("_rebuild $target")
            else
                args+=("skip:$target")
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
        scripts/runner/run-parallel.sh ${_jflag:+-j "$_jflag"} ${_sflag:+-s "$_sflag"} rebuild "${args[@]}"
    else
        name=$(_name "$_target")
        just clean "$_target" && just build "$_target"
    fi

# Clean then test all targets, or a single target
[group('test')]
retest *target:
    #!/usr/bin/env bash
    set -euo pipefail
    source scripts/_lang-helpers.sh
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
            dep=$(_dep "$target")
            if [ -z "$dep" ] || command -v "$dep" &>/dev/null; then
                args+=("_retest $target")
            else
                args+=("skip:$target")
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
        scripts/runner/run-parallel.sh ${_jflag:+-j "$_jflag"} ${_sflag:+-s "$_sflag"} retest "${args[@]}"
    else
        just clean "$_target" && just test "$_target"
    fi

# Interactive onboarding: show project info, installed languages, and install menu
[group('setup')]
get-started *args:
    @bash scripts/get-started.sh {{args}}

# Uninstall language toolchains
[group('setup')]
uninstall *langs:
    #!/usr/bin/env bash
    set -euo pipefail
    source scripts/_lang-helpers.sh

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
    if [ -z "$langs" ]; then
        echo "Usage: just uninstall <lang> [lang...] (try 'just uninstall help')" >&2
        exit 1
    fi
    for lang in $langs; do
        name=$(_check "$lang" "uninstall")
        bash "scripts/installers/${name}.sh" uninstall
    done
