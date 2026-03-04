"""Kotlin locale emitter — single file with all locales for sayable-date."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header

HEADER = make_header("codegen/targets/kotlin/emitter.py")


def _quote(s: str) -> str:
    escaped = s.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def _str_list(items: list[str]) -> str:
    """Emit a Kotlin listOf(...) literal on one line."""
    return "listOf(" + ", ".join(_quote(s) for s in items) + ")"


def _str_map(d: dict[str, str]) -> str:
    """Emit a Kotlin mapOf(...) literal on one line."""
    if not d:
        return "emptyMap()"
    pairs = [f"{_quote(k)} to {_quote(v)}" for k, v in d.items()]
    return "mapOf(" + ", ".join(pairs) + ")"


def _emit_compactness_override(ovr: dict, indent: str) -> list[str]:
    """Emit a CompactnessOverride constructor call."""
    lines = []
    if "months" in ovr:
        lines.append(f"{indent}    months = {_str_list(ovr['months'])},")
    if "monthsInDate" in ovr:
        lines.append(f"{indent}    monthsInDate = {_str_list(ovr['monthsInDate'])},")
    if "weekdays" in ovr:
        lines.append(f"{indent}    weekdays = {_str_list(ovr['weekdays'])},")
    if "dayFormat" in ovr:
        lines.append(f"{indent}    dayFormat = {_quote(ovr['dayFormat'])},")
    if "dayFormatExceptions" in ovr:
        lines.append(f"{indent}    dayFormatExceptions = {_str_map(ovr['dayFormatExceptions'])},")
    if "datePattern" in ovr:
        lines.append(f"{indent}    datePattern = {_quote(ovr['datePattern'])},")
    if "datePatternWithYear" in ovr:
        lines.append(f"{indent}    datePatternWithYear = {_quote(ovr['datePatternWithYear'])},")
    if "today" in ovr:
        lines.append(f"{indent}    today = {_quote(ovr['today'])},")
    if "tomorrow" in ovr:
        lines.append(f"{indent}    tomorrow = {_quote(ovr['tomorrow'])},")
    if "yesterday" in ovr:
        lines.append(f"{indent}    yesterday = {_quote(ovr['yesterday'])},")
    return lines


def emit_all(all_locales: list[dict]) -> str:
    """Generate the single Locales.kt file with all locales."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER, "package sayabledate.locales\n"]
    lines.append("import sayabledate.*\n")
    lines.append("/**")
    lines.append(f" * All {len(all_locales)} locale definitions for sayable-date.")
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

        lines.append(f"    public val {uc}: DateLocale = DateLocale(")
        lines.append(f"        code = {_quote(code)},")
        lines.append(f"        months = {_str_list(data['months'])},")
        lines.append(f"        weekdays = {_str_list(data['weekdays'])},")
        lines.append(f"        dayFormat = {_quote(data['dayFormat'])},")

        # dayFormatExceptions
        exceptions = data.get("dayFormatExceptions", {})
        lines.append(f"        dayFormatExceptions = {_str_map(exceptions)},")

        # Date patterns
        lines.append(f"        datePattern = {_quote(data['datePattern'])},")
        lines.append(f"        datePatternWithYear = {_quote(data['datePatternWithYear'])},")

        # Required strings
        lines.append(f"        today = {_quote(data['today'])},")
        lines.append(f"        tomorrow = {_quote(data['tomorrow'])},")
        lines.append(f"        yesterday = {_quote(data['yesterday'])},")

        # Optional strings
        if "dayAfterTomorrow" in data:
            lines.append(f"        dayAfterTomorrow = {_quote(data['dayAfterTomorrow'])},")
        if "dayBeforeYesterday" in data:
            lines.append(f"        dayBeforeYesterday = {_quote(data['dayBeforeYesterday'])},")
        if "thisWeekday" in data:
            lines.append(f"        thisWeekday = {_quote(data['thisWeekday'])},")
        if "nextWeekday" in data:
            lines.append(f"        nextWeekday = {_quote(data['nextWeekday'])},")
        if "lastWeekday" in data:
            lines.append(f"        lastWeekday = {_quote(data['lastWeekday'])},")
        if "monthsInDate" in data:
            lines.append(f"        monthsInDate = {_str_list(data['monthsInDate'])},")

        # Short override
        if "short" in data:
            ovr = data["short"]
            lines.append("        short = CompactnessOverride(")
            lines.extend(_emit_compactness_override(ovr, "        "))
            lines.append("        ),")

        # Compact override
        if "compact" in data:
            ovr = data["compact"]
            lines.append("        compact = CompactnessOverride(")
            lines.extend(_emit_compactness_override(ovr, "        "))
            lines.append("        ),")

        lines.append("    )")

        if i < len(sorted_locs) - 1:
            lines.append("")

    # ALL map
    lines.append("")
    lines.append("    public val ALL: Map<String, DateLocale> = mapOf(")
    entries = [f'"{loc["code"]}" to {loc["code"].upper()}' for loc in sorted_locs]
    for i in range(0, len(entries), 5):
        chunk = ", ".join(entries[i : i + 5])
        comma = "," if i + 5 < len(entries) else ""
        lines.append(f"        {chunk}{comma}")
    lines.append("    )")

    # get() method
    lines.append("")
    lines.append("    public fun get(code: String): DateLocale? = ALL[code]")

    lines.append("}")
    lines.append("")

    return "\n".join(lines)


def output_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "kotlin", "src", "main", "kotlin", "sayabledate", "locales", "Locales.kt")
