"""F# locale emitter — single file with all locales for sayable-date."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header

HEADER = make_header("codegen/targets/fsharp/emitter.py")


def _quote(s: str) -> str:
    escaped = s.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def _str_array(items: list[str]) -> str:
    """Emit an F# array literal."""
    return "[| " + "; ".join(_quote(s) for s in items) + " |]"


def _str_map(d: dict[str, str]) -> str:
    """Emit an F# Map<string, string>."""
    if not d:
        return "Map.empty"
    pairs = [f"({_quote(k)}, {_quote(v)})" for k, v in d.items()]
    return "Map.ofList [ " + "; ".join(pairs) + " ]"


def _nullable_str(value: str | None) -> str:
    if value is None:
        return "None"
    return f"Some {_quote(value)}"


def _emit_compactness_override(ovr: dict, indent: str) -> list[str]:
    """Emit a CompactnessOverride record fields."""
    lines: list[str] = []

    # months
    if "months" in ovr:
        lines.append(f"{indent}    Months = Some {_str_array(ovr['months'])}")
    else:
        lines.append(f"{indent}    Months = None")

    # monthsInDate
    if "monthsInDate" in ovr:
        lines.append(f"{indent}    MonthsInDate = Some {_str_array(ovr['monthsInDate'])}")
    else:
        lines.append(f"{indent}    MonthsInDate = None")

    # weekdays
    if "weekdays" in ovr:
        lines.append(f"{indent}    Weekdays = Some {_str_array(ovr['weekdays'])}")
    else:
        lines.append(f"{indent}    Weekdays = None")

    # dayFormat
    if "dayFormat" in ovr:
        lines.append(f"{indent}    DayFormat = Some {_quote(ovr['dayFormat'])}")
    else:
        lines.append(f"{indent}    DayFormat = None")

    # dayFormatExceptions
    if "dayFormatExceptions" in ovr:
        lines.append(f"{indent}    DayFormatExceptions = Some ({_str_map(ovr['dayFormatExceptions'])})")
    else:
        lines.append(f"{indent}    DayFormatExceptions = None")

    # datePattern
    if "datePattern" in ovr:
        lines.append(f"{indent}    DatePattern = Some {_quote(ovr['datePattern'])}")
    else:
        lines.append(f"{indent}    DatePattern = None")

    # datePatternWithYear
    if "datePatternWithYear" in ovr:
        lines.append(f"{indent}    DatePatternWithYear = Some {_quote(ovr['datePatternWithYear'])}")
    else:
        lines.append(f"{indent}    DatePatternWithYear = None")

    # today
    if "today" in ovr:
        lines.append(f"{indent}    Today = Some {_quote(ovr['today'])}")
    else:
        lines.append(f"{indent}    Today = None")

    # tomorrow
    if "tomorrow" in ovr:
        lines.append(f"{indent}    Tomorrow = Some {_quote(ovr['tomorrow'])}")
    else:
        lines.append(f"{indent}    Tomorrow = None")

    # yesterday
    if "yesterday" in ovr:
        lines.append(f"{indent}    Yesterday = Some {_quote(ovr['yesterday'])}")
    else:
        lines.append(f"{indent}    Yesterday = None")

    return lines


def emit_all(all_locales: list[dict]) -> str:
    """Generate the single Locales.fs file with all locales."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])

    lines = [HEADER]
    lines.append(f"/// All {len(all_locales)} locale definitions for sayable-date.")
    lines.append("module SayableDateLib.Locales\n")
    lines.append("open SayableDateLib.Types\n")

    # Emit locale constants
    for data in sorted_locs:
        code = data["code"]
        name = data["name"]
        uc = code.upper()

        lines.append("")
        lines.append(f"{locale_source_comment(code).rstrip()}")
        lines.append("// ================================================================")
        lines.append(f"// {uc} — {name}")
        lines.append("// ================================================================")

        lines.append(f"let {uc}: DateLocale =")
        lines.append("    {")
        lines.append(f"        Code = {_quote(code)}")

        # months
        lines.append(f"        Months = {_str_array(data['months'])}")

        # weekdays
        lines.append(f"        Weekdays = {_str_array(data['weekdays'])}")

        # dayFormat
        lines.append(f"        DayFormat = {_quote(data['dayFormat'])}")

        # dayFormatExceptions
        exceptions = data.get("dayFormatExceptions", {})
        lines.append(f"        DayFormatExceptions = {_str_map(exceptions)}")

        # datePattern
        lines.append(f"        DatePattern = {_quote(data['datePattern'])}")

        # datePatternWithYear
        lines.append(f"        DatePatternWithYear = {_quote(data['datePatternWithYear'])}")

        # today, tomorrow, yesterday
        lines.append(f"        Today = {_quote(data['today'])}")
        lines.append(f"        Tomorrow = {_quote(data['tomorrow'])}")
        lines.append(f"        Yesterday = {_quote(data['yesterday'])}")

        # Optional strings
        lines.append(f"        DayAfterTomorrow = {_nullable_str(data.get('dayAfterTomorrow'))}")
        lines.append(f"        DayBeforeYesterday = {_nullable_str(data.get('dayBeforeYesterday'))}")
        lines.append(f"        ThisWeekday = {_nullable_str(data.get('thisWeekday'))}")
        lines.append(f"        NextWeekday = {_nullable_str(data.get('nextWeekday'))}")
        lines.append(f"        LastWeekday = {_nullable_str(data.get('lastWeekday'))}")

        # monthsInDate
        if "monthsInDate" in data:
            lines.append(f"        MonthsInDate = Some {_str_array(data['monthsInDate'])}")
        else:
            lines.append("        MonthsInDate = None")

        # Short override
        if "short" in data:
            lines.append("        ShortOverride =")
            lines.append("            Some")
            lines.append("                {")
            lines.extend(_emit_compactness_override(data["short"], "            "))
            lines.append("                }")
        else:
            lines.append("        ShortOverride = None")

        # Compact override
        if "compact" in data:
            lines.append("        CompactOverride =")
            lines.append("            Some")
            lines.append("                {")
            lines.extend(_emit_compactness_override(data["compact"], "            "))
            lines.append("                }")
        else:
            lines.append("        CompactOverride = None")

        lines.append("    }")

    # ALL map
    lines.append("")
    lines.append("let All: Map<string, DateLocale> =")
    lines.append("    Map.ofList")
    lines.append("        [")
    for data in sorted_locs:
        code = data["code"]
        uc = code.upper()
        lines.append(f'            ("{code}", {uc})')
    lines.append("        ]")

    # Get function
    lines.append("")
    lines.append("let get (code: string) : DateLocale option = Map.tryFind code All")
    lines.append("")

    return "\n".join(lines)


def output_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "fsharp", "SayableDate", "Locales", "Locales.fs")
