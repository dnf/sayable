# parent-time task runner
# Run `just --list` to see all available commands.

python := if `which python3 2>/dev/null || true` != "" { "python3" } else { "python" }

# Run all test suites + codegen check
[group('test')]
test *lang:
    #!/usr/bin/env bash
    set -euo pipefail
    _name() { case "$1" in ts) echo typescript;; py) echo python;; rb) echo ruby;; rs) echo rust;; kt) echo kotlin;; c++) echo cpp;; cs) echo csharp;; sw) echo swift;; *) echo "$1";; esac; }
    if [ -z "{{lang}}" ]; then
        scripts/run-parallel.sh test \
            "check" "test cpp" "test csharp" "test go" "test java" \
            "test kotlin" "test php" "test python" "test ruby" \
            "test rust" "test swift" "test typescript"
    else
        name=$(_name "{{lang}}")
        mkdir -p .logs/test
        (
            if [ "{{lang}}" = "typescript" ] || [ "{{lang}}" = "ts" ]; then
                cd src/typescript && npx vitest run
            elif [ "{{lang}}" = "python" ] || [ "{{lang}}" = "py" ]; then
                cd src/python && uv run --extra dev pytest tests/
            elif [ "{{lang}}" = "go" ]; then
                cd src/go && go test ./...
            elif [ "{{lang}}" = "ruby" ] || [ "{{lang}}" = "rb" ]; then
                cd src/ruby && ruby -Ilib test/test_formatter.rb
            elif [ "{{lang}}" = "rust" ] || [ "{{lang}}" = "rs" ]; then
                cd src/rust && cargo test
            elif [ "{{lang}}" = "kotlin" ] || [ "{{lang}}" = "kt" ]; then
                cd src/kotlin && ./gradlew test
            elif [ "{{lang}}" = "cpp" ] || [ "{{lang}}" = "c++" ]; then
                just build cpp
                cd src/cpp/build && ctest --output-on-failure
            elif [ "{{lang}}" = "php" ]; then
                cd src/php && php vendor/bin/phpunit tests/
            elif [ "{{lang}}" = "java" ]; then
                cd src/java && ./gradlew test
            elif [ "{{lang}}" = "csharp" ] || [ "{{lang}}" = "cs" ]; then
                cd src/csharp && dotnet test
            elif [ "{{lang}}" = "swift" ] || [ "{{lang}}" = "sw" ]; then
                cd src/swift && swift test
            elif [ "{{lang}}" = "codegen" ]; then
                {{python}} -m unittest codegen.test_locale_groups -v
            else
                echo "Unknown language: {{lang}}"
                echo "Valid: typescript (ts), python (py), go, ruby (rb), rust (rs), kotlin (kt), cpp (c++), php, java, csharp (cs), swift (sw), codegen"
                exit 1
            fi
        ) 2>&1 | tee ".logs/test/$name.log"
    fi

# Build all languages that have a build step
[group('build')]
build *lang:
    #!/usr/bin/env bash
    set -euo pipefail
    _name() { case "$1" in ts) echo typescript;; py) echo python;; rb) echo ruby;; rs) echo rust;; kt) echo kotlin;; c++) echo cpp;; cs) echo csharp;; sw) echo swift;; *) echo "$1";; esac; }
    if [ -z "{{lang}}" ]; then
        scripts/run-parallel.sh build \
            "build cpp" "build csharp" "build java" "build kotlin" \
            "build rust" "build swift" "build typescript"
    else
        name=$(_name "{{lang}}")
        mkdir -p .logs/build
        (
            if [ "{{lang}}" = "typescript" ] || [ "{{lang}}" = "ts" ]; then
                cd src/typescript && npm run build
            elif [ "{{lang}}" = "rust" ] || [ "{{lang}}" = "rs" ]; then
                cd src/rust && cargo build
            elif [ "{{lang}}" = "kotlin" ] || [ "{{lang}}" = "kt" ]; then
                cd src/kotlin && ./gradlew build
            elif [ "{{lang}}" = "cpp" ] || [ "{{lang}}" = "c++" ]; then
                cd src/cpp && cmake -B build && cmake --build build
            elif [ "{{lang}}" = "java" ]; then
                cd src/java && ./gradlew build
            elif [ "{{lang}}" = "csharp" ] || [ "{{lang}}" = "cs" ]; then
                cd src/csharp && dotnet build
            elif [ "{{lang}}" = "swift" ] || [ "{{lang}}" = "sw" ]; then
                cd src/swift && swift build
            else
                echo "No build step for: {{lang}}"
            fi
        ) 2>&1 | tee ".logs/build/$name.log"
    fi

# Regenerate all locale files from canonical JSON
[group('codegen')]
generate *args:
    {{python}} -m codegen.generate {{args}}

# Generate locale documentation (one markdown file per locale)
[group('codegen')]
docgen *args:
    uv run --project src/python {{python}} -m codegen.docgen {{args}}

# Check that generated locale files are up-to-date (CI mode)
[group('codegen')]
check:
    {{python}} -m codegen.generate --check

# List available locale groups for --locales flag
[group('codegen')]
list-groups:
    {{python}} -m codegen.generate --list-groups

