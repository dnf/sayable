"""F# locale emitter for sayable-time — single file with all locales."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header

HEADER = make_header("codegen/targets/fsharp/emitter.py")


def _quote(s: str) -> str:
    """Quote a string for F# using double quotes."""
    escaped = s.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def _str_array_12(items: list[str]) -> str:
    """Emit an F# array literal with 12 hour-name strings."""
    return "[| " + "; ".join(_quote(s) for s in items) + " |]"


def _patterns_map(patterns: dict[str, str]) -> str:
    """Emit an F# Map<int, string> for minute patterns."""
    keys = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55]
    pairs = []
    for key in keys:
        skey = str(key)
        if skey in patterns:
            pairs.append(f"({key}, {_quote(patterns[skey])})")
    return "Map.ofList [ " + "; ".join(pairs) + " ]"


def _clock_override(clock: dict, indent: str) -> list[str]:
    """Emit a ShortClockConfig for short/compact overrides."""
    lines = []
    use24h = "true" if clock.get("use24h", True) else "false"
    am_pm = clock.get("amPm")
    fmt = clock.get("format", "{h}:{mm}")

    lines.append(f"{indent}{{ Use24h = {use24h}")
    if am_pm:
        lines.append(f"{indent}  AmPm = Some ({_quote(am_pm[0])}, {_quote(am_pm[1])})")
    else:
        lines.append(f"{indent}  AmPm = None")
    lines.append(f"{indent}  Format = {_quote(fmt)} }}")

    return lines


def emit_all(all_locales: list[dict]) -> str:
    """Generate the single Locales.fs file with all time locales."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])

    lines = [HEADER]
    lines.append(f"/// All {len(all_locales)} locale definitions for sayable-time.")
    lines.append("module SayableTimeLib.Locales\n")
    lines.append("open SayableTimeLib.Types\n")

    for data in sorted_locs:
        code = data["code"]
        name = data["name"]
        uc = code.upper()
        clock = data["clock"]

        lines.append("")
        lines.append(f"{locale_source_comment(code).rstrip()}")
        lines.append("// ================================================================")
        lines.append(f"// {uc} — {name}")
        lines.append("// ================================================================")

        lines.append(f"let {uc}: TimeLocale =")
        lines.append("    {")
        lines.append(f"        Code = {_quote(code)}")

        # Clock config
        lines.append("        Clock =")
        lines.append("            {")
        lines.append(f"                Hours = {_str_array_12(clock['hours'])}")
        lines.append(f"                Midnight = {_quote(clock['midnight'])}")
        lines.append(f"                Noon = {_quote(clock['noon'])}")
        lines.append(f"                Patterns = {_patterns_map(clock['patterns'])}")
        lines.append("            }")

        # Short override
        has_short = "short" in data
        has_compact = "compact" in data

        if has_short:
            override_lines = _clock_override(data["short"]["clock"], "                ")
            lines.append("        ShortOverride =")
            lines.append("            Some")
            lines.append("                { Clock =")
            lines.append("                    Some")
            for ol in override_lines:
                lines.append(f"            {ol}")
            lines.append("                }")
        else:
            lines.append("        ShortOverride = None")

        if has_compact:
            override_lines = _clock_override(data["compact"]["clock"], "                ")
            lines.append("        CompactOverride =")
            lines.append("            Some")
            lines.append("                { Clock =")
            lines.append("                    Some")
            for ol in override_lines:
                lines.append(f"            {ol}")
            lines.append("                }")
        else:
            lines.append("        CompactOverride = None")

        lines.append("    }")

    # ALL map
    lines.append("")
    lines.append("let All: Map<string, TimeLocale> =")
    lines.append("    Map.ofList")
    lines.append("        [")
    for data in sorted_locs:
        code = data["code"]
        uc = code.upper()
        lines.append(f'            ("{code}", {uc})')
    lines.append("        ]")

    # Get function
    lines.append("")
    lines.append("let get (code: string) : TimeLocale option = Map.tryFind code All")
    lines.append("")

    return "\n".join(lines)


def output_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "fsharp", "SayableTime", "Locales", "Locales.fs")
