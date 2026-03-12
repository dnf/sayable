"""Julia locale emitter for sayable-date."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header

HEADER = make_header("codegen/targets/julia/emitter.py", line_prefix="# ")


def _quote(s: str) -> str:
    """Quote a string for Julia."""
    escaped = s.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def _str_list(items: list[str]) -> str:
    """Emit a Julia vector of strings on one line."""
    return "[" + ", ".join(_quote(s) for s in items) + "]"


def _dict_str(d: dict[str, str]) -> str:
    """Emit a Julia Dict of String=>String on one line."""
    pairs = [f"{_quote(k)} => {_quote(v)}" for k, v in d.items()]
    return "Dict(" + ", ".join(pairs) + ")"


def emit_locale(data: dict) -> str:
    """Generate a Julia locale file from canonical JSON."""
    code = data["code"]
    name = data["name"]
    lines = [HEADER + locale_source_comment(code, line_prefix="# "), f"# {name} locale.\n"]

    # Locale constant
    lines.append(f"const {code.upper()} = DateLocale(")
    lines.append(f"    code = {_quote(code)},")
    lines.append(f"    months = {_str_list(data['months'])},")
    lines.append(f"    weekdays = {_str_list(data['weekdays'])},")
    lines.append(f"    day_format = {_quote(data['dayFormat'])},")

    if "dayFormatExceptions" in data and data["dayFormatExceptions"]:
        lines.append(f"    day_format_exceptions = {_dict_str(data['dayFormatExceptions'])},")
    else:
        lines.append("    day_format_exceptions = Dict{String, String}(),")

    lines.append(f"    date_pattern = {_quote(data['datePattern'])},")
    lines.append(f"    date_pattern_with_year = {_quote(data['datePatternWithYear'])},")
    lines.append(f"    today = {_quote(data['today'])},")
    lines.append(f"    tomorrow = {_quote(data['tomorrow'])},")
    lines.append(f"    yesterday = {_quote(data['yesterday'])},")

    # Optional proximity fields
    if "dayAfterTomorrow" in data:
        lines.append(f"    day_after_tomorrow = {_quote(data['dayAfterTomorrow'])},")
    if "dayBeforeYesterday" in data:
        lines.append(f"    day_before_yesterday = {_quote(data['dayBeforeYesterday'])},")
    if "thisWeekday" in data:
        lines.append(f"    this_weekday = {_quote(data['thisWeekday'])},")
    if "nextWeekday" in data:
        lines.append(f"    next_weekday = {_quote(data['nextWeekday'])},")
    if "lastWeekday" in data:
        lines.append(f"    last_weekday = {_quote(data['lastWeekday'])},")
    if "monthsInDate" in data:
        lines.append(f"    months_in_date = {_str_list(data['monthsInDate'])},")

    # Short override
    if "short" in data:
        ovr = data["short"]
        parts = []
        if "months" in ovr:
            parts.append(f"        months = {_str_list(ovr['months'])},")
        if "weekdays" in ovr:
            parts.append(f"        weekdays = {_str_list(ovr['weekdays'])},")
        if "dayFormat" in ovr:
            parts.append(f"        day_format = {_quote(ovr['dayFormat'])},")
        if "datePattern" in ovr:
            parts.append(f"        date_pattern = {_quote(ovr['datePattern'])},")
        if "datePatternWithYear" in ovr:
            parts.append(f"        date_pattern_with_year = {_quote(ovr['datePatternWithYear'])},")
        lines.append("    short_override = DateCompactnessOverride(")
        lines.extend(parts)
        lines.append("    ),")

    # Compact override
    if "compact" in data:
        ovr = data["compact"]
        parts = []
        if "datePattern" in ovr:
            parts.append(f"        date_pattern = {_quote(ovr['datePattern'])},")
        if "datePatternWithYear" in ovr:
            parts.append(f"        date_pattern_with_year = {_quote(ovr['datePatternWithYear'])},")
        lines.append("    compact_override = DateCompactnessOverride(")
        lines.extend(parts)
        lines.append("    ),")

    lines.append(")")
    lines.append("")

    return "\n".join(lines)


def emit_barrel(all_locales: list[dict]) -> str:
    """Generate the locales/registry.jl barrel file."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER, "# Locale registry for all supported languages.\n"]

    # Include all locale files
    for loc in sorted_locs:
        code = loc["code"]
        lines.append(f'include("{code}.jl")')

    lines.append("")

    # Lookup dict + function
    lines.append("const _ALL = Dict{String, DateLocale}(")
    for loc in sorted_locs:
        code = loc["code"]
        lines.append(f'    "{code}" => {code.upper()},')
    lines.append(")")
    lines.append("")
    lines.append("function get_locale(code::String)::Union{DateLocale, Nothing}")
    lines.append("    get(_ALL, code, nothing)")
    lines.append("end")
    lines.append("")

    return "\n".join(lines)


def output_path(code: str, root: str) -> str:
    import os
    return os.path.join(root, "impl", "julia", "src", "locales", f"{code}.jl")


def barrel_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "julia", "src", "locales", "registry.jl")
