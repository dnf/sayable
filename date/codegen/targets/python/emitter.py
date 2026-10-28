"""Python locale emitter for sayable-date."""

from __future__ import annotations

import keyword

from codegen.banner import locale_source_comment, make_header
from codegen.targets.python.layout import Group, Value, call, dict_of, layout, list_of

HEADER = make_header("codegen/targets/python/emitter.py", line_prefix="# ")


def _quote(s: str) -> str:
    """Quote a string for Python."""
    escaped = s.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def _str_list(items: list[str]) -> Group:
    """Emit a Python list of strings."""
    return list_of([_quote(s) for s in items])


def _dict_str(d: dict[str, str]) -> Group:
    """Emit a Python dict of str→str."""
    return dict_of([(_quote(k), _quote(v)) for k, v in d.items()])


def _short_override(ovr: dict) -> Group:
    fields: list[tuple[str, Value]] = []
    if "months" in ovr:
        fields.append(("months=", _str_list(ovr["months"])))
    if "weekdays" in ovr:
        fields.append(("weekdays=", _str_list(ovr["weekdays"])))
    if "dayFormat" in ovr:
        fields.append(("day_format=", _quote(ovr["dayFormat"])))
    if "datePattern" in ovr:
        fields.append(("date_pattern=", _quote(ovr["datePattern"])))
    if "datePatternWithYear" in ovr:
        fields.append(("date_pattern_with_year=", _quote(ovr["datePatternWithYear"])))
    return call("CompactnessOverride", fields, magic_trailing_comma=True)


def _compact_override(ovr: dict) -> Group:
    fields: list[tuple[str, Value]] = []
    if "datePattern" in ovr:
        fields.append(("date_pattern=", _quote(ovr["datePattern"])))
    if "datePatternWithYear" in ovr:
        fields.append(("date_pattern_with_year=", _quote(ovr["datePatternWithYear"])))
    return call("CompactnessOverride", fields, magic_trailing_comma=True)


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
    fields: list[tuple[str, Value]] = [
        ("code=", _quote(code)),
        ("months=", _str_list(data["months"])),
        ("weekdays=", _str_list(data["weekdays"])),
        ("day_format=", _quote(data["dayFormat"])),
        ("day_format_exceptions=", _dict_str(data.get("dayFormatExceptions", {}))),
        ("date_pattern=", _quote(data["datePattern"])),
        ("date_pattern_with_year=", _quote(data["datePatternWithYear"])),
        ("today=", _quote(data["today"])),
        ("tomorrow=", _quote(data["tomorrow"])),
        ("yesterday=", _quote(data["yesterday"])),
    ]
    if "dayAfterTomorrow" in data:
        fields.append(("day_after_tomorrow=", _quote(data["dayAfterTomorrow"])))
    if "dayBeforeYesterday" in data:
        fields.append(("day_before_yesterday=", _quote(data["dayBeforeYesterday"])))
    if "thisWeekday" in data:
        fields.append(("this_weekday=", _quote(data["thisWeekday"])))
    if "nextWeekday" in data:
        fields.append(("next_weekday=", _quote(data["nextWeekday"])))
    if "lastWeekday" in data:
        fields.append(("last_weekday=", _quote(data["lastWeekday"])))
    if "monthsInDate" in data:
        fields.append(("months_in_date=", _str_list(data["monthsInDate"])))
    if has_short:
        fields.append(("short=", _short_override(data["short"])))
    if has_compact:
        fields.append(("compact=", _compact_override(data["compact"])))
    lines.extend(layout(call("DateLocale", fields, magic_trailing_comma=True), head=f"{code.upper()} = "))
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
    by_code = dict_of([(_quote(loc["code"]), loc["code"].upper()) for loc in sorted_locs], magic_trailing_comma=True)
    lines.extend(layout(by_code, head="_ALL: dict[str, DateLocale] = "))
    lines.append("")
    lines.append("")
    lines.append("def get_locale(code: str) -> DateLocale | None:")
    lines.append('    """Look up a locale by its code string."""')
    lines.append("    return _ALL.get(code)")
    lines.append("")
    lines.append("")

    exported = [_quote(loc["code"].upper()) for loc in sorted_locs] + ['"get_locale"']
    lines.extend(layout(list_of(exported, magic_trailing_comma=True), head="__all__ = "))
    lines.append("")

    return "\n".join(lines)


def output_path(code: str, root: str) -> str:
    import os
    return os.path.join(root, "impl", "python", "src", "sayable_date", "locales", f"{code}.py")


def barrel_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "python", "src", "sayable_date", "locales", "__init__.py")
