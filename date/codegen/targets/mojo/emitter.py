"""Mojo locale emitter for sayable-date."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header

HEADER = make_header("codegen/targets/mojo/emitter.py", line_prefix="# ")

_MOJO_RESERVED = {
    "alias", "and", "as", "async", "await", "break", "class", "continue",
    "def", "del", "elif", "else", "except", "finally", "fn", "for", "from",
    "global", "if", "import", "in", "is", "lambda", "let", "mut", "nonlocal",
    "not", "or", "pass", "raise", "return", "self", "struct", "trait", "try",
    "var", "while", "with", "yield",
}


def _safe_id(code: str) -> str:
    """Escape locale codes that are Mojo reserved keywords."""
    safe = code.replace("-", "_")
    if safe in _MOJO_RESERVED:
        return f"{safe}_locale"
    return safe


def _quote(s: str) -> str:
    escaped = s.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def _str_list(items: list[str], indent: int = 4) -> str:
    """Emit a Mojo list literal construction using append calls."""
    # Mojo doesn't have list literals, so we build via factory function
    return items  # we'll handle this inline


def emit_locale(data: dict) -> str:
    code = data["code"]
    name = data["name"]

    lines = [HEADER + locale_source_comment(code, line_prefix="# ")]
    lines.append(f'"""{name} locale."""')
    lines.append("")
    lines.append("from ..locale import (")
    lines.append("    DateLocale,")
    lines.append("    CompactnessOverride,")
    lines.append("    DayFormatException,")
    lines.append("    build_date_locale,")
    lines.append("    build_compactness_override,")
    lines.append("    build_day_exception,")
    lines.append(")")
    lines.append("")
    lines.append("")

    lines.append(f"fn build_{_safe_id(code)}() -> DateLocale:")
    lines.append(f'    """Build the {name} locale."""')

    # Months (12 named fields)
    months = data["months"]
    for i, m in enumerate(months):
        lines.append(f"    var month{i} = {_quote(m)}")

    # Weekdays (7 named fields)
    weekdays = data["weekdays"]
    for i, w in enumerate(weekdays):
        lines.append(f"    var weekday{i} = {_quote(w)}")

    # Day format
    lines.append(f"    var day_format = {_quote(data['dayFormat'])}")

    # Day format exceptions
    exceptions = data.get("dayFormatExceptions", {})
    lines.append(f"    var num_exceptions = {len(exceptions)}")
    exc_items = sorted(exceptions.items(), key=lambda x: int(x[0]))
    for idx, (k, v) in enumerate(exc_items):
        lines.append(f"    var exc{idx} = build_day_exception({_quote(k)}, {_quote(v)})")

    # Patterns
    lines.append(f"    var date_pattern = {_quote(data['datePattern'])}")
    lines.append(f"    var date_pattern_with_year = {_quote(data['datePatternWithYear'])}")

    # Proximity strings
    lines.append(f"    var today = {_quote(data['today'])}")
    lines.append(f"    var tomorrow = {_quote(data['tomorrow'])}")
    lines.append(f"    var yesterday = {_quote(data['yesterday'])}")

    day_after = data.get("dayAfterTomorrow", "")
    day_before = data.get("dayBeforeYesterday", "")
    this_weekday = data.get("thisWeekday", "")
    next_weekday = data.get("nextWeekday", "")
    last_weekday = data.get("lastWeekday", "")

    lines.append(f"    var day_after_tomorrow = {_quote(day_after)}")
    lines.append(f"    var day_before_yesterday = {_quote(day_before)}")
    lines.append(f"    var this_weekday = {_quote(this_weekday)}")
    lines.append(f"    var next_weekday = {_quote(next_weekday)}")
    lines.append(f"    var last_weekday = {_quote(last_weekday)}")

    # Months in date (genitive)
    months_in_date = data.get("monthsInDate")
    if months_in_date:
        for i, m in enumerate(months_in_date):
            lines.append(f"    var month_in_date{i} = {_quote(m)}")
        lines.append("    var has_months_in_date = True")
    else:
        lines.append("    var has_months_in_date = False")

    # Short/compact overrides
    for mode in ("short", "compact"):
        if mode in data:
            ovr = data[mode]
            lines.append("")
            lines.append(f"    var {mode}_ovr = build_compactness_override()")
            if "months" in ovr:
                for i, m in enumerate(ovr["months"]):
                    lines.append(f"    {mode}_ovr.month{i} = {_quote(m)}")
                lines.append(f"    {mode}_ovr.has_months = True")
            if "weekdays" in ovr:
                for i, w in enumerate(ovr["weekdays"]):
                    lines.append(f"    {mode}_ovr.weekday{i} = {_quote(w)}")
                lines.append(f"    {mode}_ovr.has_weekdays = True")
            if "dayFormat" in ovr:
                lines.append(f"    {mode}_ovr.day_format = {_quote(ovr['dayFormat'])}")
                lines.append(f"    {mode}_ovr.has_day_format = True")
            if "dayFormatExceptions" in ovr:
                ovr_excs = sorted(ovr["dayFormatExceptions"].items(), key=lambda x: int(x[0]))
                for idx, (k, v) in enumerate(ovr_excs):
                    lines.append(f"    {mode}_ovr.exc{idx} = build_day_exception({_quote(k)}, {_quote(v)})")
                lines.append(f"    {mode}_ovr.num_exceptions = {len(ovr_excs)}")
                lines.append(f"    {mode}_ovr.has_exceptions = True")
            if "datePattern" in ovr:
                lines.append(f"    {mode}_ovr.date_pattern = {_quote(ovr['datePattern'])}")
                lines.append(f"    {mode}_ovr.has_date_pattern = True")
            if "datePatternWithYear" in ovr:
                lines.append(f"    {mode}_ovr.date_pattern_with_year = {_quote(ovr['datePatternWithYear'])}")
                lines.append(f"    {mode}_ovr.has_date_pattern_with_year = True")
            if "today" in ovr:
                lines.append(f"    {mode}_ovr.today = {_quote(ovr['today'])}")
                lines.append(f"    {mode}_ovr.has_today = True")
            if "tomorrow" in ovr:
                lines.append(f"    {mode}_ovr.tomorrow = {_quote(ovr['tomorrow'])}")
                lines.append(f"    {mode}_ovr.has_tomorrow = True")
            if "yesterday" in ovr:
                lines.append(f"    {mode}_ovr.yesterday = {_quote(ovr['yesterday'])}")
                lines.append(f"    {mode}_ovr.has_yesterday = True")
            if "monthsInDate" in ovr:
                for i, m in enumerate(ovr["monthsInDate"]):
                    lines.append(f"    {mode}_ovr.month_in_date{i} = {_quote(m)}")
                lines.append(f"    {mode}_ovr.has_months_in_date = True")

    lines.append("")
    lines.append("    return build_date_locale(")
    lines.append(f"        code={_quote(code)},")
    for i in range(12):
        lines.append(f"        month{i}=month{i},")
    for i in range(7):
        lines.append(f"        weekday{i}=weekday{i},")
    lines.append("        day_format=day_format,")

    # Pass exceptions
    for idx in range(len(exc_items)):
        lines.append(f"        exc{idx}=exc{idx},")
    lines.append(f"        num_exceptions={len(exc_items)},")

    lines.append("        date_pattern=date_pattern,")
    lines.append("        date_pattern_with_year=date_pattern_with_year,")
    lines.append("        today=today,")
    lines.append("        tomorrow=tomorrow,")
    lines.append("        yesterday=yesterday,")
    lines.append("        day_after_tomorrow=day_after_tomorrow,")
    lines.append("        day_before_yesterday=day_before_yesterday,")
    lines.append("        this_weekday=this_weekday,")
    lines.append("        next_weekday=next_weekday,")
    lines.append("        last_weekday=last_weekday,")
    if months_in_date:
        for i in range(12):
            lines.append(f"        month_in_date{i}=month_in_date{i},")
    lines.append("        has_months_in_date=has_months_in_date,")

    for mode in ("short", "compact"):
        if mode in data:
            lines.append(f"        {mode}_override={mode}_ovr,")
            lines.append(f"        has_{mode}=True,")

    lines.append("    )")
    lines.append("")

    return "\n".join(lines)


def emit_registry(all_locales: list[dict]) -> str:
    """Generate the registry.mojo file."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER]
    lines.append('"""Locale registry for all supported languages."""')
    lines.append("")
    lines.append("from ..locale import DateLocale")

    for loc in sorted_locs:
        code = loc["code"]
        lines.append(f"from .{_safe_id(code)} import build_{_safe_id(code)}")
    lines.append("")
    lines.append("")

    lines.append("fn get_locale(code: String) -> DateLocale:")
    lines.append('    """Look up a locale by its code string.')
    lines.append("")
    lines.append("    Returns the locale if found, or the English locale as fallback.")
    lines.append('    """')
    for loc in sorted_locs:
        code = loc["code"]
        lines.append(f'    if code == {_quote(code)}:')
        lines.append(f"        return build_{_safe_id(code)}()")
    lines.append("    return build_en()")
    lines.append("")
    lines.append("")
    lines.append("fn has_locale(code: String) -> Bool:")
    lines.append('    """Check if a locale code is known."""')
    for loc in sorted_locs:
        code = loc["code"]
        lines.append(f'    if code == {_quote(code)}:')
        lines.append("        return True")
    lines.append("    return False")
    lines.append("")

    return "\n".join(lines)


def output_path(code: str, root: str) -> str:
    import os
    return os.path.join(root, "impl", "mojo", "src", "sayable_date", "locales", f"{_safe_id(code)}.mojo")


def registry_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "mojo", "src", "sayable_date", "locales", "registry.mojo")
