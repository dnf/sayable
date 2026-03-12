"""Gleam locale emitter for sayable-date."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header

HEADER = make_header("codegen/targets/gleam/emitter.py")


def _module_name(code: str) -> str:
    """Convert locale code to Gleam module name (lowercase, hyphens to underscores)."""
    return code.replace("-", "_")


def _quote(s: str) -> str:
    escaped = s.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def _str_list(items: list[str]) -> str:
    return "[" + ", ".join(_quote(s) for s in items) + "]"


def _str_dict(d: dict[str, str]) -> str:
    pairs = [f"#({_quote(k)}, {_quote(v)})" for k, v in d.items()]
    return "[" + ", ".join(pairs) + "]"


def _build_compactness(ovr: dict, indent: str) -> str:
    inner = indent + "  "
    parts = []
    for field in ("months", "months_in_date", "weekdays"):
        json_key = {
            "months": "months",
            "months_in_date": "monthsInDate",
            "weekdays": "weekdays",
        }[field]
        if json_key in ovr:
            parts.append(f"{inner}{field}: Ok({_str_list(ovr[json_key])}),")
        else:
            parts.append(f"{inner}{field}: Error(Nil),")
    for field in ("day_format", "date_pattern", "date_pattern_with_year",
                  "today", "tomorrow", "yesterday"):
        json_key = {
            "day_format": "dayFormat",
            "date_pattern": "datePattern",
            "date_pattern_with_year": "datePatternWithYear",
            "today": "today",
            "tomorrow": "tomorrow",
            "yesterday": "yesterday",
        }[field]
        if json_key in ovr:
            parts.append(f"{inner}{field}: Ok({_quote(ovr[json_key])}),")
        else:
            parts.append(f"{inner}{field}: Error(Nil),")
    if "dayFormatExceptions" in ovr:
        parts.append(f"{inner}day_format_exceptions: Ok({_str_dict(ovr['dayFormatExceptions'])}),")
    else:
        parts.append(f"{inner}day_format_exceptions: Error(Nil),")
    return "\n".join(parts)


def emit_locale(data: dict) -> str:
    code = data["code"]
    mod = _module_name(code)

    lines = [HEADER + locale_source_comment(code)]
    lines.append("import sayabledate/types")
    lines.append("")
    lines.append("pub fn locale() -> types.DateLocale {")
    lines.append("  types.DateLocale(")

    # Code
    lines.append(f"    code: {_quote(code)},")

    # Months and weekdays
    lines.append(f"    months: {_str_list(data['months'])},")
    lines.append(f"    weekdays: {_str_list(data['weekdays'])},")

    # Day format
    lines.append(f"    day_format: {_quote(data['dayFormat'])},")

    # Day format exceptions
    if "dayFormatExceptions" in data and data["dayFormatExceptions"]:
        lines.append(f"    day_format_exceptions: {_str_dict(data['dayFormatExceptions'])},")
    else:
        lines.append("    day_format_exceptions: [],")

    # Patterns
    lines.append(f"    date_pattern: {_quote(data['datePattern'])},")
    lines.append(f"    date_pattern_with_year: {_quote(data['datePatternWithYear'])},")

    # Proximity strings
    lines.append(f"    today: {_quote(data['today'])},")
    lines.append(f"    tomorrow: {_quote(data['tomorrow'])},")
    lines.append(f"    yesterday: {_quote(data['yesterday'])},")

    # Optional proximity strings
    for field, json_key in [
        ("day_after_tomorrow", "dayAfterTomorrow"),
        ("day_before_yesterday", "dayBeforeYesterday"),
        ("this_weekday", "thisWeekday"),
        ("next_weekday", "nextWeekday"),
        ("last_weekday", "lastWeekday"),
    ]:
        if json_key in data:
            lines.append(f"    {field}: Ok({_quote(data[json_key])}),")
        else:
            lines.append(f"    {field}: Error(Nil),")

    # Months in date (genitive forms)
    if "monthsInDate" in data:
        lines.append(f"    months_in_date: Ok({_str_list(data['monthsInDate'])}),")
    else:
        lines.append("    months_in_date: Error(Nil),")

    # Short/compact overrides
    for mode in ("short", "compact"):
        if mode in data:
            lines.append(f"    {mode}: Ok(types.CompactnessOverride(")
            lines.append(_build_compactness(data[mode], "    "))
            lines.append("    )),")
        else:
            lines.append(f"    {mode}: Error(Nil),")

    lines.append("  )")
    lines.append("}")
    lines.append("")

    return "\n".join(lines)


def emit_registry(all_locales: list[dict]) -> str:
    """Generate the locales module with get(code) function."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER]
    lines.append("import sayabledate/types")

    for loc in sorted_locs:
        code = loc["code"]
        mod = _module_name(code)
        lines.append(f"import sayabledate/locales/{mod} as locale_{mod}")
    lines.append("")

    lines.append("pub fn get(code: String) -> Result(types.DateLocale, Nil) {")
    lines.append("  case code {")
    for loc in sorted_locs:
        code = loc["code"]
        mod = _module_name(code)
        lines.append(f"    {_quote(code)} -> Ok(locale_{mod}.locale())")
    lines.append("    _ -> Error(Nil)")
    lines.append("  }")
    lines.append("}")
    lines.append("")

    return "\n".join(lines)


def output_path(code: str, root: str) -> str:
    import os
    mod = code.replace("-", "_")
    return os.path.join(root, "impl", "gleam", "src", "sayabledate", "locales", f"{mod}.gleam")


def registry_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "gleam", "src", "sayabledate", "locales", "locales.gleam")
