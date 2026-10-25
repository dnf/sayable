"""Bash locale emitter for sayable-time."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header

HEADER = make_header("codegen/targets/bash/emitter.py", line_prefix="# ")


def _quote(s: str) -> str:
    """Quote a string for Bash using single quotes with proper escaping."""
    return "'" + s.replace("'", "'\\''") + "'"


def emit_locale(data: dict) -> str:
    code = data["code"]
    clock = data["clock"]

    lines = [HEADER + locale_source_comment(code, line_prefix="# ")]

    # Locale data function that sets variables in the caller's scope
    lines.append(f"_sayabletime_locale_{code}() {{")

    # Hours array (12 entries, 0-indexed)
    hours_str = " ".join(_quote(h) for h in clock["hours"])
    lines.append(f"    _clock_hours=({hours_str})")

    # Special times
    lines.append(f"    _clock_midnight={_quote(clock['midnight'])}")
    lines.append(f"    _clock_noon={_quote(clock['noon'])}")

    # Patterns (keyed by minute bucket)
    for key in ["0", "5", "10", "15", "20", "25", "30", "35", "40", "45", "50", "55"]:
        if key in clock["patterns"]:
            lines.append(f"    _clock_pattern_{key}={_quote(clock['patterns'][key])}")

    # Short/compact overrides
    for mode in ("short", "compact"):
        if mode in data:
            sc = data[mode].get("clock", {})
            use24h = sc.get("use24h", True)
            fmt = sc.get("format", "{h}:{mm}")
            am_pm = sc.get("amPm")
            lines.append(f"    _{mode}_clock_use24h={'1' if use24h else '0'}")
            lines.append(f"    _{mode}_clock_format={_quote(fmt)}")
            if am_pm:
                lines.append(f"    _{mode}_clock_am={_quote(am_pm[0])}")
                lines.append(f"    _{mode}_clock_pm={_quote(am_pm[1])}")

    lines.append("}")
    lines.append("")

    return "\n".join(lines)


def emit_registry(all_locales: list[dict]) -> str:
    """Generate registry.sh with locale loading."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER]

    # Source all locale files
    lines.append("# Source all locale files relative to this script's directory")
    lines.append('_sayabletime_locales_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"')
    lines.append("")
    for loc in sorted_locs:
        code = loc["code"]
        lines.append(f'source "${{_sayabletime_locales_dir}}/{code}.sh"')
    lines.append("")

    # Registry: known locale codes
    codes = " ".join(loc["code"] for loc in sorted_locs)
    lines.append(f'_SAYABLETIME_LOCALES="{codes}"')
    lines.append("")

    # load_locale function
    lines.append("_sayabletime_load_locale() {")
    lines.append("    local code=\"$1\"")
    lines.append("    local known")
    lines.append("    for known in ${_SAYABLETIME_LOCALES}; do")
    lines.append("        if [ \"${known}\" = \"${code}\" ]; then")
    lines.append("            _sayabletime_locale_${code}")
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
