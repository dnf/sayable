"""Python locale emitter for sayable-time."""

from __future__ import annotations

import keyword

from codegen.banner import locale_source_comment, make_header
from codegen.targets.python.layout import Group, Value, call, dict_of, layout, list_of, tuple_of

HEADER = make_header("codegen/targets/python/emitter.py", line_prefix="# ")


def _quote(s: str) -> str:
    """Quote a string for Python."""
    escaped = s.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


_PATTERN_MINUTES = ("0", "5", "10", "15", "20", "25", "30", "35", "40", "45", "50", "55")


def _str_list(items: list[str]) -> Group:
    """Emit a Python list of strings."""
    return list_of([_quote(s) for s in items])


def _clock_config(clock: dict) -> Group:
    patterns = dict_of(
        [(key, _quote(clock["patterns"][key])) for key in _PATTERN_MINUTES if key in clock["patterns"]],
        magic_trailing_comma=True,
    )
    fields: list[tuple[str, Value]] = [
        ("hours=", _str_list(clock["hours"])),
        ("midnight=", _quote(clock["midnight"])),
        ("noon=", _quote(clock["noon"])),
        ("patterns=", patterns),
    ]
    return call("ClockConfig", fields, magic_trailing_comma=True)


def _compactness_override(ovr: dict) -> Group:
    sc = ovr.get("clock", {})
    fields: list[tuple[str, Value]] = [
        ("use24h=", str(sc.get("use24h", True))),
        ("format=", _quote(sc.get("format", "{h}:{mm}"))),
    ]
    am_pm = sc.get("amPm")
    if am_pm:
        fields.append(("am_pm=", tuple_of([_quote(am_pm[0]), _quote(am_pm[1])])))
    return call("CompactnessOverride", [("clock=", call("ShortClockConfig", fields))], magic_trailing_comma=True)


def emit_locale(data: dict) -> str:
    """Generate a Python locale file from canonical JSON."""
    code = data["code"]
    name = data["name"]
    clock = data["clock"]
    lines = [HEADER + locale_source_comment(code, line_prefix="# "), f'"""{name} locale."""\n']

    # Determine imports
    imports = ["ClockConfig", "TimeLocale"]
    has_short = "short" in data
    has_compact = "compact" in data
    if has_short or has_compact:
        imports.append("CompactnessOverride")
        imports.append("ShortClockConfig")
    lines.append(f"from sayable_time.locale import {', '.join(sorted(imports))}")

    # Locale constant
    lines.append("")
    fields: list[tuple[str, Value]] = [
        ("code=", _quote(code)),
        ("clock=", _clock_config(clock)),
    ]
    if has_short:
        fields.append(("short=", _compactness_override(data["short"])))
    if has_compact:
        fields.append(("compact=", _compactness_override(data["compact"])))
    lines.extend(layout(call("TimeLocale", fields, magic_trailing_comma=True), head=f"{code.upper()} = "))
    lines.append("")

    return "\n".join(lines)


def emit_barrel(all_locales: list[dict]) -> str:
    """Generate the locales/__init__.py barrel file."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER, '"""Locale definitions for all supported languages."""\n']

    lines.append("import importlib")
    lines.append("")
    lines.append("from sayable_time.locale import TimeLocale")

    keyword_codes = []
    for loc in sorted_locs:
        code = loc["code"]
        if keyword.iskeyword(code):
            keyword_codes.append(code)
        else:
            lines.append(f"from sayable_time.locales.{code} import {code.upper()}")

    if keyword_codes:
        lines.append("")
        for code in keyword_codes:
            lines.append(
                f'{code.upper()} = importlib.import_module("sayable_time.locales.{code}").{code.upper()}'
            )

    lines.append("")

    # Lookup dict + function
    by_code = dict_of([(_quote(loc["code"]), loc["code"].upper()) for loc in sorted_locs], magic_trailing_comma=True)
    lines.extend(layout(by_code, head="_ALL: dict[str, TimeLocale] = "))
    lines.append("")
    lines.append("")
    lines.append("def get_locale(code: str) -> TimeLocale | None:")
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
    return os.path.join(root, "impl", "python", "src", "sayable_time", "locales", f"{code}.py")


def barrel_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "python", "src", "sayable_time", "locales", "__init__.py")
