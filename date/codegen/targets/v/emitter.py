"""V locale emitter for sayable-date.

V requires module names to match directory names and doesn't support
importing parent modules from subdirectories. Generated locale files
live in a `locales/` subdirectory with `module locales`. Type definitions
are duplicated in `locales/types.v` to avoid circular imports.

The main formatter in the parent directory provides the public API
and formatter logic.
"""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header

HEADER = make_header("codegen/targets/v/emitter.py", line_prefix="// ")


def _quote(s: str) -> str:
    """Quote a string for V."""
    escaped = s.replace("\\", "\\\\").replace("'", "\\'")
    return f"'{escaped}'"


def _str_array(items: list[str]) -> str:
    """Emit a V fixed-size array literal."""
    return "[" + ", ".join(_quote(s) for s in items) + "]!"


def _str_map(d: dict[str, str]) -> str:
    """Emit a V map[string]string literal."""
    if not d:
        return "map[string]string{}"
    pairs = [f"\t\t{_quote(k)}: {_quote(v)}" for k, v in d.items()]
    return "{\n" + "\n".join(pairs) + "\n\t}"


def emit_locale(data: dict) -> str:
    """Generate a V locale file from canonical JSON."""
    code = data["code"]
    name = data["name"]
    safe_code = code.replace("-", "_")

    lines = [HEADER + locale_source_comment(code, line_prefix="// ")]
    lines.append(f"// {name} locale.")
    lines.append("module locales\n")

    # Locale constant
    lines.append(f"pub const locale_{safe_code} = DateLocale{{")
    lines.append(f"\tcode: {_quote(code)}")

    # Months (12 elements)
    lines.append(f"\tmonths: {_str_array(data['months'])}")

    # Weekdays (7 elements)
    lines.append(f"\tweekdays: {_str_array(data['weekdays'])}")

    # Day format
    lines.append(f"\tday_format: {_quote(data['dayFormat'])}")

    # Day format exceptions
    if "dayFormatExceptions" in data and data["dayFormatExceptions"]:
        lines.append(f"\tday_format_exceptions: {_str_map(data['dayFormatExceptions'])}")

    # Date patterns
    lines.append(f"\tdate_pattern: {_quote(data['datePattern'])}")
    lines.append(f"\tdate_pattern_with_year: {_quote(data['datePatternWithYear'])}")

    # Today/tomorrow/yesterday
    lines.append(f"\ttoday: {_quote(data['today'])}")
    lines.append(f"\ttomorrow: {_quote(data['tomorrow'])}")
    lines.append(f"\tyesterday: {_quote(data['yesterday'])}")

    # Optional proximity fields
    if "dayAfterTomorrow" in data:
        lines.append(f"\tday_after_tomorrow: {_quote(data['dayAfterTomorrow'])}")
        lines.append("\thas_day_after_tomorrow: true")
    if "dayBeforeYesterday" in data:
        lines.append(f"\tday_before_yesterday: {_quote(data['dayBeforeYesterday'])}")
        lines.append("\thas_day_before_yesterday: true")
    if "thisWeekday" in data:
        lines.append(f"\tthis_weekday: {_quote(data['thisWeekday'])}")
        lines.append("\thas_this_weekday: true")
    if "nextWeekday" in data:
        lines.append(f"\tnext_weekday: {_quote(data['nextWeekday'])}")
        lines.append("\thas_next_weekday: true")
    if "lastWeekday" in data:
        lines.append(f"\tlast_weekday: {_quote(data['lastWeekday'])}")
        lines.append("\thas_last_weekday: true")
    if "monthsInDate" in data:
        lines.append(f"\tmonths_in_date: {_str_array(data['monthsInDate'])}")
        lines.append("\thas_months_in_date: true")

    # Short override
    if "short" in data:
        ovr = data["short"]
        lines.append("\thas_short: true")
        parts = []
        if "months" in ovr:
            parts.append(f"\t\tmonths: {_str_array(ovr['months'])}")
            parts.append("\t\thas_months: true")
        if "weekdays" in ovr:
            parts.append(f"\t\tweekdays: {_str_array(ovr['weekdays'])}")
            parts.append("\t\thas_weekdays: true")
        if "dayFormat" in ovr:
            parts.append(f"\t\tday_format: {_quote(ovr['dayFormat'])}")
            parts.append("\t\thas_day_format: true")
        if "datePattern" in ovr:
            parts.append(f"\t\tdate_pattern: {_quote(ovr['datePattern'])}")
            parts.append("\t\thas_date_pattern: true")
        if "datePatternWithYear" in ovr:
            parts.append(f"\t\tdate_pattern_with_year: {_quote(ovr['datePatternWithYear'])}")
            parts.append("\t\thas_date_pattern_with_year: true")
        lines.append("\tshort_override: DateCompactnessOverride{")
        lines.extend(parts)
        lines.append("\t}")

    # Compact override
    if "compact" in data:
        ovr = data["compact"]
        lines.append("\thas_compact: true")
        parts = []
        if "datePattern" in ovr:
            parts.append(f"\t\tdate_pattern: {_quote(ovr['datePattern'])}")
            parts.append("\t\thas_date_pattern: true")
        if "datePatternWithYear" in ovr:
            parts.append(f"\t\tdate_pattern_with_year: {_quote(ovr['datePatternWithYear'])}")
            parts.append("\t\thas_date_pattern_with_year: true")
        lines.append("\tcompact_override: DateCompactnessOverride{")
        lines.extend(parts)
        lines.append("\t}")

    lines.append("}")
    lines.append("")

    return "\n".join(lines)


def emit_barrel(all_locales: list[dict]) -> str:
    """Generate registry.v with get_date_locale function."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER]
    lines.append("// Locale registry for all supported languages.")
    lines.append("module locales\n")

    lines.append("pub fn get_date_locale(code string) ?DateLocale {")
    lines.append("\treturn match code {")
    for loc in sorted_locs:
        code = loc["code"]
        safe_code = code.replace("-", "_")
        lines.append(f"\t\t{_quote(code)} {{ locale_{safe_code} }}")
    lines.append("\t\telse { none }")
    lines.append("\t}")
    lines.append("}")
    lines.append("")

    return "\n".join(lines)


def output_path(code: str, root: str) -> str:
    import os
    return os.path.join(root, "impl", "v", "locales", f"locale_{code.replace('-', '_')}.v")


def barrel_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "v", "locales", "registry.v")
