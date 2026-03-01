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
    else
        echo "Unknown language: {{lang}}"
        echo "Valid: typescript (ts), python (py), go, ruby (rb), rust (rs), kotlin (kt), cpp (c++), php"
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
    elif [ "{{lang}}" = "typescript" ] || [ "{{lang}}" = "ts" ]; then
        cd typescript && npm run build
    elif [ "{{lang}}" = "rust" ] || [ "{{lang}}" = "rs" ]; then
        cd rust && cargo build
    elif [ "{{lang}}" = "kotlin" ] || [ "{{lang}}" = "kt" ]; then
        cd kotlin && ./gradlew build
    elif [ "{{lang}}" = "cpp" ] || [ "{{lang}}" = "c++" ]; then
        cd cpp && cmake -B build && cmake --build build
    else
        echo "No build step for: {{lang}}"
    fi

# Regenerate all locale files from canonical JSON
[group('codegen')]
generate:
    {{python}} -m codegen.generate

# Check that generated locale files are up-to-date (CI mode)
[group('codegen')]
check:
    {{python}} -m codegen.generate --check

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
    else
        echo "Unknown language: {{lang}}"
        echo "Valid: typescript (ts), python (py), go, ruby (rb), rust (rs), kotlin (kt), cpp (c++), php"
        exit 1
    fi
