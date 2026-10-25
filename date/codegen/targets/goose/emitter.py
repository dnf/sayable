"""Goose locale emitter for sayable-date — single file with all locales.

Each locale is a function returning its DateLocale: a single top-level
table of struct literals makes native builds superlinearly slow. Day
format exceptions are small module-level arrays, because a locale
function cannot return a slice viewing a temporary array literal.
"""

from __future__ import annotations

import os

from codegen.banner import locale_source_comment, make_header

HEADER = make_header("codegen/targets/goose/emitter.py")

_OPTIONAL_PHRASES = (
    ("dayAfterTomorrow", "day_after_tomorrow"),
    ("dayBeforeYesterday", "day_before_yesterday"),
    ("thisWeekday", "this_weekday"),
    ("nextWeekday", "next_weekday"),
    ("lastWeekday", "last_weekday"),
)

_OVERRIDE_STRINGS = (
    ("dayFormat", "day_format"),
    ("datePattern", "date_pattern"),
    ("datePatternWithYear", "date_pattern_with_year"),
    ("today", "today"),
    ("tomorrow", "tomorrow"),
    ("yesterday", "yesterday"),
)

_OVERRIDE_ARRAYS = (
    ("months", "months"),
    ("monthsInDate", "months_in_date"),
    ("weekdays", "weekdays"),
)


def _quote(s: str) -> str:
    escaped = s.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def _str_array(items: list[str]) -> str:
    return "[" + ", ".join(_quote(s) for s in items) + "]"


def _ident(code: str) -> str:
    return code.replace("-", "_").lower()


def _exceptions_name(code: str, mode: str = "") -> str:
    prefix = f"{_ident(code)}_{mode}" if mode else _ident(code)
    return f"{prefix}_day_format_exceptions".upper()


def _emit_exceptions(name: str, exceptions: dict[str, str]) -> list[str]:
    entries = sorted(exceptions.items(), key=lambda x: int(x[0]))
    lines = [f"let {name} = ["]
    for day, fmt in entries:
        lines.append(f"    DayFormatException {{ day: {int(day)}, format: {_quote(fmt)} }},")
    lines.append("];")
    lines.append("")
    return lines


def _compactness_override(ovr: dict, exceptions_name: str) -> str:
    fields = []
    for key, name in _OVERRIDE_ARRAYS:
        if key in ovr:
            fields.append(f"has_{name}: true")
            fields.append(f"{name}: {_str_array(ovr[key])}")
    for key, name in _OVERRIDE_STRINGS:
        if key in ovr:
            fields.append(f"has_{name}: true")
            fields.append(f"{name}: {_quote(ovr[key])}")
    if "dayFormatExceptions" in ovr:
        fields.append("has_day_format_exceptions: true")
        fields.append(f"day_format_exceptions: {exceptions_name}")
    return "CompactnessOverride { " + ", ".join(fields + [".."]) + " }"


def _emit_locale(data: dict) -> list[str]:
    code = data["code"]
    lines = [locale_source_comment(code).rstrip()]

    if data.get("dayFormatExceptions"):
        lines.extend(_emit_exceptions(_exceptions_name(code), data["dayFormatExceptions"]))
    for mode in ("short", "compact"):
        if "dayFormatExceptions" in data.get(mode, {}):
            lines.extend(_emit_exceptions(_exceptions_name(code, mode), data[mode]["dayFormatExceptions"]))

    lines.append(f"fn locale_{_ident(code)}() -> DateLocale {{")
    lines.append("    DateLocale {")
    lines.append(f"        code: {_quote(code)},")
    lines.append(f"        months: {_str_array(data['months'])},")
    lines.append(f"        weekdays: {_str_array(data['weekdays'])},")
    lines.append(f"        day_format: {_quote(data['dayFormat'])},")
    if data.get("dayFormatExceptions"):
        lines.append(f"        day_format_exceptions: {_exceptions_name(code)},")
    lines.append(f"        date_pattern: {_quote(data['datePattern'])},")
    lines.append(f"        date_pattern_with_year: {_quote(data['datePatternWithYear'])},")
    lines.append(f"        today: {_quote(data['today'])},")
    lines.append(f"        tomorrow: {_quote(data['tomorrow'])},")
    lines.append(f"        yesterday: {_quote(data['yesterday'])},")
    for key, field in _OPTIONAL_PHRASES:
        if key in data:
            lines.append(f"        {field}: {_quote(data[key])},")
    if "monthsInDate" in data:
        lines.append("        has_months_in_date: true,")
        lines.append(f"        months_in_date: {_str_array(data['monthsInDate'])},")
    for mode, field in (("short", "short_override"), ("compact", "compact_override")):
        if mode in data:
            ovr = _compactness_override(data[mode], _exceptions_name(code, mode))
            lines.append(f"        {field}: {ovr},")
    lines.append("    }")
    lines.append("}")
    lines.append("")
    return lines


def emit_all(all_locales: list[dict]) -> str:
    """Generate the single locales.goose file with all locales."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER]
    lines.append("namespace sayabledate;")
    lines.append("")

    for data in sorted_locs:
        lines.extend(_emit_locale(data))

    lines.append("// Look up a locale by exact, case-sensitive code.")
    lines.append("fn get_locale(code: u8[:]) -> DateLocale, bool {")
    for data in sorted_locs:
        c = data["code"]
        lines.append(f"    if code == {_quote(c)} {{ return locale_{_ident(c)}(), true; }}")
    lines.append("    return DateLocale { .. }, false;")
    lines.append("}")
    lines.append("")

    lines.append("let LOCALE_CODES = [")
    for data in sorted_locs:
        lines.append(f"    {_quote(data['code'])},")
    lines.append("];")
    lines.append("")

    return "\n".join(lines)


def output_path(root: str) -> str:
    return os.path.join(root, "impl", "goose", "sayabledate", "locales", "locales.goose")
