# parent-time task runner
# Run `just --list` to see all available commands.

python := if `which python3 2>/dev/null || true` != "" { "python3" } else { "python" }

# Run all test suites + codegen check
[group('test')]
test *lang:
    #!/usr/bin/env bash
    set -euo pipefail
    _name() { case "$1" in ts) echo typescript;; py) echo python;; rb) echo ruby;; rs) echo rust;; kt) echo kotlin;; c++) echo cpp;; cs) echo csharp;; sw) echo swift;; hs) echo haskell;; ex) echo elixir;; erl) echo erlang;; clj) echo clojure;; sc) echo scala;; zg) echo zig;; el) echo elm;; pl) echo perl;; *) echo "$1";; esac; }
    _jflag=""; _sflag=""; _langs=""; _prev=""
    for _a in {{lang}}; do
        if [ "$_prev" = "-j" ]; then _jflag="$_a"; _prev=""; continue; fi
        if [ "$_prev" = "-s" ]; then _sflag="$_a"; _prev=""; continue; fi
        if [ "$_a" = "-j" ]; then _prev="-j"; continue; fi
        if [ "$_a" = "-s" ]; then _prev="-s"; continue; fi
        _langs="${_langs:+$_langs }$_a"
    done
    if [ -z "$_langs" ]; then
        _tool() { case "$1" in c|cpp) echo cmake;; clojure) echo clojure;; csharp) echo dotnet;; elixir) echo mix;; elm) echo elm;; erlang) echo rebar3;; go) echo go;; haskell) echo cabal;; java|kotlin|scala) echo java;; perl) echo perl;; php) echo php;; python) echo uv;; ruby) echo ruby;; rust) echo cargo;; swift) echo swift;; typescript) echo npm;; zig) echo zig;; esac; }
        args=("check")
        for lang in c clojure cpp csharp elixir elm erlang go haskell java kotlin perl php python ruby rust scala swift typescript zig; do
            tool=$(_tool "$lang")
            if [ -z "$tool" ] || command -v "$tool" &>/dev/null; then
                args+=("test $lang")
            else
                args+=("skip:$lang")
            fi
        done
        scripts/run-parallel.sh ${_jflag:+-j "$_jflag"} ${_sflag:+-s "$_sflag"} test "${args[@]}"
    else
        name=$(_name "$_langs")
        mkdir -p .logs/test
        (
            if [ "$_langs" = "typescript" ] || [ "$_langs" = "ts" ]; then
                cd src/typescript && npx vitest run
            elif [ "$_langs" = "python" ] || [ "$_langs" = "py" ]; then
                cd src/python && uv run --extra dev pytest tests/
            elif [ "$_langs" = "go" ]; then
                cd src/go && go test ./...
            elif [ "$_langs" = "ruby" ] || [ "$_langs" = "rb" ]; then
                cd src/ruby && ruby -Ilib test/test_formatter.rb
            elif [ "$_langs" = "rust" ] || [ "$_langs" = "rs" ]; then
                cd src/rust && cargo test
            elif [ "$_langs" = "kotlin" ] || [ "$_langs" = "kt" ]; then
                cd src/kotlin && ./gradlew test
            elif [ "$_langs" = "cpp" ] || [ "$_langs" = "c++" ]; then
                just build cpp
                cd src/cpp/build && ctest --output-on-failure
            elif [ "$_langs" = "c" ]; then
                just build c
                cd src/c/build && ctest --output-on-failure
            elif [ "$_langs" = "php" ]; then
                cd src/php && php vendor/bin/phpunit tests/
            elif [ "$_langs" = "java" ]; then
                cd src/java && ./gradlew test
            elif [ "$_langs" = "csharp" ] || [ "$_langs" = "cs" ]; then
                cd src/csharp && dotnet test
            elif [ "$_langs" = "swift" ] || [ "$_langs" = "sw" ]; then
                cd src/swift && swift test
            elif [ "$_langs" = "haskell" ] || [ "$_langs" = "hs" ]; then
                cd src/haskell && cabal test
            elif [ "$_langs" = "erlang" ] || [ "$_langs" = "erl" ]; then
                cd src/erlang && rebar3 eunit
            elif [ "$_langs" = "clojure" ] || [ "$_langs" = "clj" ]; then
                cd src/clojure && clojure -M:test
            elif [ "$_langs" = "scala" ] || [ "$_langs" = "sc" ]; then
                cd src/scala && ./gradlew test
            elif [ "$_langs" = "elixir" ] || [ "$_langs" = "ex" ]; then
                cd src/elixir && mix test
            elif [ "$_langs" = "elm" ] || [ "$_langs" = "el" ]; then
                cd src/elm && elm-test
            elif [ "$_langs" = "perl" ] || [ "$_langs" = "pl" ]; then
                cd src/perl && prove -Ilib t/
            elif [ "$_langs" = "zig" ] || [ "$_langs" = "zg" ]; then
                cd src/zig && zig build test
            elif [ "$_langs" = "codegen" ]; then
                {{python}} -m unittest codegen.test_locale_groups -v
            else
                echo "Unknown language: $_langs"
                echo "Valid: c, clojure (clj), elixir (ex), elm (el), typescript (ts), python (py), go, ruby (rb), rust (rs), kotlin (kt), cpp (c++), perl (pl), php, java, csharp (cs), swift (sw), haskell (hs), erlang (erl), scala (sc), zig (zg), codegen"
                exit 1
            fi
        ) 2>&1 | tee ".logs/test/$name.log"
    fi

