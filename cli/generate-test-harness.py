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


def quote_arg(a: str) -> str:
    """Quote a CLI argument for the generated bash script."""
    if a == "":
        return "''"
    if " " in a or "'" in a:
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
            if func == "format_date":
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


def generate():
    out = []

    # Header
    out.append("#!/usr/bin/env bash")
    out.append("# ==========================================================================")
    out.append("# Sayable CLI Test Harness")
    out.append("# Generated from canonical test JSON files — do not edit by hand.")
    out.append("# Regenerate: python3 cli/generate-test-harness.py")
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
    out.append("_skip=0")
    out.append("_total=0")
    out.append("")
    out.append("# Color support")
    out.append('if [[ -t 1 ]]; then')
    out.append('    _red="\\033[31m"')
    out.append('    _green="\\033[32m"')
    out.append('    _yellow="\\033[33m"')
    out.append('    _reset="\\033[0m"')
    out.append("else")
    out.append('    _red="" _green="" _yellow="" _reset=""')
    out.append("fi")
    out.append("")
    out.append("# Test helper: expect specific output (exit 0)")
    out.append("run_test() {")
    out.append('    local id="$1" expected="$2"')
    out.append("    shift 2")
    out.append('    _total=$((_total + 1))')
    out.append('    local output rc')
    out.append('    output=$("${CLI}" "$@" 2>/dev/null) && rc=0 || rc=$?')
    out.append('    if [[ ${rc} -eq 0 && "${output}" == "${expected}" ]]; then')
    out.append('        _pass=$((_pass + 1))')
    out.append("    else")
    out.append('        _fail=$((_fail + 1))')
    out.append('        printf "${_red}FAIL${_reset} %s: expected %q, got %q (exit %d)\\n" "${id}" "${expected}" "${output}" "${rc}"')
    out.append("    fi")
    out.append("}")
    out.append("")
    out.append("# Test helper: expect null result (exit 1, no output)")
    out.append("run_null() {")
    out.append('    local id="$1"')
    out.append("    shift")
    out.append('    _total=$((_total + 1))')
    out.append('    local output rc')
    out.append('    output=$("${CLI}" "$@" 2>/dev/null) && rc=0 || rc=$?')
    out.append('    if [[ ${rc} -eq 1 && -z "${output}" ]]; then')
    out.append('        _pass=$((_pass + 1))')
    out.append("    else")
    out.append('        _fail=$((_fail + 1))')
    out.append('        printf "${_red}FAIL${_reset} %s: expected null (exit 1), got exit %d, output: %q\\n" "${id}" "${rc}" "${output}"')
    out.append("    fi")
    out.append("}")
    out.append("")
    out.append("# Test helper: expect output matching a regex (exit 0)")
    out.append("run_regex() {")
    out.append('    local id="$1" pattern="$2"')
    out.append("    shift 2")
    out.append('    _total=$((_total + 1))')
    out.append('    local output rc')
    out.append('    output=$("${CLI}" "$@" 2>/dev/null) && rc=0 || rc=$?')
    out.append('    if [[ ${rc} -eq 0 && "${output}" =~ ${pattern} ]]; then')
    out.append('        _pass=$((_pass + 1))')
    out.append("    else")
    out.append('        _fail=$((_fail + 1))')
    out.append('        printf "${_red}FAIL${_reset} %s: expected match %q, got %q (exit %d)\\n" "${id}" "${pattern}" "${output}" "${rc}"')
    out.append("    fi")
    out.append("}")
    out.append("")
    out.append("# Probe: check if a component is supported")
    out.append("probe_component() {")
    out.append('    local cmd="$1"')
    out.append('    # Try a known-good call; exit 2 means unsupported command')
    out.append('    "${CLI}" "${cmd}" null 2>/dev/null; local rc=$?')
    out.append('    [[ ${rc} -ne 2 ]]')
    out.append("}")
    out.append("")
    out.append("# Detect supported components")
    out.append("_has_age=true")
    out.append("_has_date=true")
    out.append("_has_time=true")
    out.append("_has_duration=true")
    out.append("")
    out.append('probe_component age || _has_age=false')
    out.append('probe_component date || _has_date=false')
    out.append('probe_component time || _has_time=false')
    out.append('probe_component duration || _has_duration=false')
    out.append("")
    out.append('echo "Testing: ${CLI}"')
    out.append('echo "Components: age=${_has_age} date=${_has_date} time=${_has_time} duration=${_has_duration}"')
    out.append('echo ""')

    # ── Age tests ──
    out.append("")
    out.append("# ══════════════════════════════════════════════════════════════")
    out.append("# AGE COMPONENT")
    out.append("# ══════════════════════════════════════════════════════════════")
    out.append('if ${_has_age}; then')
    out.append('echo "▸ Age tests"')

    age_data = load_tests("age")
    age_lines = []
    emit_age_tests(age_data["sections"], age_lines)
    for line in age_lines:
        if line.startswith("#"):
            out.append(line)
        elif line == "":
            out.append("")
        else:
            out.append(line)

    out.append("")
    out.append("else")
    out.append('    echo "⊘ Age: not supported, skipping"')
    out.append("fi")

    # ── Date tests ──
    out.append("")
    out.append("# ══════════════════════════════════════════════════════════════")
    out.append("# DATE COMPONENT")
    out.append("# ══════════════════════════════════════════════════════════════")
    out.append('if ${_has_date}; then')
    out.append('echo "▸ Date tests"')

    date_data = load_tests("date")
    date_lines = []
    emit_date_tests(date_data["sections"], date_lines)
    for line in date_lines:
        if line.startswith("#"):
            out.append(line)
        elif line == "":
            out.append("")
        else:
            out.append(line)

    out.append("")
    out.append("else")
    out.append('    echo "⊘ Date: not supported, skipping"')
    out.append("fi")

    # ── Time tests ──
    out.append("")
    out.append("# ══════════════════════════════════════════════════════════════")
    out.append("# TIME COMPONENT")
    out.append("# ══════════════════════════════════════════════════════════════")
    out.append('if ${_has_time}; then')
    out.append('echo "▸ Time tests"')

    time_data = load_tests("time")
    time_lines = []
    emit_time_tests(time_data["sections"], time_lines)
    for line in time_lines:
        if line.startswith("#"):
            out.append(line)
        elif line == "":
            out.append("")
        else:
            out.append(line)

    out.append("")
    out.append("else")
    out.append('    echo "⊘ Time: not supported, skipping"')
    out.append("fi")

    # ── Duration tests ──
    out.append("")
    out.append("# ══════════════════════════════════════════════════════════════")
    out.append("# DURATION COMPONENT")
    out.append("# ══════════════════════════════════════════════════════════════")
    out.append('if ${_has_duration}; then')
    out.append('echo "▸ Duration tests"')

    duration_data = load_tests("duration")
    duration_lines = []
    emit_duration_tests(duration_data["sections"], duration_lines)
    for line in duration_lines:
        if line.startswith("#"):
            out.append(line)
        elif line == "":
            out.append("")
        else:
            out.append(line)

    out.append("")
    out.append("else")
    out.append('    echo "⊘ Duration: not supported, skipping"')
    out.append("fi")

    # ── Summary ──
    out.append("")
    out.append("# ══════════════════════════════════════════════════════════════")
    out.append("# SUMMARY")
    out.append("# ══════════════════════════════════════════════════════════════")
    out.append("echo")
    out.append('if [[ ${_fail} -eq 0 ]]; then')
    out.append('    printf "${_green}All %d tests passed.${_reset}\\n" "${_total}"')
    out.append("else")
    out.append('    printf "${_red}%d failed${_reset}, ${_green}%d passed${_reset} out of %d tests.\\n" "${_fail}" "${_pass}" "${_total}"')
    out.append("fi")
    out.append("")
    out.append('[[ ${_fail} -eq 0 ]]')

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
