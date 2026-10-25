"""Goose locale emitter for sayable-time — single file with all locales.

Each locale is a function returning its TimeLocale: a single top-level
table of struct literals makes native Goose builds superlinearly slow.
get_locale() is an if-chain over those functions.
"""

from __future__ import annotations

import os

from codegen.banner import locale_source_comment, make_header

HEADER = make_header("codegen/targets/goose/emitter.py")

_PATTERN_MINUTES = (0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55)


def _quote(s: str) -> str:
    escaped = s.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def _fn_name(code: str) -> str:
    """Prefixed so that no locale code can collide with a Goose keyword."""
    return "locale_" + code.replace("-", "_")


def _string_array(values: list[str]) -> str:
    return "[" + ", ".join(_quote(v) for v in values) + "]"


def _short_clock(clock: dict) -> str:
    fields = [
        f"use_24h: {'true' if clock.get('use24h', True) else 'false'}",
        f"format: {_quote(clock.get('format', '{h}:{mm}'))}",
    ]
    am_pm = clock.get("amPm")
    if am_pm:
        fields.append(f"am_pm: {_string_array(am_pm[:2])}")
    return "ShortClockConfig { " + ", ".join(fields) + " }"


def _emit_locale(data: dict) -> list[str]:
    code = data["code"]
    clock = data["clock"]
    patterns = [clock["patterns"].get(str(m), "") for m in _PATTERN_MINUTES]
    lines = [locale_source_comment(code).rstrip()]
    lines.append(f"fn {_fn_name(code)}() -> TimeLocale {{")
    lines.append("    TimeLocale {")
    lines.append(f"        code: {_quote(code)},")
    lines.append("        clock: ClockConfig {")
    lines.append(f"            hours: {_string_array(clock['hours'])},")
    lines.append(f"            midnight: {_quote(clock['midnight'])},")
    lines.append(f"            noon: {_quote(clock['noon'])},")
    lines.append(f"            patterns: {_string_array(patterns)},")
    lines.append("        },")
    for key, field in (("short", "short_override"), ("compact", "compact_override")):
        if key in data and "clock" in data[key]:
            lines.append(
                f"        {field}: CompactnessOverride {{ has_clock: true, clock: {_short_clock(data[key]['clock'])} }},"
            )
    lines.append("    }")
    lines.append("}")
    lines.append("")
    return lines


def emit_all(all_locales: list[dict]) -> str:
    """Generate the single locales.goose file with all locales."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER]
    lines.append("namespace sayabletime;")
    lines.append("")

    for data in sorted_locs:
        lines.extend(_emit_locale(data))

    lines.append("// Look up a locale by exact, case-sensitive code.")
    lines.append("fn get_locale(code: u8[:]) -> TimeLocale, bool {")
    for data in sorted_locs:
        c = data["code"]
        lines.append(f"    if code == {_quote(c)} {{ return {_fn_name(c)}(), true; }}")
    lines.append("    return default<TimeLocale>(), false;")
    lines.append("}")
    lines.append("")

    lines.append("let LOCALE_CODES = [")
    for data in sorted_locs:
        lines.append(f"    {_quote(data['code'])},")
    lines.append("];")
    lines.append("")

    return "\n".join(lines)


def output_path(root: str) -> str:
    return os.path.join(root, "impl", "goose", "sayabletime", "locales", "locales.goose")