# Build all languages that have a build step
[group('build')]
build *lang:
    #!/usr/bin/env bash
    set -euo pipefail
    _name() { case "$1" in ts) echo typescript;; py) echo python;; rb) echo ruby;; rs) echo rust;; kt) echo kotlin;; c++) echo cpp;; cs) echo csharp;; sw) echo swift;; hs) echo haskell;; ex) echo elixir;; erl) echo erlang;; clj) echo clojure;; sc) echo scala;; zg) echo zig;; el) echo elm;; pl) echo perl;; *) echo "$1";; esac; }
    _jflag=""; _sflag=""; _langs=""; _prev=""
    for _a in {{lang}}; do
        if [ "$_prev" = "-j" ]; then _jflag="$_a"; _prev=""; continue; fi
        if [ "$_prev" = "-s" ]; then _sflag="$_a"; _prev=""; continue; fi
        if [ "$_a" = "-j" ]; then _prev="-j"; continue; fi
        if [ "$_a" = "-s" ]; then _prev="-s"; continue; fi
        _langs="${_langs:+$_langs }$_a"
    done
    if [ -z "$_langs" ]; then
        _tool() { case "$1" in c|cpp) echo cmake;; csharp) echo dotnet;; elixir) echo mix;; erlang) echo rebar3;; haskell) echo cabal;; java|kotlin|scala) echo java;; rust) echo cargo;; swift) echo swift;; typescript) echo npm;; zig) echo zig;; esac; }
        args=()
        for lang in c cpp csharp elixir erlang haskell java kotlin rust scala swift typescript zig; do
            tool=$(_tool "$lang")
            if [ -z "$tool" ] || command -v "$tool" &>/dev/null; then
                args+=("build $lang")
            else
                args+=("skip:$lang")
            fi
        done
        scripts/run-parallel.sh ${_jflag:+-j "$_jflag"} ${_sflag:+-s "$_sflag"} build "${args[@]}"
    else
        name=$(_name "$_langs")
        mkdir -p .logs/build
        (
            if [ "$_langs" = "typescript" ] || [ "$_langs" = "ts" ]; then
                cd src/typescript && npm run build
            elif [ "$_langs" = "rust" ] || [ "$_langs" = "rs" ]; then
                cd src/rust && cargo build
            elif [ "$_langs" = "kotlin" ] || [ "$_langs" = "kt" ]; then
                cd src/kotlin && ./gradlew build
            elif [ "$_langs" = "cpp" ] || [ "$_langs" = "c++" ]; then
                cd src/cpp && cmake -B build && cmake --build build
            elif [ "$_langs" = "c" ]; then
                cd src/c && cmake -B build && cmake --build build
            elif [ "$_langs" = "java" ]; then
                cd src/java && ./gradlew build
            elif [ "$_langs" = "csharp" ] || [ "$_langs" = "cs" ]; then
                cd src/csharp && dotnet build
            elif [ "$_langs" = "swift" ] || [ "$_langs" = "sw" ]; then
                cd src/swift && swift build
            elif [ "$_langs" = "haskell" ] || [ "$_langs" = "hs" ]; then
                cd src/haskell && cabal build
            elif [ "$_langs" = "elixir" ] || [ "$_langs" = "ex" ]; then
                cd src/elixir && mix compile --warnings-as-errors
            elif [ "$_langs" = "erlang" ] || [ "$_langs" = "erl" ]; then
                cd src/erlang && rebar3 compile
            elif [ "$_langs" = "scala" ] || [ "$_langs" = "sc" ]; then
                cd src/scala && ./gradlew build
            elif [ "$_langs" = "zig" ] || [ "$_langs" = "zg" ]; then
                cd src/zig && zig build
            else
                echo "No build step for: $_langs"
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
lint *lang:
    #!/usr/bin/env bash
    set -euo pipefail
    _name() { case "$1" in ts) echo typescript;; py) echo python;; rb) echo ruby;; rs) echo rust;; kt) echo kotlin;; c++) echo cpp;; cs) echo csharp;; sw) echo swift;; hs) echo haskell;; ex) echo elixir;; erl) echo erlang;; clj) echo clojure;; sc) echo scala;; zg) echo zig;; el) echo elm;; pl) echo perl;; *) echo "$1";; esac; }
    _jflag=""; _sflag=""; _langs=""; _prev=""
    for _a in {{lang}}; do
        if [ "$_prev" = "-j" ]; then _jflag="$_a"; _prev=""; continue; fi
        if [ "$_prev" = "-s" ]; then _sflag="$_a"; _prev=""; continue; fi
        if [ "$_a" = "-j" ]; then _prev="-j"; continue; fi
        if [ "$_a" = "-s" ]; then _prev="-s"; continue; fi
        _langs="${_langs:+$_langs }$_a"
    done
    if [ -z "$_langs" ]; then
        _tool() { case "$1" in csharp) echo dotnet;; go) echo golangci-lint;; java) echo java;; php) echo php;; python) echo uv;; ruby) echo ruby;; rust) echo cargo;; swift) echo swift;; typescript) echo npm;; esac; }
        args=()
        for lang in csharp go java php python ruby rust swift typescript; do
            tool=$(_tool "$lang")
            if [ -z "$tool" ] || command -v "$tool" &>/dev/null; then
                args+=("lint $lang")
            else
                args+=("skip:$lang")
            fi
        done
        scripts/run-parallel.sh ${_jflag:+-j "$_jflag"} ${_sflag:+-s "$_sflag"} lint "${args[@]}"
    else
        name=$(_name "$_langs")
        mkdir -p .logs/lint
        (
            if [ "$_langs" = "typescript" ] || [ "$_langs" = "ts" ]; then
                cd src/typescript && npm run lint
            elif [ "$_langs" = "python" ] || [ "$_langs" = "py" ]; then
                cd src/python && uv run --extra dev ruff check . && uv run --extra dev pyright
            elif [ "$_langs" = "go" ]; then
                cd src/go && golangci-lint run
            elif [ "$_langs" = "ruby" ] || [ "$_langs" = "rb" ]; then
                cd src/ruby && bundle exec rubocop
            elif [ "$_langs" = "rust" ] || [ "$_langs" = "rs" ]; then
                cd src/rust && cargo clippy
            elif [ "$_langs" = "php" ]; then
                cd src/php && composer analyse && composer cs-check
            elif [ "$_langs" = "kotlin" ] || [ "$_langs" = "kt" ]; then
                echo "Kotlin uses warnings-as-errors in build (no separate linter)"
            elif [ "$_langs" = "c" ]; then
                echo "C uses warnings-as-errors in build (no separate linter)"
            elif [ "$_langs" = "cpp" ] || [ "$_langs" = "c++" ]; then
                echo "C++ uses warnings-as-errors in build (no separate linter)"
            elif [ "$_langs" = "java" ]; then
                echo "Java uses warnings-as-errors in build (no separate linter)"
            elif [ "$_langs" = "csharp" ] || [ "$_langs" = "cs" ]; then
                echo "C# uses TreatWarningsAsErrors in build (no separate linter)"
            elif [ "$_langs" = "swift" ] || [ "$_langs" = "sw" ]; then
                echo "Swift uses warnings-as-errors in build (no separate linter)"
            elif [ "$_langs" = "haskell" ] || [ "$_langs" = "hs" ]; then
                echo "Haskell uses -Wall -Werror in build (no separate linter)"
            elif [ "$_langs" = "erlang" ] || [ "$_langs" = "erl" ]; then
                echo "Erlang uses warnings-as-errors in build (no separate linter)"
            elif [ "$_langs" = "clojure" ] || [ "$_langs" = "clj" ]; then
                echo "Clojure uses *warn-on-reflection* in build (no separate linter)"
            elif [ "$_langs" = "scala" ] || [ "$_langs" = "sc" ]; then
                echo "Scala uses -Werror in build (no separate linter)"
            elif [ "$_langs" = "elixir" ] || [ "$_langs" = "ex" ]; then
                echo "Elixir uses warnings-as-errors in build (no separate linter)"
            elif [ "$_langs" = "elm" ] || [ "$_langs" = "el" ]; then
                echo "Elm compiler is warnings-as-errors (no separate linter)"
            elif [ "$_langs" = "perl" ] || [ "$_langs" = "pl" ]; then
                echo "Perl uses strict/warnings (no separate linter)"
            elif [ "$_langs" = "zig" ] || [ "$_langs" = "zg" ]; then
                echo "Zig uses warnings-as-errors in build (no separate linter)"
            else
                echo "Unknown language: $_langs"
                echo "Valid: c, clojure (clj), elixir (ex), elm (el), typescript (ts), python (py), go, ruby (rb), rust (rs), kotlin (kt), cpp (c++), perl (pl), php, java, csharp (cs), swift (sw), haskell (hs), erlang (erl), scala (sc), zig (zg)"
                exit 1
            fi
        ) 2>&1 | tee ".logs/lint/$name.log"
    fi

