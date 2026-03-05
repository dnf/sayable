"""Java locale emitter for sayable-time — single file with all locales."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header

HEADER = make_header("codegen/targets/java/emitter.py")


def _quote(s: str) -> str:
    """Quote a string for Java using double quotes."""
    escaped = s.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def _str_list_12(items: list[str]) -> str:
    """Emit a Java List.of() with 12 hour-name strings."""
    return "List.of(" + ", ".join(_quote(s) for s in items) + ")"


def _patterns_map(patterns: dict[str, str]) -> str:
    """Emit a Java Map.of() for minute patterns."""
    keys = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55]
    pairs = []
    for key in keys:
        skey = str(key)
        if skey in patterns:
            pairs.append(f"{key}, {_quote(patterns[skey])}")
    # Map.of supports up to 10 entries; 12 entries need Map.ofEntries
    if len(pairs) > 10:
        entries = []
        for key in keys:
            skey = str(key)
            if skey in patterns:
                entries.append(f"Map.entry({key}, {_quote(patterns[skey])})")
        return "Map.ofEntries(" + ", ".join(entries) + ")"
    return "Map.of(" + ", ".join(pairs) + ")"


def _clock_override(clock: dict, indent: str) -> list[str]:
    """Emit a ShortClockConfig for short/compact overrides."""
    lines = []
    use24h = "true" if clock.get("use24h", True) else "false"
    am_pm = clock.get("amPm")
    fmt = clock.get("format", "{h}:{mm}")

    if am_pm:
        lines.append(f"{indent}new ShortClockConfig({use24h}, new String[]{{{_quote(am_pm[0])}, {_quote(am_pm[1])}}}, {_quote(fmt)})")
    else:
        lines.append(f"{indent}new ShortClockConfig({use24h}, null, {_quote(fmt)})")

    return lines


def emit_all(all_locales: list[dict]) -> str:
    """Generate the single Locales.java file with all time locales."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER, "package sayabletime.locales;\n"]
    lines.append("import java.util.List;")
    lines.append("import java.util.Map;")
    lines.append("import java.util.LinkedHashMap;")
    lines.append("import java.util.Collections;\n")
    lines.append("import sayabletime.*;\n")
    lines.append("/**")
    lines.append(f" * All {len(all_locales)} locale definitions for sayable-time.")
    lines.append(" */")
    lines.append("@SuppressWarnings({\"LineLength\", \"MethodLength\"})")
    lines.append("public final class Locales {\n")
    lines.append("    private Locales() {}")

    for i, data in enumerate(sorted_locs):
        code = data["code"]
        name = data["name"]
        uc = code.upper()

        lines.append("")
        lines.append(f"    {locale_source_comment(code).rstrip()}")
        lines.append("    // ================================================================")
        lines.append(f"    // {uc} — {name}")
        lines.append("    // ================================================================")

        clock = data["clock"]
        lines.append(f"    public static final TimeLocale {uc} = new TimeLocale(")
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
            clock_lines = _clock_override(data["short"]["clock"], "            ")
            lines.append(f"        new CompactnessOverride({clock_lines[0].strip()}),")
        else:
            lines.append("        null,")

        if has_compact:
            clock_lines = _clock_override(data["compact"]["clock"], "            ")
            lines.append(f"        new CompactnessOverride({clock_lines[0].strip()})")
        else:
            lines.append("        null")

        lines.append("    );")

    # ALL map
    lines.append("")
    lines.append("    public static final Map<String, TimeLocale> ALL;")
    lines.append("    static {")
    lines.append(f"        Map<String, TimeLocale> map = new LinkedHashMap<>({len(sorted_locs)});")
    for data in sorted_locs:
        code = data["code"]
        uc = code.upper()
        lines.append(f'        map.put("{code}", {uc});')
    lines.append("        ALL = Collections.unmodifiableMap(map);")
    lines.append("    }")

    # get() method
    lines.append("")
    lines.append("    public static TimeLocale get(String code) {")
    lines.append("        return ALL.get(code);")
    lines.append("    }")

    lines.append("}")
    lines.append("")

    return "\n".join(lines)


def output_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "java", "src", "main", "java", "sayabletime", "locales", "Locales.java")
