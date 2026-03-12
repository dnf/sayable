"""Bash locale emitter for sayable-date."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header

HEADER = make_header("codegen/targets/bash/emitter.py", line_prefix="# ")


def _quote(s: str) -> str:
    """Quote a string for Bash using single quotes with proper escaping."""
    return "'" + s.replace("'", "'\\''") + "'"


def emit_locale(data: dict) -> str:
    code = data["code"]

    lines = [HEADER + locale_source_comment(code, line_prefix="# ")]

    # Locale data function that sets variables in the caller's scope
    lines.append(f"_locale_{code}() {{")

    # Months (0-indexed array)
    months_str = " ".join(_quote(m) for m in data["months"])
    lines.append(f"    _months=({months_str})")

    # Weekdays (0-indexed: Sunday=0)
    weekdays_str = " ".join(_quote(w) for w in data["weekdays"])
    lines.append(f"    _weekdays=({weekdays_str})")

    # Day format
    lines.append(f"    _day_format={_quote(data['dayFormat'])}")

    # Day format exceptions (as individual variables)
    if "dayFormatExceptions" in data:
        for key, val in sorted(data["dayFormatExceptions"].items()):
            lines.append(f"    _day_format_ex_{key}={_quote(val)}")

    # Date patterns
    lines.append(f"    _date_pattern={_quote(data['datePattern'])}")
    lines.append(f"    _date_pattern_with_year={_quote(data['datePatternWithYear'])}")

    # Proximity strings
    lines.append(f"    _today={_quote(data['today'])}")
    lines.append(f"    _tomorrow={_quote(data['tomorrow'])}")
    lines.append(f"    _yesterday={_quote(data['yesterday'])}")

    # Optional proximity strings
    if "dayAfterTomorrow" in data:
        lines.append(f"    _day_after_tomorrow={_quote(data['dayAfterTomorrow'])}")
    if "dayBeforeYesterday" in data:
        lines.append(f"    _day_before_yesterday={_quote(data['dayBeforeYesterday'])}")
    if "thisWeekday" in data:
        lines.append(f"    _this_weekday={_quote(data['thisWeekday'])}")
    if "nextWeekday" in data:
        lines.append(f"    _next_weekday={_quote(data['nextWeekday'])}")
    if "lastWeekday" in data:
        lines.append(f"    _last_weekday={_quote(data['lastWeekday'])}")

    # Months in date (genitive forms)
    if "monthsInDate" in data:
        mid_str = " ".join(_quote(m) for m in data["monthsInDate"])
        lines.append(f"    _months_in_date=({mid_str})")

    # Short/compact overrides
    for mode in ("short", "compact"):
        if mode in data:
            ovr = data[mode]
            if "months" in ovr:
                months_str = " ".join(_quote(m) for m in ovr["months"])
                lines.append(f"    _{mode}_months=({months_str})")
            if "weekdays" in ovr:
                weekdays_str = " ".join(_quote(w) for w in ovr["weekdays"])
                lines.append(f"    _{mode}_weekdays=({weekdays_str})")
            if "dayFormat" in ovr:
                lines.append(f"    _{mode}_day_format={_quote(ovr['dayFormat'])}")
            if "datePattern" in ovr:
                lines.append(f"    _{mode}_date_pattern={_quote(ovr['datePattern'])}")
            if "datePatternWithYear" in ovr:
                lines.append(f"    _{mode}_date_pattern_with_year={_quote(ovr['datePatternWithYear'])}")

    lines.append("}")
    lines.append("")

    return "\n".join(lines)


def emit_registry(all_locales: list[dict]) -> str:
    """Generate registry.sh with locale loading."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER]

    # Source all locale files
    lines.append("# Source all locale files relative to this script's directory")
    lines.append('_sayabledate_locales_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"')
    lines.append("")
    for loc in sorted_locs:
        code = loc["code"]
        lines.append(f'source "${{_sayabledate_locales_dir}}/{code}.sh"')
    lines.append("")

    # Registry: known locale codes
    codes = " ".join(loc["code"] for loc in sorted_locs)
    lines.append(f'_SAYABLEDATE_LOCALES="{codes}"')
    lines.append("")

    # load_locale function
    lines.append("_sayabledate_load_locale() {")
    lines.append("    local code=\"$1\"")
    lines.append("    local known")
    lines.append("    for known in ${_SAYABLEDATE_LOCALES}; do")
    lines.append("        if [ \"${known}\" = \"${code}\" ]; then")
    lines.append("            _locale_${code}")
    lines.append("            return 0")
    lines.append("        fi")
    lines.append("    done")
    lines.append("    return 1")
    lines.append("}")
    lines.append("")

    return "\n".join(lines)


def output_path(code: str, root: str) -> str:
    import os
    return os.path.join(root, "impl", "bash", "locales", f"{code}.sh")


def registry_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "bash", "locales", "registry.sh")
