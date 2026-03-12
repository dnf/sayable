"""Wren locale emitter for sayable-time."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header

HEADER = make_header("codegen/targets/wren/emitter.py", line_prefix="// ")


def _quote(s: str) -> str:
    """Quote a string for Wren."""
    escaped = s.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def _str_list(items: list[str]) -> str:
    """Emit a Wren list of strings on one line."""
    return "[" + ", ".join(_quote(s) for s in items) + "]"


def emit_locale(data: dict) -> str:
    """Generate a Wren locale file from canonical JSON."""
    code = data["code"]
    clock = data["clock"]

    lines = [HEADER + locale_source_comment(code, line_prefix="// ")]

    class_name = code.upper().replace("-", "_") + "Locale"
    lines.append(f"class {class_name} {{")
    lines.append(f"  static code {{ {_quote(code)} }}")

    # Clock config
    lines.append("  static clock {")
    lines.append("    return {")
    lines.append(f'      "hours": {_str_list(clock["hours"])},')
    lines.append(f'      "midnight": {_quote(clock["midnight"])},')
    lines.append(f'      "noon": {_quote(clock["noon"])},')
    lines.append('      "patterns": {')
    for key in ["0", "5", "10", "15", "20", "25", "30", "35", "40", "45", "50", "55"]:
        if key in clock["patterns"]:
            lines.append(f'        {key}: {_quote(clock["patterns"][key])},')
    lines.append("      },")
    lines.append("    }")
    lines.append("  }")

    # Short override
    if "short" in data:
        sc = data["short"].get("clock", {})
        use24h = "true" if sc.get("use24h", True) else "false"
        fmt = sc.get("format", "{h}:{mm}")
        am_pm = sc.get("amPm")
        lines.append("  static short {")
        lines.append("    return {")
        lines.append('      "clock": {')
        lines.append(f'        "use24h": {use24h},')
        lines.append(f'        "format": {_quote(fmt)},')
        if am_pm:
            lines.append(f'        "amPm": [{_quote(am_pm[0])}, {_quote(am_pm[1])}],')
        lines.append("      },")
        lines.append("    }")
        lines.append("  }")

    # Compact override
    if "compact" in data:
        sc = data["compact"].get("clock", {})
        use24h = "true" if sc.get("use24h", True) else "false"
        fmt = sc.get("format", "{h}:{mm}")
        am_pm = sc.get("amPm")
        lines.append("  static compact {")
        lines.append("    return {")
        lines.append('      "clock": {')
        lines.append(f'        "use24h": {use24h},')
        lines.append(f'        "format": {_quote(fmt)},')
        if am_pm:
            lines.append(f'        "amPm": [{_quote(am_pm[0])}, {_quote(am_pm[1])}],')
        lines.append("      },")
        lines.append("    }")
        lines.append("  }")

    lines.append("}")
    lines.append("")

    return "\n".join(lines)


def emit_barrel(all_locales: list[dict]) -> str:
    """Generate the registry module that maps locale codes to locale classes."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER]

    for loc in sorted_locs:
        code = loc["code"]
        class_name = code.upper().replace("-", "_") + "Locale"
        lines.append(f'import "./{code}" for {class_name}')

    lines.append("")
    lines.append("class LocaleRegistry {")
    lines.append("  static getLocale(code) {")

    for loc in sorted_locs:
        code = loc["code"]
        class_name = code.upper().replace("-", "_") + "Locale"
        lines.append(f'    if (code == {_quote(code)}) return {class_name}')

    lines.append("    return null")
    lines.append("  }")
    lines.append("}")
    lines.append("")

    return "\n".join(lines)


def output_path(code: str, root: str) -> str:
    import os
    return os.path.join(root, "impl", "wren", "locales", f"{code}.wren")


def barrel_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "wren", "locales", "registry.wren")
