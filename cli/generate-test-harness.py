#!/usr/bin/env python3
"""Generate the CLI test harness from canonical test JSON files.

Reads {age,date,duration,time}/config/tests.json and produces
cli/test-harness.sh — a self-contained bash script that exercises
any conforming sayable CLI binary.

Usage:
    python3 cli/generate-test-harness.py
"""

import json
import os
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent


def load_tests(component: str) -> dict:
    path = ROOT / component / "config" / "tests.json"
    with open(path) as f:
        return json.load(f)


def shell_escape(s: str) -> str:
    """Escape a string for safe inclusion in single-quoted bash strings."""
    if s is None:
        return "null"
    return s.replace("'", "'\\''")


# Locale codes that are also shell keywords (Finnish "fi") are quoted so
# shellcheck doesn't read them as syntax.
SHELL_KEYWORDS = {"if", "then", "else", "elif", "fi", "case", "esac", "for", "while",
                  "until", "do", "done", "in", "function", "select"}


def quote_arg(a: str) -> str:
    """Quote a CLI argument for the generated bash script."""
    if a == "":
        return "''"
    if " " in a or "'" in a or a in SHELL_KEYWORDS:
        return f"'{shell_escape(a)}'"
    return a


def emit_age_tests(sections: list, out: list):
    """Emit age component test cases."""
    skip_sections = {15, 23, 30}  # systemDate, stage default asOf, getLocale

    for section in sections:
        sid = section["id"]
        if sid in skip_sections:
            out.append(f"# Skipped: section {sid} — {section['title']}")
            continue

        section_locale = section.get("locale", "")
        section_compactness = section.get("compactness", "")

        out.append(f"")
        out.append(f"# === Age {sid}: {section['title']} ===")

        for test in section["tests"]:
            tid = test["id"]
            method = test.get("method", "formatAge")
            inp = test["input"]
            expected = test["expected"]
            locale = test.get("locale", section_locale) or ""
            compactness = test.get("compactness", section_compactness) or ""
            gender = test.get("gender", inp.get("gender", ""))

            # Skip untestable
            if method == "getLocale":
                continue
            if tid == "1.2":  # undefined — language-specific
                out.append(f"# Skipped: {tid} — 'undefined' is language-specific")
                continue
            if inp.get("systemDate"):
                continue

            dob = inp.get("dateOfBirth")
            as_of = inp.get("asOf", "")

            # Build CLI command
            cmd = "stage" if method == "formatStage" else "age"
            args = [cmd]

            # Positional: dob
            if dob is None:
                args.append("null")
            else:
                args.append(shell_escape(dob))

            # Options
            if as_of:
                args.extend(["-d", shell_escape(as_of)])
            if locale:
                args.extend(["-l", locale])
            if compactness == "short":
                args.append("--short")
            elif compactness == "compact":
                args.append("--compact")
            if gender:
                args.extend(["-g", gender])

            cli_args = " ".join(quote_arg(a) for a in args)

            if expected is None:
                out.append(f"run_null 'age:{tid}' {cli_args}")
            elif expected == "weeks_pattern":
                out.append(f"run_regex 'age:{tid}' '^[0-9]+ weeks?(, [0-9]+ days?)?$' {cli_args}")
            else:
                out.append(f"run_test 'age:{tid}' '{shell_escape(str(expected))}' {cli_args}")


def emit_date_tests(sections: list, out: list):
    """Emit date component test cases."""
    for section in sections:
        name = section.get("name", section.get("title", ""))
        section_locale = section.get("locale", "")
        section_compactness = section.get("compactness", "")

        out.append(f"")
        out.append(f"# === Date: {name} ===")

        for test in section["tests"]:
            tid = test["id"]
            func = test["function"]
            inp = test["input"]
            expected = test["expected"]
            locale = test.get("locale", section_locale) or ""
            compactness = test.get("compactness", section_compactness) or ""

            # Map function to CLI command
            with_year = func == "format_date_with_year"
            if func in ("format_date", "format_date_with_year"):
                cmd = "date"
            elif func == "format_relative":
                cmd = "relative"
            else:
                out.append(f"# Skipped: {tid} — unknown function {func}")
                continue

            args = [cmd]

            # Positional: date
            date_val = inp.get("date")
            if date_val is None:
                args.append("null")
            else:
                args.append(shell_escape(date_val))

            # Options
            as_of = inp.get("asOf")
            if as_of is None and cmd == "relative":
                args.extend(["-d", "null"])
            elif as_of:
                args.extend(["-d", shell_escape(as_of)])

            if locale:
                args.extend(["-l", locale])
            if compactness == "short":
                args.append("--short")
            elif compactness == "compact":
                args.append("--compact")
            if with_year:
                args.append("--with-year")

            cli_args = " ".join(quote_arg(a) for a in args)

            if expected is None:
                out.append(f"run_null 'date:{tid}' {cli_args}")
            else:
                out.append(f"run_test 'date:{tid}' '{shell_escape(str(expected))}' {cli_args}")