# Remove build artifacts (keeps installed dependencies)
[group('build')]
clean *lang:
    #!/usr/bin/env bash
    set -euo pipefail
    _jflag=""; _sflag=""; _langs=""; _prev=""
    for _a in {{lang}}; do
        if [ "$_prev" = "-j" ]; then _jflag="$_a"; _prev=""; continue; fi
        if [ "$_prev" = "-s" ]; then _sflag="$_a"; _prev=""; continue; fi
        if [ "$_a" = "-j" ]; then _prev="-j"; continue; fi
        if [ "$_a" = "-s" ]; then _prev="-s"; continue; fi
        _langs="${_langs:+$_langs }$_a"
    done
    if [ -z "$_langs" ]; then
        scripts/run-parallel.sh ${_jflag:+-j "$_jflag"} ${_sflag:+-s "$_sflag"} clean \
            "clean c" "clean clojure" "clean codegen" "clean cpp" "clean csharp" "clean elixir" "clean elm" "clean erlang" \
            "clean haskell" "clean java" "clean kotlin" "clean python" "clean rust" \
            "clean scala" "clean swift" "clean typescript" "clean zig"
    elif [ "$_langs" = "typescript" ] || [ "$_langs" = "ts" ]; then
        rm -rf src/typescript/dist
    elif [ "$_langs" = "python" ] || [ "$_langs" = "py" ]; then
        find src/python -type d -name __pycache__ -not -path '*/\.venv/*' -exec rm -rf {} + 2>/dev/null || true
        rm -rf src/python/.pytest_cache
    elif [ "$_langs" = "rust" ] || [ "$_langs" = "rs" ]; then
        rm -rf src/rust/target
    elif [ "$_langs" = "kotlin" ] || [ "$_langs" = "kt" ]; then
        rm -rf src/kotlin/build src/kotlin/.gradle
    elif [ "$_langs" = "c" ]; then
        rm -rf src/c/build
    elif [ "$_langs" = "cpp" ] || [ "$_langs" = "c++" ]; then
        rm -rf src/cpp/build
    elif [ "$_langs" = "java" ]; then
        rm -rf src/java/build src/java/.gradle
    elif [ "$_langs" = "csharp" ] || [ "$_langs" = "cs" ]; then
        rm -rf src/csharp/ParentTime/bin src/csharp/ParentTime/obj src/csharp/ParentTime.Tests/bin src/csharp/ParentTime.Tests/obj
    elif [ "$_langs" = "swift" ] || [ "$_langs" = "sw" ]; then
        rm -rf src/swift/.build
    elif [ "$_langs" = "haskell" ] || [ "$_langs" = "hs" ]; then
        rm -rf src/haskell/dist-newstyle
    elif [ "$_langs" = "erlang" ] || [ "$_langs" = "erl" ]; then
        rm -rf src/erlang/_build
    elif [ "$_langs" = "clojure" ] || [ "$_langs" = "clj" ]; then
        rm -rf src/clojure/.cpcache
    elif [ "$_langs" = "scala" ] || [ "$_langs" = "sc" ]; then
        rm -rf src/scala/build src/scala/.gradle
    elif [ "$_langs" = "zig" ] || [ "$_langs" = "zg" ]; then
        rm -rf src/zig/zig-out src/zig/.zig-cache
    elif [ "$_langs" = "elixir" ] || [ "$_langs" = "ex" ]; then
        rm -rf src/elixir/_build
    elif [ "$_langs" = "elm" ] || [ "$_langs" = "el" ]; then
        rm -rf src/elm/elm-stuff
    elif [ "$_langs" = "codegen" ]; then
        find codegen -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
    elif [ "$_langs" = "go" ] || [ "$_langs" = "ruby" ] || [ "$_langs" = "rb" ] || [ "$_langs" = "perl" ] || [ "$_langs" = "pl" ] || [ "$_langs" = "php" ]; then
        echo "No build artifacts for: $_langs"
    else
        echo "Unknown language: $_langs"
        echo "Valid: c, clojure (clj), elixir (ex), elm (el), typescript (ts), python (py), go, ruby (rb), rust (rs), kotlin (kt), cpp (c++), perl (pl), php, java, csharp (cs), swift (sw), haskell (hs), erlang (erl), scala (sc), zig (zg), codegen"
        exit 1
    fi

