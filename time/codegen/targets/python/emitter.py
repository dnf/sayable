"""Python locale emitter for sayable-time."""

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
    lines.append(f"{code.upper()} = TimeLocale(")
    lines.append(f"    code={_quote(code)},")

    # Clock config
    lines.append("    clock=ClockConfig(")
    lines.append(f"        hours={_str_list(clock['hours'])},")
    lines.append(f"        midnight={_quote(clock['midnight'])},")
    lines.append(f"        noon={_quote(clock['noon'])},")
    lines.append("        patterns={")
    for key in ["0", "5", "10", "15", "20", "25", "30", "35", "40", "45", "50", "55"]:
        if key in clock["patterns"]:
            lines.append(f"            {key}: {_quote(clock['patterns'][key])},")
    lines.append("        },")
    lines.append("    ),")

    # Short override
    if has_short:
        sc = data["short"].get("clock", {})
        use24h = sc.get("use24h", True)
        fmt = sc.get("format", "{h}:{mm}")
        am_pm = sc.get("amPm")
        if am_pm:
            lines.append("    short=CompactnessOverride(")
            lines.append(f"        clock=ShortClockConfig(use24h={use24h}, format={_quote(fmt)}, am_pm=({_quote(am_pm[0])}, {_quote(am_pm[1])})),")
            lines.append("    ),")
        else:
            lines.append("    short=CompactnessOverride(")
            lines.append(f"        clock=ShortClockConfig(use24h={use24h}, format={_quote(fmt)}),")
            lines.append("    ),")

    # Compact override
    if has_compact:
        sc = data["compact"].get("clock", {})
        use24h = sc.get("use24h", True)
        fmt = sc.get("format", "{h}:{mm}")
        am_pm = sc.get("amPm")
        if am_pm:
            lines.append("    compact=CompactnessOverride(")
            lines.append(f"        clock=ShortClockConfig(use24h={use24h}, format={_quote(fmt)}, am_pm=({_quote(am_pm[0])}, {_quote(am_pm[1])})),")
            lines.append("    ),")
        else:
            lines.append("    compact=CompactnessOverride(")
            lines.append(f"        clock=ShortClockConfig(use24h={use24h}, format={_quote(fmt)}),")
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
    lines.append("_ALL: dict[str, TimeLocale] = {")
    entries = [f'"{loc["code"]}": {loc["code"].upper()}' for loc in sorted_locs]
    for i in range(0, len(entries), 4):
        chunk = ", ".join(entries[i : i + 4])
        lines.append(f"    {chunk},")
    lines.append("}")
    lines.append("")
    lines.append("")
    lines.append("def get_locale(code: str) -> TimeLocale | None:")
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
    return os.path.join(root, "impl", "python", "src", "sayable_time", "locales", f"{code}.py")


def barrel_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "python", "src", "sayable_time", "locales", "__init__.py")