def emit_time_tests(sections: list, out: list):
    """Emit time component test cases."""
    for section in sections:
        title = section.get("title", "")
        section_locale = section.get("locale", "")
        section_compactness = section.get("compactness", "")

        out.append(f"")
        out.append(f"# === Time {section['id']}: {title} ===")

        for test in section["tests"]:
            tid = test["id"]
            inp = test["input"]
            expected = test["expected"]
            locale = test.get("locale", section_locale) or ""
            compactness = test.get("compactness", section_compactness) or ""

            args = ["time"]

            time_val = inp.get("time")
            if time_val is None:
                args.append("null")
            else:
                args.append(shell_escape(time_val))

            if locale:
                args.extend(["-l", locale])
            if compactness == "short":
                args.append("--short")
            elif compactness == "compact":
                args.append("--compact")

            cli_args = " ".join(quote_arg(a) for a in args)

            if expected is None:
                out.append(f"run_null 'time:{tid}' {cli_args}")
            else:
                out.append(f"run_test 'time:{tid}' '{shell_escape(str(expected))}' {cli_args}")


def emit_duration_tests(sections: list, out: list):
    """Emit duration component test cases."""
    for section in sections:
        title = section.get("title", "")
        section_locale = section.get("locale", "")
        section_compactness = section.get("compactness", "")

        out.append(f"")
        out.append(f"# === Duration {section['id']}: {title} ===")

        for test in section["tests"]:
            tid = test["id"]
            func = test["function"]
            inp = test["input"]
            expected = test["expected"]
            locale = test.get("locale", section_locale) or ""
            compactness = test.get("compactness", section_compactness) or ""

            args = []

            if func == "format_duration":
                args.append("duration")
                if "seconds" in inp:
                    secs = inp["seconds"]
                    if secs is None:
                        args.append("null")
                    elif isinstance(secs, (int, float)) and secs < 0:
                        args.append("--")
                        args.append(str(secs))
                    else:
                        args.append(str(secs))
                elif "start" in inp:
                    args.append(shell_escape(inp["start"]))
                    args.append(shell_escape(inp["end"]))
            elif func == "format_since":
                args.append("since")
                start = inp.get("start")
                if start is None:
                    args.append("null")
                else:
                    args.append(shell_escape(start))
                as_of = inp.get("asOf")
                if as_of is None:
                    args.extend(["-d", "null"])
                else:
                    args.extend(["-d", shell_escape(as_of)])
            elif func == "format_until":
                args.append("until")
                target = inp.get("target")
                if target is None:
                    args.append("null")
                else:
                    args.append(shell_escape(target))
                as_of = inp.get("asOf")
                if as_of is None:
                    args.extend(["-d", "null"])
                else:
                    args.extend(["-d", shell_escape(as_of)])
            else:
                out.append(f"# Skipped: {tid} — unknown function {func}")
                continue

            if locale:
                args.extend(["-l", locale])
            if compactness == "short":
                args.append("--short")
            elif compactness == "compact":
                args.append("--compact")

            cli_args = " ".join(quote_arg(a) for a in args)

            if expected is None:
                out.append(f"run_null 'dur:{tid}' {cli_args}")
            else:
                out.append(f"run_test 'dur:{tid}' '{shell_escape(str(expected))}' {cli_args}")


HARNESS_RUNTIME = r"""
# Requests are queued, answered by a single `--repl` process, then checked.
# Request: the CLI arguments joined by tabs. Response: "<exit>\t<output>".
_tab=$'\t'
_ids=()
_kinds=()
_expects=()
_requests=""

_queue() {
    local id="$1" kind="$2" expected="$3"
    shift 3
    local IFS="${_tab}"
    _ids+=("${id}")
    _kinds+=("${kind}")
    _expects+=("${expected}")
    _requests+="$*"$'\n'
}

run_test() { local id="$1" expected="$2"; shift 2; _queue "${id}" test "${expected}" "$@"; }
run_null() { local id="$1"; shift; _queue "${id}" null "" "$@"; }
run_regex() { local id="$1" pattern="$2"; shift 2; _queue "${id}" regex "${pattern}" "$@"; }

"""

