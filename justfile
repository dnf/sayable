# parent-time task runner
# Run `just --list` to see all available commands.

python := if `which python3 2>/dev/null || true` != "" { "python3" } else { "python" }

# Run all test suites + codegen check
[group('test')]
test *lang:
    #!/usr/bin/env bash
    set -euo pipefail
    if [ -z "{{lang}}" ]; then
        just test typescript
        just test python
        just test go
        just test ruby
        just test rust
        just test kotlin
        just test cpp
        just test php
        just test java
        just check
    elif [ "{{lang}}" = "typescript" ] || [ "{{lang}}" = "ts" ]; then
        cd typescript && npx vitest run
    elif [ "{{lang}}" = "python" ] || [ "{{lang}}" = "py" ]; then
        cd python && uv run pytest tests/
    elif [ "{{lang}}" = "go" ]; then
        cd go && go test ./...
    elif [ "{{lang}}" = "ruby" ] || [ "{{lang}}" = "rb" ]; then
        cd ruby && ruby -Ilib test/test_formatter.rb
    elif [ "{{lang}}" = "rust" ] || [ "{{lang}}" = "rs" ]; then
        cd rust && cargo test
    elif [ "{{lang}}" = "kotlin" ] || [ "{{lang}}" = "kt" ]; then
        cd kotlin && ./gradlew test
    elif [ "{{lang}}" = "cpp" ] || [ "{{lang}}" = "c++" ]; then
        just build cpp
        cd cpp/build && ctest --output-on-failure
    elif [ "{{lang}}" = "php" ]; then
        cd php && php vendor/bin/phpunit tests/
    elif [ "{{lang}}" = "java" ]; then
        cd java && ./gradlew test
    elif [ "{{lang}}" = "codegen" ]; then
        {{python}} -m unittest codegen.test_locale_groups -v
    else
        echo "Unknown language: {{lang}}"
        echo "Valid: typescript (ts), python (py), go, ruby (rb), rust (rs), kotlin (kt), cpp (c++), php, java, codegen"
        exit 1
    fi

# Build all languages that have a build step
[group('build')]
build *lang:
    #!/usr/bin/env bash
    set -euo pipefail
    if [ -z "{{lang}}" ]; then
        just build typescript
        just build rust
        just build kotlin
        just build cpp
        just build java
    elif [ "{{lang}}" = "typescript" ] || [ "{{lang}}" = "ts" ]; then
        cd typescript && npm run build
    elif [ "{{lang}}" = "rust" ] || [ "{{lang}}" = "rs" ]; then
        cd rust && cargo build
    elif [ "{{lang}}" = "kotlin" ] || [ "{{lang}}" = "kt" ]; then
        cd kotlin && ./gradlew build
    elif [ "{{lang}}" = "cpp" ] || [ "{{lang}}" = "c++" ]; then
        cd cpp && cmake -B build && cmake --build build
    elif [ "{{lang}}" = "java" ]; then
        cd java && ./gradlew build
    else
        echo "No build step for: {{lang}}"
    fi

# Regenerate all locale files from canonical JSON
[group('codegen')]
generate *args:
    {{python}} -m codegen.generate {{args}}

# Generate locale documentation (one markdown file per locale)
[group('codegen')]
docgen *args:
    uv run --project python {{python}} -m codegen.docgen {{args}}

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
    if [ -z "{{lang}}" ]; then
        just lint typescript
        just lint python
        just lint go
        just lint ruby
        just lint rust
        just lint php
        just lint java
    elif [ "{{lang}}" = "typescript" ] || [ "{{lang}}" = "ts" ]; then
        cd typescript && npm run lint
    elif [ "{{lang}}" = "python" ] || [ "{{lang}}" = "py" ]; then
        cd python && uv run ruff check . && uv run pyright
    elif [ "{{lang}}" = "go" ]; then
        cd go && golangci-lint run
    elif [ "{{lang}}" = "ruby" ] || [ "{{lang}}" = "rb" ]; then
        cd ruby && bundle exec rubocop
    elif [ "{{lang}}" = "rust" ] || [ "{{lang}}" = "rs" ]; then
        cd rust && cargo clippy
    elif [ "{{lang}}" = "php" ]; then
        cd php && composer analyse && composer cs-check
    elif [ "{{lang}}" = "kotlin" ] || [ "{{lang}}" = "kt" ]; then
        echo "Kotlin uses warnings-as-errors in build (no separate linter)"
    elif [ "{{lang}}" = "cpp" ] || [ "{{lang}}" = "c++" ]; then
        echo "C++ uses warnings-as-errors in build (no separate linter)"
    elif [ "{{lang}}" = "java" ]; then
        echo "Java uses warnings-as-errors in build (no separate linter)"
    else
        echo "Unknown language: {{lang}}"
        echo "Valid: typescript (ts), python (py), go, ruby (rb), rust (rs), kotlin (kt), cpp (c++), php, java"
        exit 1
    fi

# Remove build artifacts (keeps installed dependencies)
[group('build')]
clean *lang:
    #!/usr/bin/env bash
    set -euo pipefail
    if [ -z "{{lang}}" ]; then
        just clean typescript
        just clean python
        just clean rust
        just clean kotlin
        just clean cpp
        just clean java
        just clean codegen
    elif [ "{{lang}}" = "typescript" ] || [ "{{lang}}" = "ts" ]; then
        rm -rf typescript/dist
    elif [ "{{lang}}" = "python" ] || [ "{{lang}}" = "py" ]; then
        find python -type d -name __pycache__ -not -path '*/\.venv/*' -exec rm -rf {} + 2>/dev/null || true
        rm -rf python/.pytest_cache
    elif [ "{{lang}}" = "rust" ] || [ "{{lang}}" = "rs" ]; then
        rm -rf rust/target
    elif [ "{{lang}}" = "kotlin" ] || [ "{{lang}}" = "kt" ]; then
        rm -rf kotlin/build kotlin/.gradle
    elif [ "{{lang}}" = "cpp" ] || [ "{{lang}}" = "c++" ]; then
        rm -rf cpp/build
    elif [ "{{lang}}" = "java" ]; then
        rm -rf java/build java/.gradle
    elif [ "{{lang}}" = "codegen" ]; then
        find codegen -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
    elif [ "{{lang}}" = "go" ] || [ "{{lang}}" = "ruby" ] || [ "{{lang}}" = "rb" ] || [ "{{lang}}" = "php" ]; then
        echo "No build artifacts for: {{lang}}"
    else
        echo "Unknown language: {{lang}}"
        echo "Valid: typescript (ts), python (py), go, ruby (rb), rust (rs), kotlin (kt), cpp (c++), php, java, codegen"
        exit 1
    fi
