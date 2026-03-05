"""Python locale emitter for sayable-date."""

from __future__ import annotations

import keyword

from codegen.banner import locale_source_comment, make_header

HEADER = make_header("codegen/targets/python/emitter.py", line_prefix="# ")


def _quote(s: str) -> str:
    """Quote a string for Python."""
    escaped = s.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def _str_list(items: list[str]) -> str:
    """Emit a Python list of strings on one line."""
    return "[" + ", ".join(_quote(s) for s in items) + "]"


def _dict_str(d: dict[str, str]) -> str:
    """Emit a Python dict of str→str on one line."""
    pairs = [f"{_quote(k)}: {_quote(v)}" for k, v in d.items()]
    return "{" + ", ".join(pairs) + "}"


def emit_locale(data: dict) -> str:
    """Generate a Python locale file from canonical JSON."""
    code = data["code"]
    name = data["name"]
    lines = [HEADER + locale_source_comment(code, line_prefix="# "), f'"""{name} locale."""\n']

    # Imports
    imports = ["DateLocale"]
    has_short = "short" in data
    has_compact = "compact" in data
    if has_short or has_compact:
        imports.append("CompactnessOverride")
    lines.append(f"from sayable_date.locale import {', '.join(sorted(imports))}")

    # Locale constant
    lines.append("")
    lines.append(f"{code.upper()} = DateLocale(")
    lines.append(f"    code={_quote(code)},")
    lines.append(f"    months={_str_list(data['months'])},")
    lines.append(f"    weekdays={_str_list(data['weekdays'])},")
    lines.append(f"    day_format={_quote(data['dayFormat'])},")

    if "dayFormatExceptions" in data:
        lines.append(f"    day_format_exceptions={_dict_str(data['dayFormatExceptions'])},")
    else:
        lines.append("    day_format_exceptions={},")

    lines.append(f"    date_pattern={_quote(data['datePattern'])},")
    lines.append(f"    date_pattern_with_year={_quote(data['datePatternWithYear'])},")
    lines.append(f"    today={_quote(data['today'])},")
    lines.append(f"    tomorrow={_quote(data['tomorrow'])},")
    lines.append(f"    yesterday={_quote(data['yesterday'])},")

    if "dayAfterTomorrow" in data:
        lines.append(f"    day_after_tomorrow={_quote(data['dayAfterTomorrow'])},")
    if "dayBeforeYesterday" in data:
        lines.append(f"    day_before_yesterday={_quote(data['dayBeforeYesterday'])},")
    if "thisWeekday" in data:
        lines.append(f"    this_weekday={_quote(data['thisWeekday'])},")
    if "nextWeekday" in data:
        lines.append(f"    next_weekday={_quote(data['nextWeekday'])},")
    if "lastWeekday" in data:
        lines.append(f"    last_weekday={_quote(data['lastWeekday'])},")
    if "monthsInDate" in data:
        lines.append(f"    months_in_date={_str_list(data['monthsInDate'])},")

    # Short override
    if has_short:
        ovr = data["short"]
        parts = []
        if "months" in ovr:
            parts.append(f"        months={_str_list(ovr['months'])},")
        if "weekdays" in ovr:
            parts.append(f"        weekdays={_str_list(ovr['weekdays'])},")
        if "dayFormat" in ovr:
            parts.append(f"        day_format={_quote(ovr['dayFormat'])},")
        if "datePattern" in ovr:
            parts.append(f"        date_pattern={_quote(ovr['datePattern'])},")
        if "datePatternWithYear" in ovr:
            parts.append(f"        date_pattern_with_year={_quote(ovr['datePatternWithYear'])},")
        lines.append("    short=CompactnessOverride(")
        lines.extend(parts)
        lines.append("    ),")

    # Compact override
    if has_compact:
        ovr = data["compact"]
        parts = []
        if "datePattern" in ovr:
            parts.append(f"        date_pattern={_quote(ovr['datePattern'])},")
        if "datePatternWithYear" in ovr:
            parts.append(f"        date_pattern_with_year={_quote(ovr['datePatternWithYear'])},")
        lines.append("    compact=CompactnessOverride(")
        lines.extend(parts)
        lines.append("    ),")

    lines.append(")")
    lines.append("")

    return "\n".join(lines)


def emit_barrel(all_locales: list[dict]) -> str:
    """Generate the locales/__init__.py barrel file."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER, '"""Locale definitions for all supported languages."""\n']

    lines.append("import importlib")
    lines.append("")
    lines.append("from sayable_date.locale import DateLocale")

    keyword_codes = []
    for loc in sorted_locs:
        code = loc["code"]
        if keyword.iskeyword(code):
            keyword_codes.append(code)
        else:
            lines.append(f"from sayable_date.locales.{code} import {code.upper()}")

    if keyword_codes:
        lines.append("")
        for code in keyword_codes:
            lines.append(
                f'{code.upper()} = importlib.import_module("sayable_date.locales.{code}").{code.upper()}'
            )

    lines.append("")

    # Lookup dict + function
    lines.append("_ALL: dict[str, DateLocale] = {")
    entries = [f'"{loc["code"]}": {loc["code"].upper()}' for loc in sorted_locs]
    for i in range(0, len(entries), 4):
        chunk = ", ".join(entries[i : i + 4])
        lines.append(f"    {chunk},")
    lines.append("}")
    lines.append("")
    lines.append("")
    lines.append("def get_locale(code: str) -> DateLocale | None:")
    lines.append('    """Look up a locale by its code string."""')
    lines.append("    return _ALL.get(code)")
    lines.append("")

    lines.append("__all__ = [")
    codes = [f'"{loc["code"].upper()}"' for loc in sorted_locs]
    for i in range(0, len(codes), 8):
        chunk = ", ".join(codes[i : i + 8])
        lines.append(f"    {chunk},")
    lines.append('    "get_locale",')
    lines.append("]")
    lines.append("")

    return "\n".join(lines)


def output_path(code: str, root: str) -> str:
    import os
    return os.path.join(root, "impl", "python", "src", "sayable_date", "locales", f"{code}.py")


def barrel_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "python", "src", "sayable_date", "locales", "__init__.py")
