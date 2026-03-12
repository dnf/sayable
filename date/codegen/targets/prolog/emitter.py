"""Prolog locale emitter for sayable-date."""

from __future__ import annotations

import os

from codegen.banner import locale_source_comment, make_header

HEADER = make_header("codegen/targets/prolog/emitter.py", line_prefix="% ")


def _quote(s: str) -> str:
    """Quote a string as a Prolog atom using single quotes."""
    escaped = s.replace("\\", "\\\\").replace("'", "\\'")
    return f"'{escaped}'"


def _list(items: list[str]) -> str:
    """Emit a Prolog list of quoted atoms."""
    return "[" + ", ".join(_quote(s) for s in items) + "]"


def emit_locale(data: dict) -> str:
    """Generate a Prolog locale file from canonical JSON."""
    code = data["code"]
    name = data["name"]

    lines = [HEADER + locale_source_comment(code, line_prefix="% ")]
    lines.append(f"% {name} locale.\n")

    # Months
    lines.append(f"sd_months({_quote(code)}, {_list(data['months'])}).")

    # Weekdays
    lines.append(f"sd_weekdays({_quote(code)}, {_list(data['weekdays'])}).")

    # Day format
    lines.append(f"sd_day_format({_quote(code)}, {_quote(data['dayFormat'])}).")

    # Day format exceptions
    if "dayFormatExceptions" in data and data["dayFormatExceptions"]:
        for key, val in sorted(data["dayFormatExceptions"].items(), key=lambda x: int(x[0])):
            lines.append(f"sd_day_format_exception({_quote(code)}, {_quote(key)}, {_quote(val)}).")
    lines.append("")

    # Date patterns
    lines.append(f"sd_date_pattern({_quote(code)}, {_quote(data['datePattern'])}).")
    lines.append(f"sd_date_pattern_with_year({_quote(code)}, {_quote(data['datePatternWithYear'])}).")
    lines.append("")

    # Proximity strings
    lines.append(f"sd_today({_quote(code)}, {_quote(data['today'])}).")
    lines.append(f"sd_tomorrow({_quote(code)}, {_quote(data['tomorrow'])}).")
    lines.append(f"sd_yesterday({_quote(code)}, {_quote(data['yesterday'])}).")

    if "dayAfterTomorrow" in data:
        lines.append(f"sd_day_after_tomorrow({_quote(code)}, {_quote(data['dayAfterTomorrow'])}).")
    if "dayBeforeYesterday" in data:
        lines.append(f"sd_day_before_yesterday({_quote(code)}, {_quote(data['dayBeforeYesterday'])}).")
    if "thisWeekday" in data:
        lines.append(f"sd_this_weekday({_quote(code)}, {_quote(data['thisWeekday'])}).")
    if "nextWeekday" in data:
        lines.append(f"sd_next_weekday({_quote(code)}, {_quote(data['nextWeekday'])}).")
    if "lastWeekday" in data:
        lines.append(f"sd_last_weekday({_quote(code)}, {_quote(data['lastWeekday'])}).")

    # Months in date (genitive forms)
    if "monthsInDate" in data:
        lines.append(f"sd_months_in_date({_quote(code)}, {_list(data['monthsInDate'])}).")
    lines.append("")

    # Short override
    if "short" in data:
        ovr = data["short"]
        if "months" in ovr:
            lines.append(f"short_sd_months({_quote(code)}, {_list(ovr['months'])}).")
        if "weekdays" in ovr:
            lines.append(f"short_sd_weekdays({_quote(code)}, {_list(ovr['weekdays'])}).")
        if "dayFormat" in ovr:
            lines.append(f"short_sd_day_format({_quote(code)}, {_quote(ovr['dayFormat'])}).")
            # If short has dayFormat but no dayFormatExceptions, clear exceptions
            if "dayFormatExceptions" not in ovr:
                lines.append(f"short_sd_clear_exceptions({_quote(code)}).")
        if "dayFormatExceptions" in ovr:
            for key, val in sorted(ovr["dayFormatExceptions"].items(), key=lambda x: int(x[0])):
                lines.append(f"short_sd_day_format_exception({_quote(code)}, {_quote(key)}, {_quote(val)}).")
        if "datePattern" in ovr:
            lines.append(f"short_sd_date_pattern({_quote(code)}, {_quote(ovr['datePattern'])}).")
        if "datePatternWithYear" in ovr:
            lines.append(f"short_sd_date_pattern_with_year({_quote(code)}, {_quote(ovr['datePatternWithYear'])}).")
        lines.append("")

    # Compact override
    if "compact" in data:
        ovr = data["compact"]
        if "datePattern" in ovr:
            lines.append(f"compact_sd_date_pattern({_quote(code)}, {_quote(ovr['datePattern'])}).")
        if "datePatternWithYear" in ovr:
            lines.append(f"compact_sd_date_pattern_with_year({_quote(code)}, {_quote(ovr['datePatternWithYear'])}).")
        lines.append("")

    return "\n".join(lines)


def emit_barrel(all_locales: list[dict]) -> str:
    """Generate the locales/registry.pl barrel file."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER, "% Locale registry — loads all locale files.\n"]

    # Discontiguous declarations
    lines.append(":- discontiguous sd_months/2.")
    lines.append(":- discontiguous sd_weekdays/2.")
    lines.append(":- discontiguous sd_day_format/2.")
    lines.append(":- discontiguous sd_day_format_exception/3.")
    lines.append(":- discontiguous sd_date_pattern/2.")
    lines.append(":- discontiguous sd_date_pattern_with_year/2.")
    lines.append(":- discontiguous sd_today/2.")
    lines.append(":- discontiguous sd_tomorrow/2.")
    lines.append(":- discontiguous sd_yesterday/2.")
    lines.append(":- discontiguous sd_day_after_tomorrow/2.")
    lines.append(":- discontiguous sd_day_before_yesterday/2.")
    lines.append(":- discontiguous sd_this_weekday/2.")
    lines.append(":- discontiguous sd_next_weekday/2.")
    lines.append(":- discontiguous sd_last_weekday/2.")
    lines.append(":- discontiguous sd_months_in_date/2.")
    lines.append(":- discontiguous short_sd_months/2.")
    lines.append(":- discontiguous short_sd_weekdays/2.")
    lines.append(":- discontiguous short_sd_day_format/2.")
    lines.append(":- discontiguous short_sd_clear_exceptions/1.")
    lines.append(":- discontiguous short_sd_day_format_exception/3.")
    lines.append(":- discontiguous short_sd_date_pattern/2.")
    lines.append(":- discontiguous short_sd_date_pattern_with_year/2.")
    lines.append(":- discontiguous compact_sd_date_pattern/2.")
    lines.append(":- discontiguous compact_sd_date_pattern_with_year/2.")
    lines.append("")

    # Include all locale files
    for loc in sorted_locs:
        code = loc["code"]
        lines.append(f":- include('{code}').")

    lines.append("")

    # sd_locale/1: succeeds if code is known
    lines.append("% sd_locale(+Code) - succeeds if Code is a known locale.")
    for loc in sorted_locs:
        lines.append(f"sd_locale({_quote(loc['code'])}).")
    lines.append("")

    return "\n".join(lines)


def output_path(code: str, root: str) -> str:
    return os.path.join(root, "impl", "prolog", "locales", f"{code}.pl")


def barrel_path(root: str) -> str:
    return os.path.join(root, "impl", "prolog", "locales", "registry.pl")
