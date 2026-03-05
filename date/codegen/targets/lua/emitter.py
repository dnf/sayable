"""Lua locale emitter for sayable-date."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header

HEADER = make_header("codegen/targets/lua/emitter.py", line_prefix="-- ")


def _quote(s: str) -> str:
    """Quote a string for Lua."""
    escaped = s.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def _str_list(items: list[str]) -> str:
    """Emit a Lua array of strings."""
    return "{ " + ", ".join(_quote(s) for s in items) + " }"


def _str_dict(d: dict[str, str]) -> str:
    """Emit a Lua table of string keys to string values."""
    pairs = [f'[{_quote(k)}] = {_quote(v)}' for k, v in d.items()]
    return "{ " + ", ".join(pairs) + " }"


def emit_locale(data: dict) -> str:
    """Generate a Lua locale file from canonical JSON."""
    code = data["code"]
    lines = [HEADER + locale_source_comment(code, line_prefix="-- ")]

    # Module table
    lines.append("local M = {}")
    lines.append("")
    lines.append(f"M.code = {_quote(code)}")

    # Months (1-indexed array)
    lines.append(f"M.months = {_str_list(data['months'])}")

    # Weekdays (1-indexed array, 1=Sunday in Lua)
    lines.append(f"M.weekdays = {_str_list(data['weekdays'])}")

    # Day format
    lines.append(f"M.day_format = {_quote(data['dayFormat'])}")

    # Day format exceptions
    if "dayFormatExceptions" in data and data["dayFormatExceptions"]:
        lines.append(f"M.day_format_exceptions = {_str_dict(data['dayFormatExceptions'])}")
    else:
        lines.append("M.day_format_exceptions = {}")

    # Date patterns
    lines.append(f"M.date_pattern = {_quote(data['datePattern'])}")
    lines.append(f"M.date_pattern_with_year = {_quote(data['datePatternWithYear'])}")

    # Proximity strings
    lines.append(f"M.today = {_quote(data['today'])}")
    lines.append(f"M.tomorrow = {_quote(data['tomorrow'])}")
    lines.append(f"M.yesterday = {_quote(data['yesterday'])}")

    # Optional proximity fields
    if "dayAfterTomorrow" in data:
        lines.append(f"M.day_after_tomorrow = {_quote(data['dayAfterTomorrow'])}")
    if "dayBeforeYesterday" in data:
        lines.append(f"M.day_before_yesterday = {_quote(data['dayBeforeYesterday'])}")
    if "thisWeekday" in data:
        lines.append(f"M.this_weekday = {_quote(data['thisWeekday'])}")
    if "nextWeekday" in data:
        lines.append(f"M.next_weekday = {_quote(data['nextWeekday'])}")
    if "lastWeekday" in data:
        lines.append(f"M.last_weekday = {_quote(data['lastWeekday'])}")
    if "monthsInDate" in data:
        lines.append(f"M.months_in_date = {_str_list(data['monthsInDate'])}")

    # Short/compact overrides
    for mode in ("short", "compact"):
        if mode in data:
            ovr = data[mode]
            lines.append(f"M.{mode} = {{")
            if "months" in ovr:
                lines.append(f"    months = {_str_list(ovr['months'])},")
            if "monthsInDate" in ovr:
                lines.append(f"    months_in_date = {_str_list(ovr['monthsInDate'])},")
            if "weekdays" in ovr:
                lines.append(f"    weekdays = {_str_list(ovr['weekdays'])},")
            if "dayFormat" in ovr:
                lines.append(f"    day_format = {_quote(ovr['dayFormat'])},")
            if "dayFormatExceptions" in ovr:
                lines.append(f"    day_format_exceptions = {_str_dict(ovr['dayFormatExceptions'])},")
            if "datePattern" in ovr:
                lines.append(f"    date_pattern = {_quote(ovr['datePattern'])},")
            if "datePatternWithYear" in ovr:
                lines.append(f"    date_pattern_with_year = {_quote(ovr['datePatternWithYear'])},")
            if "today" in ovr:
                lines.append(f"    today = {_quote(ovr['today'])},")
            if "tomorrow" in ovr:
                lines.append(f"    tomorrow = {_quote(ovr['tomorrow'])},")
            if "yesterday" in ovr:
                lines.append(f"    yesterday = {_quote(ovr['yesterday'])},")
            lines.append("}")

    lines.append("")
    lines.append("return M")
    lines.append("")

    return "\n".join(lines)


def emit_barrel(all_locales: list[dict]) -> str:
    """Generate the registry module that maps locale codes to modules."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER]
    lines.append("local M = {}")
    lines.append("")
    lines.append("local cache = {}")
    lines.append("")
    lines.append("function M.get_locale(code)")
    lines.append("    if cache[code] ~= nil then return cache[code] end")

    for loc in sorted_locs:
        code = loc["code"]
        lines.append(f'    if code == "{code}" then')
        lines.append(f'        cache[code] = require("locales.{code}")')
        lines.append(f"        return cache[code]")
        lines.append("    end")

    lines.append("    return nil")
    lines.append("end")
    lines.append("")
    lines.append("return M")
    lines.append("")

    return "\n".join(lines)


def output_path(code: str, root: str) -> str:
    import os
    return os.path.join(root, "impl", "lua", "locales", f"{code}.lua")


def barrel_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "lua", "locales", "init.lua")
