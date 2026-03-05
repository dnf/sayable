"""Scala locale emitter — single file with all locales for sayable-date.

Splits locales into private batch objects to avoid the JVM 64KB method limit,
then delegates from the public Locales object.
"""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header

HEADER = make_header("codegen/targets/scala/emitter.py")

# Split locales into batches to keep each <clinit> under the 64KB JVM limit
_BATCH_SIZE = 18


def _quote(s: str) -> str:
    escaped = s.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def _str_list(items: list[str]) -> str:
    """Emit a Scala List(...) literal on one line."""
    return "List(" + ", ".join(_quote(s) for s in items) + ")"


def _str_map(d: dict[str, str]) -> str:
    """Emit a Scala Map(...) literal on one line."""
    if not d:
        return "Map.empty"
    pairs = [f"{_quote(k)} -> {_quote(v)}" for k, v in d.items()]
    return "Map(" + ", ".join(pairs) + ")"


def _emit_compactness_override(ovr: dict, indent: str) -> list[str]:
    """Emit a CompactnessOverride constructor call."""
    lines = []
    if "months" in ovr:
        lines.append(f"{indent}    months = Some({_str_list(ovr['months'])}),")
    if "monthsInDate" in ovr:
        lines.append(f"{indent}    monthsInDate = Some({_str_list(ovr['monthsInDate'])}),")
    if "weekdays" in ovr:
        lines.append(f"{indent}    weekdays = Some({_str_list(ovr['weekdays'])}),")
    if "dayFormat" in ovr:
        lines.append(f"{indent}    dayFormat = Some({_quote(ovr['dayFormat'])}),")
    if "dayFormatExceptions" in ovr:
        lines.append(f"{indent}    dayFormatExceptions = Some({_str_map(ovr['dayFormatExceptions'])}),")
    if "datePattern" in ovr:
        lines.append(f"{indent}    datePattern = Some({_quote(ovr['datePattern'])}),")
    if "datePatternWithYear" in ovr:
        lines.append(f"{indent}    datePatternWithYear = Some({_quote(ovr['datePatternWithYear'])}),")
    if "today" in ovr:
        lines.append(f"{indent}    today = Some({_quote(ovr['today'])}),")
    if "tomorrow" in ovr:
        lines.append(f"{indent}    tomorrow = Some({_quote(ovr['tomorrow'])}),")
    if "yesterday" in ovr:
        lines.append(f"{indent}    yesterday = Some({_quote(ovr['yesterday'])}),")
    return lines


def _emit_locale(data: dict, indent: str) -> list[str]:
    """Emit a single locale val declaration."""
    lines = []
    code = data["code"]
    name = data["name"]
    uc = code.upper()

    lines.append(f"{indent}{locale_source_comment(code).rstrip()}")
    lines.append(f"{indent}// ================================================================")
    lines.append(f"{indent}// {uc} — {name}")
    lines.append(f"{indent}// ================================================================")

    lines.append(f"{indent}val {uc}: DateLocale = DateLocale(")
    lines.append(f"{indent}    code = {_quote(code)},")
    lines.append(f"{indent}    months = {_str_list(data['months'])},")
    lines.append(f"{indent}    weekdays = {_str_list(data['weekdays'])},")
    lines.append(f"{indent}    dayFormat = {_quote(data['dayFormat'])},")

    # dayFormatExceptions
    exceptions = data.get("dayFormatExceptions", {})
    lines.append(f"{indent}    dayFormatExceptions = {_str_map(exceptions)},")

    # Date patterns
    lines.append(f"{indent}    datePattern = {_quote(data['datePattern'])},")
    lines.append(f"{indent}    datePatternWithYear = {_quote(data['datePatternWithYear'])},")

    # Required strings
    lines.append(f"{indent}    today = {_quote(data['today'])},")
    lines.append(f"{indent}    tomorrow = {_quote(data['tomorrow'])},")
    lines.append(f"{indent}    yesterday = {_quote(data['yesterday'])},")

    # Optional strings
    if "dayAfterTomorrow" in data:
        lines.append(f"{indent}    dayAfterTomorrow = Some({_quote(data['dayAfterTomorrow'])}),")
    if "dayBeforeYesterday" in data:
        lines.append(f"{indent}    dayBeforeYesterday = Some({_quote(data['dayBeforeYesterday'])}),")
    if "thisWeekday" in data:
        lines.append(f"{indent}    thisWeekday = Some({_quote(data['thisWeekday'])}),")
    if "nextWeekday" in data:
        lines.append(f"{indent}    nextWeekday = Some({_quote(data['nextWeekday'])}),")
    if "lastWeekday" in data:
        lines.append(f"{indent}    lastWeekday = Some({_quote(data['lastWeekday'])}),")
    if "monthsInDate" in data:
        lines.append(f"{indent}    monthsInDate = Some({_str_list(data['monthsInDate'])}),")

    # Short override
    if "short" in data:
        ovr = data["short"]
        lines.append(f"{indent}    short = Some(CompactnessOverride(")
        lines.extend(_emit_compactness_override(ovr, indent + "    "))
        lines.append(f"{indent}    )),")

    # Compact override
    if "compact" in data:
        ovr = data["compact"]
        lines.append(f"{indent}    compact = Some(CompactnessOverride(")
        lines.extend(_emit_compactness_override(ovr, indent + "    "))
        lines.append(f"{indent}    )),")

    lines.append(f"{indent})")
    return lines


def emit_all(all_locales: list[dict]) -> str:
    """Generate the single Locales.scala file with all locales."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER, "package sayabledate.locales\n"]
    lines.append("import sayabledate._\n")
    lines.append("/**")
    lines.append(f" * All {len(all_locales)} locale definitions for sayable-date.")
    lines.append(" */")

    # Split into batches
    batches: list[list[dict]] = []
    for i in range(0, len(sorted_locs), _BATCH_SIZE):
        batches.append(sorted_locs[i : i + _BATCH_SIZE])

    # Emit private batch objects
    for bi, batch in enumerate(batches):
        lines.append(f"private object Batch{bi} {{")
        for j, data in enumerate(batch):
            lines.extend(_emit_locale(data, "    "))
            if j < len(batch) - 1:
                lines.append("")
        lines.append("}")
        lines.append("")

    # Emit public Locales object with delegating vals
    lines.append("object Locales {\n")
    for bi, batch in enumerate(batches):
        for data in batch:
            uc = data["code"].upper()
            lines.append(f"    val {uc}: DateLocale = Batch{bi}.{uc}")
    lines.append("")

    # ALL map
    lines.append("    val ALL: Map[String, DateLocale] = Map(")
    entries = [f'"{loc["code"]}" -> {loc["code"].upper()}' for loc in sorted_locs]
    for i in range(0, len(entries), 5):
        chunk = ", ".join(entries[i : i + 5])
        comma = "," if i + 5 < len(entries) else ""
        lines.append(f"        {chunk}{comma}")
    lines.append("    )")

    # get() method
    lines.append("")
    lines.append("    def get(code: String): Option[DateLocale] = ALL.get(code)")

    lines.append("}")
    lines.append("")

    return "\n".join(lines)


def output_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "scala", "src", "main", "scala", "sayabledate", "locales", "Locales.scala")
