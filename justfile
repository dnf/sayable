# sayable task runner. Run `just --list` to see every recipe.
#
# Toolchains and per-language runs (test, lint, build, clean, install, doctor,
# add, ...) are delegated to hecatron (https://github.com/dnf/hecatron), which
# reads .hecatron/config.json and the hooks in .hecatron/languages/<lang>/.
# Install it with `brew install dnf/tap/hecatron` (or put a checkout's bin/ on
# PATH). The rest of this file is sayable's own: codegen, docs, the CLI
# harness, fuzzing and benchmarks.

python := if `which python3 2>/dev/null || true` != "" { "python3" } else { "python" }

# Run every language's tests (all four libraries) in parallel, or one target's; `just test cli [lang]` runs the CLI harness
[group('test')]
test *args:
    #!/usr/bin/env bash
    set -euo pipefail
    _args=({{args}})
    if [ "${_args[0]:-}" = "cli" ]; then
        just _test_clis ${_args[@]:1}
    else
        hecatron test ${_args[@]+"${_args[@]}"}
    fi

# Run every linter, or one language's (all four libraries); `just lint shell` runs shellcheck
[group('lint')]
lint *args:
    hecatron lint {{args}}

# Build every compiled language, or one language's four libraries
[group('build')]
build *args:
    hecatron build {{args}}

# Remove build artifacts (keeps installed dependencies)
[group('build')]
clean *args:
    hecatron clean {{args}}

# Clean, then build
[group('build')]
rebuild *args:
    hecatron rebuild {{args}}

# Clean, then test
[group('test')]
retest *args:
    hecatron retest {{args}}

# Install language toolchains (every one the project uses, or those named)
[group('setup')]
install *args:
    hecatron install {{args}}

# Uninstall language toolchains
[group('setup')]
uninstall *args:
    hecatron uninstall {{args}}

# Check every toolchain works; --fix runs installers to repair
[group('setup')]
doctor *args:
    hecatron doctor {{args}}

# Onboarding: status table and install menu
[group('setup')]
get-started *args:
    hecatron get-started {{args}}

# Skip languages in parallel runs, for you only
[group('setup')]
disable *args:
    hecatron disable {{args}}

# Re-enable disabled languages
[group('setup')]
enable *args:
    hecatron enable {{args}}

# Add languages to the project
[group('manage')]
add *args:
    hecatron add {{args}}

# Remove languages from the project
[group('manage')]
remove *args:
    hecatron remove {{args}}

# List the project's languages (--all: every language hecatron knows)
[group('manage')]
list *args:
    hecatron list {{args}}

# Regenerate age/Dockerfile from each language's snippet
[group('codegen')]
dockerfile:
    hecatron dockerfile

# Update project metadata across all manifests
[group('codegen')]
metadata:
    hecatron metadata

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
    hecatron check
    {{python}} tools/generate_compatibility.py --check
    {{python}} tools/check_test_ids.py
    uv run --with geopandas --with matplotlib {{python}} tools/geography/generate.py --check

# Show or set the library version across all implementations
[group('codegen')]
version *ver:
    #!/usr/bin/env bash
    set -euo pipefail
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

    # 2. Update every language's implementation (each one's version.sh hook)
    hecatron version "${ver}"

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

# Run the CLI harness (all CLIs, or one): `just cli go` is `just test cli go`
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

# Internal: run the CLI harness for every CLI in parallel, or the ones named
[private]
_test_clis *langs:
    #!/usr/bin/env bash
    set -euo pipefail
    eval "$(hecatron env)"
    _langs=({{langs}})
    if [ "${#_langs[@]}" -gt 0 ]; then
        for _cl in "${_langs[@]}"; do just _test_cli "$(_name "${_cl}")"; done
        exit 0
    fi
    _jobs=()
    for _cli_dir in cli/impl/*/; do
        _cl=$(basename "${_cli_dir}")
        if [ ! -x "${_cli_dir}sayable" ] || ! _dep_available "${_cl}"; then
            _jobs+=("skip:${_cl}")
        else
            _jobs+=("_test_cli ${_cl}")
        fi
    done
    hecatron parallel cli "${_jobs[@]}"

# Internal: run the CLI harness for one CLI
[private]
_test_cli lang:
    #!/usr/bin/env bash
    set -euo pipefail
    eval "$(hecatron env)"
    # The language's own toolchain directories (e.g. Ada's GNAT under Alire)
    _use_lang_path "{{lang}}"
    _cli_bin="cli/impl/{{lang}}/sayable"
    if [ ! -x "${_cli_bin}" ]; then
        echo "error: ${_cli_bin} is not executable or not found" >&2
        exit 1
    fi
    bash cli/test-harness.sh "${_cli_bin}"

# Run benchmarks across all or individual language implementations
[group('benchmark')]
benchmark type="cpu" *target:
    #!/usr/bin/env bash
    set -euo pipefail
    eval "$(hecatron env)"
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
            hecatron parallel -j "${_jflag}" -n "${_nflag}" ${_sflag:+-s "${_sflag}"} benchmark "${args[@]}"
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
        hecatron parallel -j "${_jflag}" -n "${_nflag}" ${_sflag:+-s "${_sflag}"} benchmark "${args[@]}"
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