# Run all available linters
[group('lint')]
lint *lang:
    #!/usr/bin/env bash
    set -euo pipefail
    _name() { case "$1" in ts) echo typescript;; py) echo python;; rb) echo ruby;; rs) echo rust;; kt) echo kotlin;; c++) echo cpp;; cs) echo csharp;; sw) echo swift;; *) echo "$1";; esac; }
    if [ -z "{{lang}}" ]; then
        scripts/run-parallel.sh lint \
            "lint csharp" "lint go" "lint java" "lint php" "lint python" \
            "lint ruby" "lint rust" "lint swift" "lint typescript"
    else
        name=$(_name "{{lang}}")
        mkdir -p .logs/lint
        (
            if [ "{{lang}}" = "typescript" ] || [ "{{lang}}" = "ts" ]; then
                cd src/typescript && npm run lint
            elif [ "{{lang}}" = "python" ] || [ "{{lang}}" = "py" ]; then
                cd src/python && uv run --extra dev ruff check . && uv run --extra dev pyright
            elif [ "{{lang}}" = "go" ]; then
                cd src/go && golangci-lint run
            elif [ "{{lang}}" = "ruby" ] || [ "{{lang}}" = "rb" ]; then
                cd src/ruby && bundle exec rubocop
            elif [ "{{lang}}" = "rust" ] || [ "{{lang}}" = "rs" ]; then
                cd src/rust && cargo clippy
            elif [ "{{lang}}" = "php" ]; then
                cd src/php && composer analyse && composer cs-check
            elif [ "{{lang}}" = "kotlin" ] || [ "{{lang}}" = "kt" ]; then
                echo "Kotlin uses warnings-as-errors in build (no separate linter)"
            elif [ "{{lang}}" = "cpp" ] || [ "{{lang}}" = "c++" ]; then
                echo "C++ uses warnings-as-errors in build (no separate linter)"
            elif [ "{{lang}}" = "java" ]; then
                echo "Java uses warnings-as-errors in build (no separate linter)"
            elif [ "{{lang}}" = "csharp" ] || [ "{{lang}}" = "cs" ]; then
                echo "C# uses TreatWarningsAsErrors in build (no separate linter)"
            elif [ "{{lang}}" = "swift" ] || [ "{{lang}}" = "sw" ]; then
                echo "Swift uses warnings-as-errors in build (no separate linter)"
            else
                echo "Unknown language: {{lang}}"
                echo "Valid: typescript (ts), python (py), go, ruby (rb), rust (rs), kotlin (kt), cpp (c++), php, java, csharp (cs), swift (sw)"
                exit 1
            fi
        ) 2>&1 | tee ".logs/lint/$name.log"
    fi

# Remove build artifacts (keeps installed dependencies)
[group('build')]
clean *lang:
    #!/usr/bin/env bash
    set -euo pipefail
    if [ -z "{{lang}}" ]; then
        scripts/run-parallel.sh clean \
            "clean codegen" "clean cpp" "clean csharp" "clean java" \
            "clean kotlin" "clean python" "clean rust" "clean swift" \
            "clean typescript"
    elif [ "{{lang}}" = "typescript" ] || [ "{{lang}}" = "ts" ]; then
        rm -rf src/typescript/dist
    elif [ "{{lang}}" = "python" ] || [ "{{lang}}" = "py" ]; then
        find src/python -type d -name __pycache__ -not -path '*/\.venv/*' -exec rm -rf {} + 2>/dev/null || true
        rm -rf src/python/.pytest_cache
    elif [ "{{lang}}" = "rust" ] || [ "{{lang}}" = "rs" ]; then
        rm -rf src/rust/target
    elif [ "{{lang}}" = "kotlin" ] || [ "{{lang}}" = "kt" ]; then
        rm -rf src/kotlin/build src/kotlin/.gradle
    elif [ "{{lang}}" = "cpp" ] || [ "{{lang}}" = "c++" ]; then
        rm -rf src/cpp/build
    elif [ "{{lang}}" = "java" ]; then
        rm -rf src/java/build src/java/.gradle
    elif [ "{{lang}}" = "csharp" ] || [ "{{lang}}" = "cs" ]; then
        rm -rf src/csharp/ParentTime/bin src/csharp/ParentTime/obj src/csharp/ParentTime.Tests/bin src/csharp/ParentTime.Tests/obj
    elif [ "{{lang}}" = "swift" ] || [ "{{lang}}" = "sw" ]; then
        rm -rf src/swift/.build
    elif [ "{{lang}}" = "codegen" ]; then
        find codegen -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
    elif [ "{{lang}}" = "go" ] || [ "{{lang}}" = "ruby" ] || [ "{{lang}}" = "rb" ] || [ "{{lang}}" = "php" ]; then
        echo "No build artifacts for: {{lang}}"
    else
        echo "Unknown language: {{lang}}"
        echo "Valid: typescript (ts), python (py), go, ruby (rb), rust (rs), kotlin (kt), cpp (c++), php, java, csharp (cs), swift (sw), codegen"
        exit 1
    fi
