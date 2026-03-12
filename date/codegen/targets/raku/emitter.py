"""Raku locale emitter for sayable-date."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header

HEADER = make_header("codegen/targets/raku/emitter.py", line_prefix="# ")


def _quote(s: str) -> str:
    escaped = s.replace("\\", "\\\\").replace("'", "\\'")
    return f"'{escaped}'"


def _str_list(items: list[str]) -> str:
    return "(" + ", ".join(_quote(s) for s in items) + ")"


def _dict_str(d: dict[str, str]) -> str:
    pairs = [f"{_quote(k)} => {_quote(v)}" for k, v in d.items()]
    return "{ " + ", ".join(pairs) + " }"


def emit_locale(data: dict) -> str:
    code = data["code"]
    uc = code.upper()

    lines = []
    lines.append("use v6.d;")
    lines.append("")
    lines.append((HEADER + locale_source_comment(code, line_prefix="# ")).rstrip())
    lines.append(f"unit module SayableDate::Locales::{uc};")
    lines.append("")
    lines.append("our sub locale() {")
    lines.append("    {")

    # Code
    lines.append(f"        code => {_quote(code)},")

    # Months
    lines.append(f"        months => {_str_list(data['months'])},")

    # Weekdays
    lines.append(f"        weekdays => {_str_list(data['weekdays'])},")

    # Day format
    lines.append(f"        day-format => {_quote(data['dayFormat'])},")

    # Day format exceptions
    if "dayFormatExceptions" in data and data["dayFormatExceptions"]:
        lines.append(f"        day-format-exceptions => {_dict_str(data['dayFormatExceptions'])},")
    else:
        lines.append("        day-format-exceptions => {},")

    # Patterns
    lines.append(f"        date-pattern => {_quote(data['datePattern'])},")
    lines.append(f"        date-pattern-with-year => {_quote(data['datePatternWithYear'])},")

    # Proximity
    lines.append(f"        today => {_quote(data['today'])},")
    lines.append(f"        tomorrow => {_quote(data['tomorrow'])},")
    lines.append(f"        yesterday => {_quote(data['yesterday'])},")

    # Optional fields
    if "dayAfterTomorrow" in data:
        lines.append(f"        day-after-tomorrow => {_quote(data['dayAfterTomorrow'])},")
    if "dayBeforeYesterday" in data:
        lines.append(f"        day-before-yesterday => {_quote(data['dayBeforeYesterday'])},")
    if "thisWeekday" in data:
        lines.append(f"        this-weekday => {_quote(data['thisWeekday'])},")
    if "nextWeekday" in data:
        lines.append(f"        next-weekday => {_quote(data['nextWeekday'])},")
    if "lastWeekday" in data:
        lines.append(f"        last-weekday => {_quote(data['lastWeekday'])},")
    if "monthsInDate" in data:
        lines.append(f"        months-in-date => {_str_list(data['monthsInDate'])},")

    # Short override
    if "short" in data:
        ovr = data["short"]
        lines.append("        short => {")
        if "months" in ovr:
            lines.append(f"            months => {_str_list(ovr['months'])},")
        if "weekdays" in ovr:
            lines.append(f"            weekdays => {_str_list(ovr['weekdays'])},")
        if "dayFormat" in ovr:
            lines.append(f"            day-format => {_quote(ovr['dayFormat'])},")
        if "datePattern" in ovr:
            lines.append(f"            date-pattern => {_quote(ovr['datePattern'])},")
        if "datePatternWithYear" in ovr:
            lines.append(f"            date-pattern-with-year => {_quote(ovr['datePatternWithYear'])},")
        lines.append("        },")

    # Compact override
    if "compact" in data:
        ovr = data["compact"]
        lines.append("        compact => {")
        if "datePattern" in ovr:
            lines.append(f"            date-pattern => {_quote(ovr['datePattern'])},")
        if "datePatternWithYear" in ovr:
            lines.append(f"            date-pattern-with-year => {_quote(ovr['datePatternWithYear'])},")
        lines.append("        },")

    lines.append("    }")
    lines.append("}")
    lines.append("")

    return "\n".join(lines)


def emit_barrel(all_locales: list[dict]) -> str:
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = ["use v6.d;", "", HEADER.rstrip()]
    lines.append("unit module SayableDate::Locales::Registry;")
    lines.append("")

    for loc in sorted_locs:
        uc = loc["code"].upper()
        lines.append(f"use SayableDate::Locales::{uc};")
    lines.append("")

    lines.append("my %locales = (")
    for loc in sorted_locs:
        code = loc["code"]
        uc = code.upper()
        lines.append(f"    '{code}' => SayableDate::Locales::{uc}::locale(),")
    lines.append(");")
    lines.append("")

    lines.append("our sub get-locale(Str $code) {")
    lines.append("    %locales{$code} // Nil;")
    lines.append("}")
    lines.append("")

    return "\n".join(lines)


def output_path(code: str, root: str) -> str:
    import os
    return os.path.join(root, "impl", "raku", "lib", "SayableDate", "Locales", f"{code.upper()}.rakumod")


def barrel_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "raku", "lib", "SayableDate", "Locales", "Registry.rakumod")
