# Sayable CLI Specification

A unified command-line interface to all four Sayable components (age, date, duration, time). Each language that implements all four libraries provides a `sayable` CLI binary that exercises every public function.

## Purpose

The CLI serves as a **cross-language test harness**. A single bash script (`test-harness.sh`) drives any conforming CLI binary through every canonical test case through one [REPL](#repl-mode) process, verifying that all implementations produce identical output, and `fuzz.py` compares every CLI's answers to random requests. See [`docs/testing.md`](../docs/testing.md).

## Binary Name

Each language produces a binary (or wrapper script) that can be invoked as:

```
sayable <command> [arguments] [options]
```

The actual binary name is language-specific (e.g., `sayable-go`, `sayable-py`, `./sayable`), but the argument interface is identical across all implementations.

## Commands

### `age <dob>`

Format an age from a date of birth.

| Argument | Description |
|----------|-------------|
| `<dob>` | Date of birth (YYYY-MM-DD). Use the literal string `null` to pass a null value. |

Calls `format_age(dob, asOf)` and prints the result.

### `stage <dob>`

Get the developmental stage for a date of birth.

| Argument | Description |
|----------|-------------|
| `<dob>` | Date of birth (YYYY-MM-DD). Use `null` for null input. |

Calls `format_stage(dob, asOf, gender)` and prints the result.

### `date <date>`

Format a calendar date.

| Argument | Description |
|----------|-------------|
| `<date>` | Date (YYYY-MM-DD or ISO 8601 datetime). Use `null` for null input. |

Calls `format_date(date)` and prints the result.

With `--with-year`, calls `format_date_with_year(date)` instead.

### `relative <date>`

Format a date relative to a reference point.

| Argument | Description |
|----------|-------------|
| `<date>` | Target date (YYYY-MM-DD). Use `null` for null input. |

Requires `-d <asOf>`. Calls `format_relative(date, asOf)` and prints the result.

### `time <time>`

Format a clock time as human-readable text.

| Argument | Description |
|----------|-------------|
| `<time>` | Time (HH:MM or ISO 8601 datetime). Use `null` for null input. |

Calls `format_time(time)` and prints the result.

### `duration <value> [end]`

Format a duration.

| Arguments | Mode | Function called |
|-----------|------|-----------------|
| `<seconds>` (integer) | Seconds mode | `format_duration(seconds)` |
| `<start> <end>` (ISO timestamps) | Timestamp mode | `format_duration(start, end)` |

Use `null` for null input (seconds mode only).

### `since <start>`

Format elapsed time as "X ago".

| Argument | Description |
|----------|-------------|
| `<start>` | Start timestamp (ISO 8601). Use `null` for null input. |

Requires `-d <asOf>`. Calls `format_since(start, asOf)` and prints the result.

### `until <target>`

Format remaining time as "in X".

| Argument | Description |
|----------|-------------|
| `<target>` | Target timestamp (ISO 8601). Use `null` for null input. |

Requires `-d <asOf>`. Calls `format_until(target, asOf)` and prints the result.

### `locales`

List all supported locale codes, one per line, sorted alphabetically.

### `version`

Print version string: `sayable 0.5.0`

### `help`

Print usage information.

## Options

| Option | Short | Description | Applies to |
|--------|-------|-------------|------------|
| `--locale <code>` | `-l` | Locale code (default: `en`) | All formatting commands |
| `--as-of <value>` | `-d` | Reference date or timestamp | `age`, `stage`, `relative`, `since`, `until` |
| `--short` | | Use short compactness | All formatting commands |
| `--compact` | | Use compact compactness | All formatting commands |
| `--gender <m\|f>` | `-g` | Gender for stage labels | `stage` only |
| `--with-year` | | Include year in date output | `date` only |
| `--help` | `-h` | Show help | Global |
| `--version` | `-v` | Show version | Global |

Options can appear in any order after the positional arguments.

## Null Handling

The literal string `null` (case-sensitive, lowercase) as a positional argument is interpreted as a null/nil/None value, not the string "null". This enables testing null-input edge cases from the command line.

An empty string `""` is passed as-is (an empty string, distinct from null).

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success — result printed to stdout (with trailing newline) |
| 1 | Null result — the formatting function returned null/nil/None (nothing printed to stdout) |
| 2 | Usage error — invalid arguments, unknown command, missing required option (error message printed to stderr) |

## Output Format

- Successful output is printed to **stdout** followed by a single newline (`\n`).
- Error messages are printed to **stderr**.
- No decorative output (no labels, no colors, no prefixes). Just the raw formatted string.
- The `locales` command prints one code per line.

## REPL Mode

`sayable --repl` (as the only argument) answers many requests from one process, so the test harness and the fuzz tester do not pay process startup once per call.

- **Request:** one per line on stdin — the same arguments a one-shot invocation takes, separated by tab characters (`\t`) instead of shell quoting. An empty field is an empty-string argument, so `age<TAB>` is `sayable age ''`. Arguments never contain tabs or newlines.
- **Response:** exactly one line on stdout per request, `<exit><TAB><output>`, where `<exit>` is the exit code the one-shot invocation would return (0, 1 or 2) and `<output>` is what it would print to stdout with the trailing newline removed and any inner newlines (e.g. `locales`) replaced by tabs. A null result is `1<TAB>` with nothing after the tab.
- **Flush stdout after every response line**, so a driver can interleave writes and reads.
- Errors still go to stderr. A usage error answers `2<TAB>` and the REPL keeps reading; so does a blank line (no command).
- An unexpected failure while handling a request (exception, panic) must not end the REPL: answer `1<TAB>`, as a crashed one-shot run would exit 1, and report the error on stderr.
- Commands without `-d` still default to today's date, evaluated per request.
- End of input ends the REPL with exit code 0.

```
$ printf 'age\t2020-06-15\t-d\t2025-06-15\nage\tnull\t-d\t2025-06-15\nbogus\n' | sayable --repl 2>/dev/null
0	5 years
1	
2	
```

## Argument Parsing Rules

1. The first non-option argument is always the **command**.
2. The second non-option argument is the **primary value** (dob, date, time, seconds/start).
3. For `duration` with timestamps, the third non-option argument is **end**.
4. Options (`-l`, `-d`, `--short`, etc.) can appear anywhere after the command.
5. `--` stops option parsing (remaining args are positional).
6. Unknown options produce a usage error (exit 2).

## Duration Argument Detection

The `duration` command determines its mode from the first value argument:

- If the value is `null` → pass null to `format_duration`
- If the value is a non-negative integer (all digits) → seconds mode: `format_duration(int(value))`
- If the value contains `-` or `T` → timestamp mode: requires a second positional argument (`end`), calls `format_duration(start, end)`
- Negative integers (e.g., `-1`) → pass as negative to `format_duration` (which returns null). Because a leading `-` starts an option, a negative value must follow `--`: `sayable duration -- -1`; `sayable duration -1` is an unknown-option usage error (exit 2).
- Digits are ASCII `0`–`9` only; other Unicode digits make the value a (malformed) timestamp.

## Reference Implementation Behavior

When `-d` / `--as-of` is not provided:

- `age` and `stage`: use today's date (YYYY-MM-DD); so does `-d null` or `-d ''` (an absent reference date)
- `relative`, `since`, `until`: the `-d` option is **required** — omitting it is a usage error (exit 2)

## Example Usage

```bash
# Age formatting
sayable age 2020-06-15 -d 2025-06-15
# Output: 5 years

# Stage with gender
sayable stage 2024-01-10 -d 2025-06-15 -l es -g f
# Output: Bebé

# Date formatting
sayable date 2025-03-15
# Output: March 15th

# Relative date
sayable relative 2025-03-16 -d 2025-03-15
# Output: tomorrow

# Time formatting
sayable time 14:15
# Output: a quarter past two

# Duration in seconds
sayable duration 5400
# Output: 1½ hours

# Duration between timestamps
sayable duration 2025-01-15T10:00:00 2025-01-15T11:30:00
# Output: 1½ hours

# Elapsed time
sayable since 2025-01-15T10:00:00 -d 2025-01-15T10:45:00
# Output: 45 minutes ago

# Remaining time
sayable until 2025-01-15T13:00:00 -d 2025-01-15T10:00:00
# Output: in 3 hours

# Compact mode with locale
sayable age 2020-06-15 -d 2025-06-15 --compact -l fr
# Output: 5a

# Null input
sayable age null -d 2025-06-15
# (no output, exit code 1)

# List locales
sayable locales
# af
# ak
# am
# ...
```

## Implementation Notes

- Each CLI implementation lives in `cli/impl/<lang>/`.
- The CLI links all four component libraries from the same language.
- Every CLI implements all four libraries; the test harness and the fuzzer run every request against every CLI, so a missing command shows up as failures, not skipped tests.
- A language with no clock of its own (Wren: wren_cli has none) still defaults `age` and `stage` to today: its wrapper supplies the date.

## Canonical Test Coverage

The test harness exercises all tests from:

| Component | Test file | Test count |
|-----------|-----------|------------|
| age | `age/config/tests.json` | 217 (minus untestable: ~195 CLI tests) |
| date | `date/config/tests.json` | 52 |
| time | `time/config/tests.json` | 27 |
| duration | `duration/config/tests.json` | 55 |

Tests excluded from the CLI harness:
- `systemDate` tests (sections 15, 23) — require mocking the system clock
- `getLocale` tests (section 30) — API-only, not a CLI function
- `undefined` input tests (1.2) — language-specific concept
- `weeks_pattern` tests — matched by regex pattern instead of exact string