HARNESS_CHECK = r"""
# ══════════════════════════════════════════════════════════════
# RUN AND CHECK
# ══════════════════════════════════════════════════════════════
_responses=()
while IFS= read -r _line; do
    _responses+=("${_line}")
done < <(printf '%s' "${_requests}" | "${CLI}" --repl 2>/dev/null || true)

if [[ ${#_responses[@]} -ne ${#_ids[@]} ]]; then
    printf "${_red}FAIL${_reset} REPL answered %d of %d requests\n" "${#_responses[@]}" "${#_ids[@]}"
    exit 1
fi

# Every CLI implements all four libraries (cli/SPEC.md), so nothing is
# skipped: a missing library shows up as failing tests.
echo "Testing: ${CLI}"

for _i in "${!_ids[@]}"; do
    _id="${_ids[_i]}"
    _kind="${_kinds[_i]}"
    _expected="${_expects[_i]}"
    _total=$((_total + 1))
    _response="${_responses[_i]}"
    _rc="${_response%%${_tab}*}"
    _output="${_response#*${_tab}}"
    case "${_kind}" in
        test) [[ "${_rc}" == 0 && "${_output}" == "${_expected}" ]] ;;
        null) [[ "${_rc}" == 1 && -z "${_output}" ]] ;;
        regex) [[ "${_rc}" == 0 && "${_output}" =~ ${_expected} ]] ;;
    esac && _ok=true || _ok=false
    if ${_ok}; then
        _pass=$((_pass + 1))
    else
        _fail=$((_fail + 1))
        case "${_kind}" in
            test) printf "${_red}FAIL${_reset} %s: expected %q, got %q (exit %s)\n" "${_id}" "${_expected}" "${_output}" "${_rc}" ;;
            null) printf "${_red}FAIL${_reset} %s: expected null (exit 1), got exit %s, output: %q\n" "${_id}" "${_rc}" "${_output}" ;;
            regex) printf "${_red}FAIL${_reset} %s: expected match %q, got %q (exit %s)\n" "${_id}" "${_expected}" "${_output}" "${_rc}" ;;
        esac
    fi
done

# ══════════════════════════════════════════════════════════════
# SUMMARY
# ══════════════════════════════════════════════════════════════
echo
if [[ ${_fail} -eq 0 ]]; then
    printf "${_green}All %d tests passed.${_reset}\n" "${_total}"
else
    printf "${_red}%d failed${_reset}, ${_green}%d passed${_reset} out of %d tests.\n" "${_fail}" "${_pass}" "${_total}"
fi

[[ ${_fail} -eq 0 ]]
"""


def generate():
    out = []

    # Header
    out.append("#!/usr/bin/env bash")
    out.append("# ==========================================================================")
    out.append("# Sayable CLI Test Harness")
    out.append("# Generated from canonical test JSON files — do not edit by hand.")
    out.append("# Regenerate: python3 cli/generate-test-harness.py")
    out.append("#")
    out.append("# Runs every test through one `<cli> --repl` process (see cli/SPEC.md).")
    out.append("# ==========================================================================")
    out.append("set -euo pipefail")
    out.append("")
    out.append('CLI="${1:?Usage: $0 <path-to-cli-binary>}"')
    out.append("")
    out.append("# Verify the CLI exists and is executable")
    out.append('if [[ ! -x "${CLI}" ]] && ! command -v "${CLI}" &>/dev/null; then')
    out.append('    echo "error: ${CLI} is not executable or not found" >&2')
    out.append("    exit 2")
    out.append("fi")
    out.append("")
    out.append("# Counters")
    out.append("_pass=0")
    out.append("_fail=0")
    out.append("_total=0")
    out.append("")
    out.append("# Color support")
    out.append('if [[ -t 1 ]]; then')
    out.append('    _red="\\033[31m"')
    out.append('    _green="\\033[32m"')
    out.append('    _reset="\\033[0m"')
    out.append("else")
    out.append('    _red="" _green="" _reset=""')
    out.append("fi")
    out.extend(HARNESS_RUNTIME.rstrip("\n").split("\n"))

    for component, emit in (("age", emit_age_tests), ("date", emit_date_tests),
                            ("time", emit_time_tests), ("duration", emit_duration_tests)):
        out.append("")
        out.append("# ══════════════════════════════════════════════════════════════")
        out.append(f"# {component.upper()} COMPONENT")
        out.append("# ══════════════════════════════════════════════════════════════")
        lines = []
        emit(load_tests(component)["sections"], lines)
        out.extend(lines)

    out.extend(HARNESS_CHECK.rstrip("\n").split("\n"))

    # Write output
    harness_path = ROOT / "cli" / "test-harness.sh"
    with open(harness_path, "w") as f:
        f.write("\n".join(out) + "\n")
    os.chmod(harness_path, 0o755)

    # Count tests
    test_count = sum(1 for line in out if line.startswith("run_test ")
                     or line.startswith("run_null ")
                     or line.startswith("run_regex "))
    print(f"Generated {harness_path} with {test_count} test cases")


if __name__ == "__main__":
    generate()
