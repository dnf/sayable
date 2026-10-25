"""Groovy locale emitter for sayable-time — single file with all locales."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header

HEADER = make_header("codegen/targets/groovy/emitter.py")


def _quote(s: str) -> str:
    escaped = s.replace("\\", "\\\\").replace("'", "\\'")
    return f"'{escaped}'"


def _str_list_12(items: list[str]) -> str:
    """Emit a Groovy list with 12 hour-name strings."""
    return "[" + ", ".join(_quote(s) for s in items) + "]"


def _patterns_map(patterns: dict[str, str]) -> str:
    """Emit a Groovy map for minute patterns."""
    keys = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55]
    pairs = []
    for key in keys:
        skey = str(key)
        if skey in patterns:
            pairs.append(f"({key}): {_quote(patterns[skey])}")
    return "[" + ", ".join(pairs) + "]"


def _clock_override(clock: dict) -> str:
    """Emit a ShortClockConfig for short/compact overrides."""
    use24h = "true" if clock.get("use24h", True) else "false"
    am_pm = clock.get("amPm")
    fmt = clock.get("format", "{h}:{mm}")

    if am_pm:
        return f"new ShortClockConfig({use24h}, [{_quote(am_pm[0])}, {_quote(am_pm[1])}] as String[], {_quote(fmt)})"
    return f"new ShortClockConfig({use24h}, null, {_quote(fmt)})"


def emit_all(all_locales: list[dict]) -> str:
    """Generate the single Locales.groovy file with all time locales.

    Each locale is built in its own private static factory method, and the
    ALL map by one helper per first letter, so <clinit> stays under the
    JVM's 64KB method size limit.
    """
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER, "package sayabletime.locales\n"]
    lines.append("import sayabletime.*\n")
    lines.append("/**")
    lines.append(f" * All {len(all_locales)} locale definitions for sayable-time.")
    lines.append(" */")
    lines.append("class Locales {\n")

    for i, data in enumerate(sorted_locs):
        code = data["code"]
        name = data["name"]
        uc = code.upper()

        lines.append(f"    {locale_source_comment(code).rstrip()}")
        lines.append("    // ================================================================")
        lines.append(f"    // {uc} — {name}")
        lines.append("    // ================================================================")

        clock = data["clock"]
        lines.append(f"    static final TimeLocale {uc} = _{code}()")
        lines.append("")
        lines.append(f"    private static TimeLocale _{code}() {{")
        body_start = len(lines)
        lines.append("    new TimeLocale(")
        lines.append(f"        {_quote(code)},")

        # Clock config
        lines.append("        new ClockConfig(")
        lines.append(f"            {_str_list_12(clock['hours'])},")
        lines.append(f"            {_quote(clock['midnight'])},")
        lines.append(f"            {_quote(clock['noon'])},")
        lines.append(f"            {_patterns_map(clock['patterns'])}")
        lines.append("        ),")

        # Short override
        has_short = "short" in data
        has_compact = "compact" in data

        if has_short:
            ovr_str = _clock_override(data["short"]["clock"])
            lines.append(f"        new CompactnessOverride({ovr_str}),")
        else:
            lines.append("        null,")

        if has_compact:
            ovr_str = _clock_override(data["compact"]["clock"])
            lines.append(f"        new CompactnessOverride({ovr_str})")
        else:
            lines.append("        null")

        lines.append("    )")
        lines[body_start:] = ["    " + line if line else line for line in lines[body_start:]]
        lines.append("    }")

        if i < len(sorted_locs) - 1:
            lines.append("")

    # ALL map, built by one helper method per first letter
    groups: dict[str, list[dict]] = {}
    for loc in sorted_locs:
        groups.setdefault(loc["code"][0].upper(), []).append(loc)

    for letter, locs in groups.items():
        lines.append("")
        lines.append(f"    private static Map<String, TimeLocale> _locales{letter}() {{")
        lines.append("        [")
        entries = [f"({_quote(loc['code'])}): {loc['code'].upper()}" for loc in locs]
        for k in range(0, len(entries), 3):
            chunk = ", ".join(entries[k : k + 3])
            comma = "," if k + 3 < len(entries) else ""
            lines.append(f"            {chunk}{comma}")
        lines.append("        ]")
        lines.append("    }")

    lines.append("")
    group_calls = " + ".join(f"_locales{letter}()" for letter in groups)
    lines.append(f"    static final Map<String, TimeLocale> ALL = Collections.unmodifiableMap({group_calls})")

    # get() method
    lines.append("")
    lines.append("    static TimeLocale get(String code) { ALL[code] }")

    lines.append("}")
    lines.append("")

    return "\n".join(lines)


def output_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "groovy", "src", "main", "groovy", "sayabletime", "locales", "Locales.groovy")
