"""V locale emitter for sayable-time.

V requires module names to match directory names and doesn't support
importing parent modules from subdirectories. Generated locale files
live in a `locales/` subdirectory with `module locales`. Type definitions
are duplicated in `locales/types.v` to avoid circular imports.

The main formatter in the parent directory provides the public API
and formatter logic.
"""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header

HEADER = make_header("codegen/targets/v/emitter.py", line_prefix="// ")


def _quote(s: str) -> str:
    """Quote a string for V."""
    escaped = s.replace("\\", "\\\\").replace("'", "\\'")
    return f"'{escaped}'"


def _str_array(items: list[str]) -> str:
    """Emit a V fixed-size array literal."""
    return "[" + ", ".join(_quote(s) for s in items) + "]!"


def emit_locale(data: dict) -> str:
    """Generate a V locale file from canonical JSON."""
    code = data["code"]
    name = data["name"]
    safe_code = code.replace("-", "_")
    clock = data["clock"]

    lines = [HEADER + locale_source_comment(code, line_prefix="// ")]
    lines.append(f"// {name} locale.")
    lines.append("module locales\n")

    # Locale constant
    lines.append(f"pub const locale_{safe_code} = TimeLocale{{")
    lines.append(f"\tcode: {_quote(code)}")

    # Clock config
    lines.append("\tclock: ClockConfig{")
    lines.append(f"\t\thours: {_str_array(clock['hours'])}")
    lines.append(f"\t\tmidnight: {_quote(clock['midnight'])}")
    lines.append(f"\t\tnoon: {_quote(clock['noon'])}")

    # Patterns map
    pattern_pairs = []
    for key in ("0", "5", "10", "15", "20", "25", "30", "35", "40", "45", "50", "55"):
        if key in clock["patterns"]:
            pattern_pairs.append(f"\t\t\t{key}: {_quote(clock['patterns'][key])}")
    lines.append("\t\tpatterns: {")
    lines.extend(pattern_pairs)
    lines.append("\t\t}")
    lines.append("\t}")

    # Short override
    if "short" in data:
        sc = data["short"].get("clock", {})
        use24h = "true" if sc.get("use24h", True) else "false"
        fmt = _quote(sc.get("format", "{h}:{mm}"))
        am_pm = sc.get("amPm")
        parts = [f"\t\t\tuse24h: {use24h}", f"\t\t\tformat: {fmt}"]
        if am_pm:
            parts.append(f"\t\t\tam: {_quote(am_pm[0])}")
            parts.append(f"\t\t\tpm: {_quote(am_pm[1])}")
            parts.append("\t\t\thas_am_pm: true")
        lines.append("\thas_short: true")
        lines.append("\tshort_override: TimeCompactnessOverride{")
        lines.append("\t\tclock: ShortClockConfig{")
        lines.extend(parts)
        lines.append("\t\t}")
        lines.append("\t}")

    # Compact override
    if "compact" in data:
        sc = data["compact"].get("clock", {})
        use24h = "true" if sc.get("use24h", True) else "false"
        fmt = _quote(sc.get("format", "{h}:{mm}"))
        am_pm = sc.get("amPm")
        parts = [f"\t\t\tuse24h: {use24h}", f"\t\t\tformat: {fmt}"]
        if am_pm:
            parts.append(f"\t\t\tam: {_quote(am_pm[0])}")
            parts.append(f"\t\t\tpm: {_quote(am_pm[1])}")
            parts.append("\t\t\thas_am_pm: true")
        lines.append("\thas_compact: true")
        lines.append("\tcompact_override: TimeCompactnessOverride{")
        lines.append("\t\tclock: ShortClockConfig{")
        lines.extend(parts)
        lines.append("\t\t}")
        lines.append("\t}")

    lines.append("}")
    lines.append("")

    return "\n".join(lines)


def emit_barrel(all_locales: list[dict]) -> str:
    """Generate registry.v with get_time_locale function."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER]
    lines.append("// Locale registry for all supported languages.")
    lines.append("module locales\n")

    lines.append("pub fn get_time_locale(code string) ?TimeLocale {")
    lines.append("\treturn match code {")
    for loc in sorted_locs:
        code = loc["code"]
        safe_code = code.replace("-", "_")
        lines.append(f"\t\t{_quote(code)} {{ locale_{safe_code} }}")
    lines.append("\t\telse { none }")
    lines.append("\t}")
    lines.append("}")
    lines.append("")

    return "\n".join(lines)


def output_path(code: str, root: str) -> str:
    import os
    return os.path.join(root, "impl", "v", "locales", f"locale_{code.replace('-', '_')}.v")


def barrel_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "v", "locales", "registry.v")
