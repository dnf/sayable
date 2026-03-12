"""Mojo locale emitter for sayable-time."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header

HEADER = make_header("codegen/targets/mojo/emitter.py", line_prefix="# ")

_MOJO_RESERVED = {
    "alias", "and", "as", "async", "await", "break", "class", "continue",
    "def", "del", "elif", "else", "except", "finally", "fn", "for", "from",
    "global", "if", "import", "in", "is", "lambda", "let", "mut", "nonlocal",
    "not", "or", "pass", "raise", "return", "self", "struct", "trait", "try",
    "var", "while", "with", "yield",
}


def _safe_id(code: str) -> str:
    """Escape locale codes that are Mojo reserved keywords."""
    safe = code.replace("-", "_")
    if safe in _MOJO_RESERVED:
        return f"{safe}_locale"
    return safe


def _quote(s: str) -> str:
    escaped = s.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def emit_locale(data: dict) -> str:
    code = data["code"]
    name = data["name"]
    clock = data["clock"]

    lines = [HEADER + locale_source_comment(code, line_prefix="# ")]
    lines.append(f'"""{name} locale."""')
    lines.append("")
    lines.append("from ..locale import (")
    lines.append("    TimeLocale,")
    lines.append("    ClockConfig,")
    lines.append("    ShortClockConfig,")
    lines.append("    CompactnessOverride,")
    lines.append(")")
    lines.append("")
    lines.append("")

    lines.append(f"fn build_{_safe_id(code)}() -> TimeLocale:")
    lines.append(f'    """Build the {name} locale."""')

    # Clock config — hours (12 named fields)
    hours = clock["hours"]
    for i, h in enumerate(hours):
        lines.append(f"    var hour{i} = {_quote(h)}")

    lines.append(f"    var midnight = {_quote(clock['midnight'])}")
    lines.append(f"    var noon = {_quote(clock['noon'])}")

    # Patterns (12 five-minute buckets: 0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55)
    patterns = clock["patterns"]
    for bucket in (0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55):
        key = str(bucket)
        val = patterns.get(key, "")
        lines.append(f"    var pattern{bucket} = {_quote(val)}")

    lines.append("")
    lines.append("    var clock = ClockConfig(")
    for i in range(12):
        lines.append(f"        hour{i}=hour{i},")
    lines.append("        midnight=midnight,")
    lines.append("        noon=noon,")
    for bucket in (0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55):
        lines.append(f"        pattern{bucket}=pattern{bucket},")
    lines.append("    )")

    # Short/compact overrides
    for mode in ("short", "compact"):
        if mode in data:
            ovr = data[mode]
            if "clock" in ovr:
                sc = ovr["clock"]
                use24h = "True" if sc.get("use24h", False) else "False"
                fmt = _quote(sc.get("format", ""))
                am_pm = sc.get("amPm")
                if am_pm:
                    lines.append("")
                    lines.append(f"    var {mode}_clock = ShortClockConfig(")
                    lines.append(f"        use24h={use24h},")
                    lines.append(f"        format={fmt},")
                    lines.append(f"        has_am_pm=True,")
                    lines.append(f"        am={_quote(am_pm[0])},")
                    lines.append(f"        pm={_quote(am_pm[1])},")
                    lines.append("    )")
                else:
                    lines.append("")
                    lines.append(f"    var {mode}_clock = ShortClockConfig(")
                    lines.append(f"        use24h={use24h},")
                    lines.append(f"        format={fmt},")
                    lines.append("    )")
                lines.append(f"    var {mode}_ovr = CompactnessOverride()")
                lines.append(f"    {mode}_ovr.clock = {mode}_clock")
                lines.append(f"    {mode}_ovr.has_clock = True")

    lines.append("")
    lines.append("    return TimeLocale(")
    lines.append(f"        code={_quote(code)},")
    lines.append("        clock=clock,")
    for mode in ("short", "compact"):
        if mode in data and "clock" in data[mode]:
            lines.append(f"        {mode}_override={mode}_ovr,")
            lines.append(f"        has_{mode}=True,")
    lines.append("    )")
    lines.append("")

    return "\n".join(lines)


def emit_registry(all_locales: list[dict]) -> str:
    """Generate the registry.mojo file."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER]
    lines.append('"""Locale registry for all supported languages."""')
    lines.append("")
    lines.append("from ..locale import TimeLocale")

    for loc in sorted_locs:
        code = loc["code"]
        lines.append(f"from .{_safe_id(code)} import build_{_safe_id(code)}")
    lines.append("")
    lines.append("")

    lines.append("fn get_locale(code: String) -> TimeLocale:")
    lines.append('    """Look up a locale by its code string.')
    lines.append("")
    lines.append("    Returns the locale if found, or the English locale as fallback.")
    lines.append('    """')
    for loc in sorted_locs:
        code = loc["code"]
        lines.append(f'    if code == {_quote(code)}:')
        lines.append(f"        return build_{_safe_id(code)}()")
    lines.append("    return build_en()")
    lines.append("")
    lines.append("")
    lines.append("fn has_locale(code: String) -> Bool:")
    lines.append('    """Check if a locale code is known."""')
    for loc in sorted_locs:
        code = loc["code"]
        lines.append(f'    if code == {_quote(code)}:')
        lines.append("        return True")
    lines.append("    return False")
    lines.append("")

    return "\n".join(lines)


def output_path(code: str, root: str) -> str:
    import os
    return os.path.join(root, "impl", "mojo", "src", "sayable_time", "locales", f"{_safe_id(code)}.mojo")


def registry_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "mojo", "src", "sayable_time", "locales", "registry.mojo")
