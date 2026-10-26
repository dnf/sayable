"""Kotlin locale emitter for sayable-time — single file with all locales."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header

HEADER = make_header("codegen/targets/kotlin/emitter.py")


def _quote(s: str) -> str:
    """Quote a string for Kotlin using double quotes."""
    escaped = s.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def _str_list_12(items: list[str]) -> str:
    """Emit a Kotlin listOf() with 12 hour-name strings."""
    return "listOf(" + ", ".join(_quote(s) for s in items) + ")"


def _patterns_map(patterns: dict[str, str]) -> str:
    """Emit a Kotlin mapOf() for minute patterns."""
    keys = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55]
    pairs = []
    for key in keys:
        skey = str(key)
        if skey in patterns:
            pairs.append(f"{key} to {_quote(patterns[skey])}")
    return "mapOf(" + ", ".join(pairs) + ")"


def _clock_override(clock: dict, indent: str) -> list[str]:
    """Emit a ShortClockConfig for short/compact overrides."""
    lines = []
    use24h = "true" if clock.get("use24h", True) else "false"
    am_pm = clock.get("amPm")
    fmt = clock.get("format", "{h}:{mm}")

    if am_pm:
        lines.append(f"{indent}clock = ShortClockConfig(use24h = {use24h}, amPm = Pair({_quote(am_pm[0])}, {_quote(am_pm[1])}), format = {_quote(fmt)}),")
    else:
        lines.append(f"{indent}clock = ShortClockConfig(use24h = {use24h}, format = {_quote(fmt)}),")

    return lines


def emit_all(all_locales: list[dict]) -> str:
    """Generate the single Locales.kt file with all time locales."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER, "package sayabletime.locales\n"]
    lines.append("import sayabletime.*\n")
    lines.append("/**")
    lines.append(f" * All {len(all_locales)} locale definitions for sayable-time.")
    lines.append(" */")
    lines.append("public object Locales {\n")

    for i, data in enumerate(sorted_locs):
        code = data["code"]
        name = data["name"]
        uc = code.upper()

        lines.append(f"    {locale_source_comment(code).rstrip()}")
        lines.append("    // ================================================================")
        lines.append(f"    // {uc} — {name}")
        lines.append("    // ================================================================")

        clock = data["clock"]
        # One builder function per locale keeps Locales.<clinit> under the
        # JVM's 64KB method size limit.
        builder = f"build{code.capitalize()}"
        lines.append(f"    public val {uc}: TimeLocale = {builder}()")
        lines.append("")
        lines.append(f"    private fun {builder}(): TimeLocale = TimeLocale(")
        lines.append(f"        code = {_quote(code)},")

        # Clock config
        lines.append("        clock = ClockConfig(")
        lines.append(f"            hours = {_str_list_12(clock['hours'])},")
        lines.append(f"            midnight = {_quote(clock['midnight'])},")
        lines.append(f"            noon = {_quote(clock['noon'])},")
        lines.append(f"            patterns = {_patterns_map(clock['patterns'])},")
        lines.append("        ),")

        # Short override
        if "short" in data:
            lines.append("        short = CompactnessOverride(")
            lines.extend(_clock_override(data["short"]["clock"], "            "))
            lines.append("        ),")

        # Compact override
        if "compact" in data:
            lines.append("        compact = CompactnessOverride(")
            lines.extend(_clock_override(data["compact"]["clock"], "            "))
            lines.append("        ),")

        lines.append("    )")

        if i < len(sorted_locs) - 1:
            lines.append("")

    # ALL map
    lines.append("")
    lines.append("    public val ALL: Map<String, TimeLocale> = mapOf(")
    entries = [f'{_quote(loc["code"])} to {loc["code"].upper()}' for loc in sorted_locs]
    for i in range(0, len(entries), 5):
        chunk = ", ".join(entries[i : i + 5])
        comma = "," if i + 5 < len(entries) else ""
        lines.append(f"        {chunk}{comma}")
    lines.append("    )")

    # get() method
    lines.append("")
    lines.append("    public fun get(code: String): TimeLocale? = ALL[code]")

    lines.append("}")
    lines.append("")

    return "\n".join(lines)


def output_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "kotlin", "src", "main", "kotlin", "sayabletime", "locales", "Locales.kt")