# Install language toolchains (all if no args, or specific languages)
[group('setup')]
install *langs:
    #!/usr/bin/env bash
    set -euo pipefail
    _name() { case "$1" in ts) echo typescript;; py) echo python;; rb) echo ruby;; rs) echo rust;; kt) echo kotlin;; c++) echo cpp;; cs) echo csharp;; sw) echo swift;; hs) echo haskell;; ex) echo elixir;; erl) echo erlang;; clj) echo clojure;; sc) echo scala;; zg) echo zig;; el) echo elm;; pl) echo perl;; *) echo "$1";; esac; }
    _all="c clojure cpp csharp elixir elm erlang go haskell java kotlin perl php python ruby rust scala swift typescript zig"
    _suggest() {
        local input; input="$(echo "$1" | tr '[:upper:]' '[:lower:]')"
        case "$input" in
            elixer|elixr|exlir|exilir)         echo elixir  ;;
            haskel|haskle|haslkell)             echo haskell ;;
            closure|clojur|clojre|cojure)       echo clojure ;;
            erland|erlng|earland|earlang)       echo erlang  ;;
            typscript|tyepscript|typesript|tsc) echo typescript ;;
            golang|goland)                      echo go      ;;
            scalar|scalla)                      echo scala   ;;
            kotlint|koltin|kotln)               echo kotlin  ;;
            pyton|pyhton|pythn)                 echo python  ;;
            phpp)                               echo php     ;;
            rubby)                              echo ruby    ;;
            swft|siwft)                         echo swift   ;;
            *)
                if [ ${#input} -ge 3 ]; then
                    for name in $_all; do
                        if [[ "$name" == "$input"* || "$name" == *"$input" ]]; then
                            echo "$name"; return
                        fi
                    done
                fi ;;
        esac
    }
    _check() {
        local lang="$1" name script suggest
        name=$(_name "$lang")
        script="scripts/installers/${name}.sh"
        if [ -f "$script" ]; then echo "$name"; return; fi
        suggest=$(_suggest "$lang")
        if [ -n "$suggest" ]; then
            if [ -t 0 ]; then
                read -rp "Unknown language '$lang'. Did you mean '$suggest'? [Y/n] " answer </dev/tty
                case "$(echo "$answer" | tr '[:upper:]' '[:lower:]')" in
                    ""|y|yes) echo "$suggest"; return ;;
                esac
            else
                echo "Unknown language '$lang'. Did you mean '$suggest'?" >&2
            fi
        else
            echo "Unknown language: $lang" >&2
        fi
        echo "Valid: c, clojure (clj), cpp (c++), csharp (cs), elixir (ex), elm (el), erlang (erl), go, haskell (hs), java, kotlin (kt), perl (pl), php, python (py), ruby (rb), rust (rs), scala (sc), swift (sw), typescript (ts), zig (zg)" >&2
        exit 1
    }
    langs="{{langs}}"
    install_all=false
    if [ -z "$langs" ]; then
        langs="$_all"
        install_all=true
    fi
    failed=""
    for lang in $langs; do
        name=$(_check "$lang")
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

