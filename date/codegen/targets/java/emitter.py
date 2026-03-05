"""Java locale emitter for sayable-date — single file with all locales."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header

HEADER = make_header("codegen/targets/java/emitter.py")


def _quote(s: str) -> str:
    escaped = s.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def _str_list(items: list[str]) -> str:
    """Emit a Java List.of(...) literal on one line."""
    return "List.of(" + ", ".join(_quote(s) for s in items) + ")"


def _str_map(d: dict[str, str]) -> str:
    """Emit a Java Map.of(...) literal on one line."""
    if not d:
        return "Map.of()"
    pairs = []
    for k, v in d.items():
        pairs.append(f"{_quote(k)}, {_quote(v)}")
    if len(d) > 10:
        entries = [f"Map.entry({_quote(k)}, {_quote(v)})" for k, v in d.items()]
        return "Map.ofEntries(" + ", ".join(entries) + ")"
    return "Map.of(" + ", ".join(pairs) + ")"


def _emit_compactness_override(ovr: dict, indent: str) -> list[str]:
    """Emit a CompactnessOverride constructor call fields."""
    lines = []
    # Order matches the CompactnessOverride constructor:
    # months, monthsInDate, weekdays, dayFormat, dayFormatExceptions,
    # datePattern, datePatternWithYear, today, tomorrow, yesterday
    fields = []
    fields.append(_str_list(ovr["months"]) if "months" in ovr else "null")
    fields.append(_str_list(ovr["monthsInDate"]) if "monthsInDate" in ovr else "null")
    fields.append(_str_list(ovr["weekdays"]) if "weekdays" in ovr else "null")
    fields.append(_quote(ovr["dayFormat"]) if "dayFormat" in ovr else "null")
    fields.append(_str_map(ovr["dayFormatExceptions"]) if "dayFormatExceptions" in ovr else "null")
    fields.append(_quote(ovr["datePattern"]) if "datePattern" in ovr else "null")
    fields.append(_quote(ovr["datePatternWithYear"]) if "datePatternWithYear" in ovr else "null")
    fields.append(_quote(ovr["today"]) if "today" in ovr else "null")
    fields.append(_quote(ovr["tomorrow"]) if "tomorrow" in ovr else "null")
    fields.append(_quote(ovr["yesterday"]) if "yesterday" in ovr else "null")

    for j, field in enumerate(fields):
        comma = "," if j < len(fields) - 1 else ""
        lines.append(f"{indent}    {field}{comma}")
    return lines


def emit_all(all_locales: list[dict]) -> str:
    """Generate the single Locales.java file with all date locales."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER, "package sayabledate.locales;\n"]
    lines.append("import java.util.List;")
    lines.append("import java.util.Map;")
    lines.append("import java.util.LinkedHashMap;")
    lines.append("import java.util.Collections;\n")
    lines.append("import sayabledate.*;\n")
    lines.append("/**")
    lines.append(f" * All {len(all_locales)} locale definitions for sayable-date.")
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

        lines.append(f"    public static final DateLocale {uc} = new DateLocale(")
        lines.append(f"        {_quote(code)},")
        lines.append(f"        {_str_list(data['months'])},")
        lines.append(f"        {_str_list(data['weekdays'])},")
        lines.append(f"        {_quote(data['dayFormat'])},")

        # dayFormatExceptions
        exceptions = data.get("dayFormatExceptions", {})
        lines.append(f"        {_str_map(exceptions)},")

        # Date patterns
        lines.append(f"        {_quote(data['datePattern'])},")
        lines.append(f"        {_quote(data['datePatternWithYear'])},")

        # Required strings
        lines.append(f"        {_quote(data['today'])},")
        lines.append(f"        {_quote(data['tomorrow'])},")
        lines.append(f"        {_quote(data['yesterday'])},")

        # Optional strings
        lines.append(f"        {_quote(data['dayAfterTomorrow']) if 'dayAfterTomorrow' in data else 'null'},")
        lines.append(f"        {_quote(data['dayBeforeYesterday']) if 'dayBeforeYesterday' in data else 'null'},")
        lines.append(f"        {_quote(data['thisWeekday']) if 'thisWeekday' in data else 'null'},")
        lines.append(f"        {_quote(data['nextWeekday']) if 'nextWeekday' in data else 'null'},")
        lines.append(f"        {_quote(data['lastWeekday']) if 'lastWeekday' in data else 'null'},")
        lines.append(f"        {_str_list(data['monthsInDate']) if 'monthsInDate' in data else 'null'},")

        # Short/compact overrides
        has_short = "short" in data
        has_compact = "compact" in data

        if has_short:
            lines.append("        new CompactnessOverride(")
            lines.extend(_emit_compactness_override(data["short"], "        "))
            lines.append("        ),")
        else:
            lines.append("        null,")

        if has_compact:
            lines.append("        new CompactnessOverride(")
            lines.extend(_emit_compactness_override(data["compact"], "        "))
            lines.append("        )")
        else:
            lines.append("        null")

        lines.append("    );")

    # ALL map
    lines.append("")
    lines.append("    public static final Map<String, DateLocale> ALL;")
    lines.append("    static {")
    lines.append(f"        Map<String, DateLocale> map = new LinkedHashMap<>({len(sorted_locs)});")
    for data in sorted_locs:
        code = data["code"]
        uc = code.upper()
        lines.append(f'        map.put("{code}", {uc});')
    lines.append("        ALL = Collections.unmodifiableMap(map);")
    lines.append("    }")

    # get() method
    lines.append("")
    lines.append("    public static DateLocale get(String code) {")
    lines.append("        return ALL.get(code);")
    lines.append("    }")

    lines.append("}")
    lines.append("")

    return "\n".join(lines)


def output_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "java", "src", "main", "java", "sayabledate", "locales", "Locales.java")
