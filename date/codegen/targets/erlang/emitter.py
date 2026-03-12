"""Erlang locale emitter for sayable-date."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header

HEADER = make_header("codegen/targets/erlang/emitter.py", line_prefix="%% ")


def _module_name(code: str) -> str:
    """Convert locale code to Erlang module suffix (lowercase, underscores for hyphens)."""
    return code.replace("-", "_")


def _quote(s: str) -> str:
    escaped = s.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def _str_list_12(items: list[str]) -> str:
    """Emit an Erlang list of 12 strings (months)."""
    return "[" + ", ".join(_quote(s) for s in items) + "]"


def _str_list_7(items: list[str]) -> str:
    """Emit an Erlang list of 7 strings (weekdays)."""
    return "[" + ", ".join(_quote(s) for s in items) + "]"


def _str_map(d: dict[str, str]) -> str:
    """Emit an Erlang proplist for day format exceptions."""
    if not d:
        return "[]"
    pairs = [f'{{{_quote(k)}, {_quote(v)}}}' for k, v in d.items()]
    return "[" + ", ".join(pairs) + "]"


def emit_locale(data: dict) -> str:
    """Generate an Erlang locale file from canonical JSON."""
    code = data["code"]
    mod = _module_name(code)

    lines = [HEADER + locale_source_comment(code, line_prefix="%% ")]
    lines.append(f"-module(sayabledate_locales_{mod}).")
    lines.append('-include("sayabledate.hrl").')
    lines.append("-export([locale/0]).")
    lines.append("")
    lines.append("locale() ->")
    lines.append("    #date_locale{")

    parts = []
    parts.append(f"        code = {_quote(code)}")
    parts.append(f"        months = {_str_list_12(data['months'])}")
    parts.append(f"        weekdays = {_str_list_7(data['weekdays'])}")
    parts.append(f"        day_format = {_quote(data['dayFormat'])}")

    exceptions = data.get("dayFormatExceptions", {})
    parts.append(f"        day_format_exceptions = {_str_map(exceptions)}")

    parts.append(f"        date_pattern = {_quote(data['datePattern'])}")
    parts.append(f"        date_pattern_with_year = {_quote(data['datePatternWithYear'])}")
    parts.append(f"        today = {_quote(data['today'])}")
    parts.append(f"        tomorrow = {_quote(data['tomorrow'])}")
    parts.append(f"        yesterday = {_quote(data['yesterday'])}")

    # Optional strings
    if "dayAfterTomorrow" in data:
        parts.append(f"        day_after_tomorrow = {{just, {_quote(data['dayAfterTomorrow'])}}}")
    else:
        parts.append("        day_after_tomorrow = nothing")

    if "dayBeforeYesterday" in data:
        parts.append(f"        day_before_yesterday = {{just, {_quote(data['dayBeforeYesterday'])}}}")
    else:
        parts.append("        day_before_yesterday = nothing")

    if "thisWeekday" in data:
        parts.append(f"        this_weekday = {{just, {_quote(data['thisWeekday'])}}}")
    else:
        parts.append("        this_weekday = nothing")

    if "nextWeekday" in data:
        parts.append(f"        next_weekday = {{just, {_quote(data['nextWeekday'])}}}")
    else:
        parts.append("        next_weekday = nothing")

    if "lastWeekday" in data:
        parts.append(f"        last_weekday = {{just, {_quote(data['lastWeekday'])}}}")
    else:
        parts.append("        last_weekday = nothing")

    # MonthsInDate (optional)
    if "monthsInDate" in data:
        parts.append(f"        months_in_date = {{just, {_str_list_12(data['monthsInDate'])}}}")
    else:
        parts.append("        months_in_date = nothing")

    # Short override
    if "short" in data:
        parts.append(f"        short = {{just, {_compactness_override(data['short'])}}}")
    else:
        parts.append("        short = nothing")

    # Compact override
    if "compact" in data:
        parts.append(f"        compact = {{just, {_compactness_override(data['compact'])}}}")
    else:
        parts.append("        compact = nothing")

    lines.append(",\n".join(parts))
    lines.append("    }.")
    lines.append("")

    return "\n".join(lines)


def _compactness_override(ovr: dict) -> str:
    parts = []
    if "months" in ovr:
        parts.append(f"months = {{just, {_str_list_12(ovr['months'])}}}")
    else:
        parts.append("months = nothing")

    if "monthsInDate" in ovr:
        parts.append(f"months_in_date = {{just, {_str_list_12(ovr['monthsInDate'])}}}")
    else:
        parts.append("months_in_date = nothing")

    if "weekdays" in ovr:
        parts.append(f"weekdays = {{just, {_str_list_7(ovr['weekdays'])}}}")
    else:
        parts.append("weekdays = nothing")

    if "dayFormat" in ovr:
        parts.append(f"day_format = {{just, {_quote(ovr['dayFormat'])}}}")
    else:
        parts.append("day_format = nothing")

    if "dayFormatExceptions" in ovr:
        parts.append(f"day_format_exceptions = {{just, {_str_map(ovr['dayFormatExceptions'])}}}")
    else:
        parts.append("day_format_exceptions = nothing")

    if "datePattern" in ovr:
        parts.append(f"date_pattern = {{just, {_quote(ovr['datePattern'])}}}")
    else:
        parts.append("date_pattern = nothing")

    if "datePatternWithYear" in ovr:
        parts.append(f"date_pattern_with_year = {{just, {_quote(ovr['datePatternWithYear'])}}}")
    else:
        parts.append("date_pattern_with_year = nothing")

    if "today" in ovr:
        parts.append(f"today = {{just, {_quote(ovr['today'])}}}")
    else:
        parts.append("today = nothing")

    if "tomorrow" in ovr:
        parts.append(f"tomorrow = {{just, {_quote(ovr['tomorrow'])}}}")
    else:
        parts.append("tomorrow = nothing")

    if "yesterday" in ovr:
        parts.append(f"yesterday = {{just, {_quote(ovr['yesterday'])}}}")
    else:
        parts.append("yesterday = nothing")

    return "#date_compactness_override{" + ", ".join(parts) + "}"


def emit_barrel(all_locales: list[dict]) -> str:
    """Generate the sayabledate_locales.erl barrel module."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER]
    lines.append("-module(sayabledate_locales).")
    lines.append('-include("sayabledate.hrl").')
    lines.append("-export([get_locale/1]).")
    lines.append("")

    for loc in sorted_locs:
        code = loc["code"]
        mod = _module_name(code)
        lines.append(f'get_locale({_quote(code)}) -> {{ok, sayabledate_locales_{mod}:locale()}};')

    lines.append("get_locale(_) -> error.")
    lines.append("")

    return "\n".join(lines)


def output_path(code: str, root: str) -> str:
    import os
    mod = _module_name(code)
    return os.path.join(root, "impl", "erlang", "src", "locales", f"sayabledate_locales_{mod}.erl")


def barrel_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "erlang", "src", "locales", "sayabledate_locales.erl")