# Interactive onboarding: show project info, installed languages, and install menu
[group('setup')]
get-started *args:
    @bash scripts/get-started.sh {{args}}

# Uninstall language toolchains
[group('setup')]
uninstall *langs:
    #!/usr/bin/env bash
    set -euo pipefail
    _name() { case "$1" in ts) echo typescript;; py) echo python;; rb) echo ruby;; rs) echo rust;; kt) echo kotlin;; c++) echo cpp;; cs) echo csharp;; sw) echo swift;; hs) echo haskell;; ex) echo elixir;; erl) echo erlang;; clj) echo clojure;; sc) echo scala;; zg) echo zig;; el) echo elm;; pl) echo perl;; *) echo "$1";; esac; }
    _all="c clojure cpp csharp elixir elm erlang go haskell java kotlin perl php python ruby rust scala swift typescript zig"
    _suggest() {
        local input; input="$(echo "$1" | tr '[:upper:]' '[:lower:]')"
        case "$input" in
            elixer|elixr|exlir|exilir)         echo elixir  ;;
            haskel|haskle|haslkell)             echo haskell ;;
            closure|clojur|clojre|cojure)       echo clojure ;;
            erland|erlng|earland|earlang)       echo erlang  ;;
            typscript|tyepscript|typesript|tsc) echo typescript ;;
            golang|goland)                      echo go      ;;
            scalar|scalla)                      echo scala   ;;
            kotlint|koltin|kotln)               echo kotlin  ;;
            pyton|pyhton|pythn)                 echo python  ;;
            phpp)                               echo php     ;;
            rubby)                              echo ruby    ;;
            swft|siwft)                         echo swift   ;;
            *)
                if [ ${#input} -ge 3 ]; then
                    for name in $_all; do
                        if [[ "$name" == "$input"* || "$name" == *"$input" ]]; then
                            echo "$name"; return
                        fi
                    done
                fi ;;
        esac
    }
    _check() {
        local lang="$1" name script suggest
        name=$(_name "$lang")
        script="scripts/installers/${name}.sh"
        if [ -f "$script" ]; then echo "$name"; return; fi
        suggest=$(_suggest "$lang")
        if [ -n "$suggest" ]; then
            if [ -t 0 ]; then
                read -rp "Unknown language '$lang'. Did you mean '$suggest'? [Y/n] " answer </dev/tty
                case "$(echo "$answer" | tr '[:upper:]' '[:lower:]')" in
                    ""|y|yes) echo "$suggest"; return ;;
                esac
            else
                echo "Unknown language '$lang'. Did you mean '$suggest'?" >&2
            fi
        else
            echo "Unknown language: $lang" >&2
        fi
        echo "Valid: c, clojure (clj), cpp (c++), csharp (cs), elixir (ex), elm (el), erlang (erl), go, haskell (hs), java, kotlin (kt), perl (pl), php, python (py), ruby (rb), rust (rs), scala (sc), swift (sw), typescript (ts), zig (zg)" >&2
        exit 1
    }
    langs="{{langs}}"
    if [ -z "$langs" ]; then
        echo "Usage: just uninstall <lang> [lang...]" >&2
        echo "Valid: c, clojure (clj), cpp (c++), csharp (cs), elixir (ex), elm (el), erlang (erl), go, haskell (hs), java, kotlin (kt), perl (pl), php, python (py), ruby (rb), rust (rs), scala (sc), swift (sw), typescript (ts), zig (zg)" >&2
        exit 1
    fi
    for lang in $langs; do
        name=$(_check "$lang")
        bash "scripts/installers/${name}.sh" uninstall
    done
