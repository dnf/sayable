"""C# locale emitter — single file with all locales for sayable-date."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header

HEADER = make_header("codegen/targets/csharp/emitter.py")


def _quote(s: str) -> str:
    escaped = s.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def _str_array(items: list[str]) -> str:
    """Emit a C# array initializer on one line."""
    return "new[] { " + ", ".join(_quote(s) for s in items) + " }"


def _str_dict(d: dict[str, str]) -> str:
    """Emit a C# Dictionary initializer on one line."""
    if not d:
        return "new Dictionary<string, string>()"
    pairs = [f"{{ {_quote(k)}, {_quote(v)} }}" for k, v in d.items()]
    return "new Dictionary<string, string> { " + ", ".join(pairs) + " }"


def _nullable_str(value: str | None) -> str:
    if value is None:
        return "null"
    return _quote(value)


def _emit_compactness_override(ovr: dict, indent: str) -> list[str]:
    """Emit a CompactnessOverride constructor call fields."""
    lines: list[str] = []

    # months
    if "months" in ovr:
        lines.append(f"{indent}    {_str_array(ovr['months'])},")
    else:
        lines.append(f"{indent}    null,")

    # monthsInDate
    if "monthsInDate" in ovr:
        lines.append(f"{indent}    {_str_array(ovr['monthsInDate'])},")
    else:
        lines.append(f"{indent}    null,")

    # weekdays
    if "weekdays" in ovr:
        lines.append(f"{indent}    {_str_array(ovr['weekdays'])},")
    else:
        lines.append(f"{indent}    null,")

    # dayFormat
    if "dayFormat" in ovr:
        lines.append(f"{indent}    {_quote(ovr['dayFormat'])},")
    else:
        lines.append(f"{indent}    null,")

    # dayFormatExceptions
    if "dayFormatExceptions" in ovr:
        lines.append(f"{indent}    {_str_dict(ovr['dayFormatExceptions'])},")
    else:
        lines.append(f"{indent}    null,")

    # datePattern
    if "datePattern" in ovr:
        lines.append(f"{indent}    {_quote(ovr['datePattern'])},")
    else:
        lines.append(f"{indent}    null,")

    # datePatternWithYear
    if "datePatternWithYear" in ovr:
        lines.append(f"{indent}    {_quote(ovr['datePatternWithYear'])},")
    else:
        lines.append(f"{indent}    null,")

    # today
    if "today" in ovr:
        lines.append(f"{indent}    {_quote(ovr['today'])},")
    else:
        lines.append(f"{indent}    null,")

    # tomorrow
    if "tomorrow" in ovr:
        lines.append(f"{indent}    {_quote(ovr['tomorrow'])},")
    else:
        lines.append(f"{indent}    null,")

    # yesterday (last field, no trailing comma)
    if "yesterday" in ovr:
        lines.append(f"{indent}    {_quote(ovr['yesterday'])}")
    else:
        lines.append(f"{indent}    null")

    return lines


def emit_all(all_locales: list[dict]) -> str:
    """Generate the single Locales.cs file with all locales."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])

    lines = [HEADER]
    lines.append("using System.Collections.Generic;\n")
    lines.append("namespace SayableDateLib;\n")
    lines.append("/// <summary>")
    lines.append(f"/// All {len(all_locales)} locale definitions for sayable-date.")
    lines.append("/// </summary>")
    lines.append("public static class Locales")
    lines.append("{")

    # Emit locale constants
    for data in sorted_locs:
        code = data["code"]
        name = data["name"]
        uc = code.upper()

        lines.append("")
        lines.append(f"    {locale_source_comment(code).rstrip()}")
        lines.append("    // ================================================================")
        lines.append(f"    // {uc} — {name}")
        lines.append("    // ================================================================")

        lines.append(f"    public static readonly DateLocale {uc} = new(")
        lines.append(f"        {_quote(code)},")

        # months
        lines.append(f"        {_str_array(data['months'])},")

        # weekdays
        lines.append(f"        {_str_array(data['weekdays'])},")

        # dayFormat
        lines.append(f"        {_quote(data['dayFormat'])},")

        # dayFormatExceptions
        exceptions = data.get("dayFormatExceptions", {})
        lines.append(f"        {_str_dict(exceptions)},")

        # datePattern
        lines.append(f"        {_quote(data['datePattern'])},")

        # datePatternWithYear
        lines.append(f"        {_quote(data['datePatternWithYear'])},")

        # today, tomorrow, yesterday
        lines.append(f"        {_quote(data['today'])},")
        lines.append(f"        {_quote(data['tomorrow'])},")
        lines.append(f"        {_quote(data['yesterday'])},")

        # Optional strings
        lines.append(f"        {_nullable_str(data.get('dayAfterTomorrow'))},")
        lines.append(f"        {_nullable_str(data.get('dayBeforeYesterday'))},")
        lines.append(f"        {_nullable_str(data.get('thisWeekday'))},")
        lines.append(f"        {_nullable_str(data.get('nextWeekday'))},")
        lines.append(f"        {_nullable_str(data.get('lastWeekday'))},")

        # monthsInDate (optional array)
        if "monthsInDate" in data:
            lines.append(f"        {_str_array(data['monthsInDate'])},")
        else:
            lines.append("        null,")

        # Short override
        if "short" in data:
            lines.append("        new CompactnessOverride(")
            lines.extend(_emit_compactness_override(data["short"], "        "))
            lines.append("        ),")
        else:
            lines.append("        null,")

        # Compact override
        if "compact" in data:
            lines.append("        new CompactnessOverride(")
            lines.extend(_emit_compactness_override(data["compact"], "        "))
            lines.append("        )")
        else:
            lines.append("        null")

        lines.append("    );")

    # ALL dictionary
    lines.append("")
    lines.append("    public static readonly IReadOnlyDictionary<string, DateLocale> All =")
    lines.append("        new Dictionary<string, DateLocale>")
    lines.append("        {")
    for data in sorted_locs:
        code = data["code"]
        uc = code.upper()
        lines.append(f'            {{ "{code}", {uc} }},')
    lines.append("        };")

    # Get() method
    lines.append("")
    lines.append("    public static DateLocale? Get(string code)")
    lines.append("    {")
    lines.append("        return All.TryGetValue(code, out var locale) ? locale : null;")
    lines.append("    }")

    lines.append("}")
    lines.append("")

    return "\n".join(lines)


def output_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "csharp", "SayableDate", "Locales", "Locales.cs")
