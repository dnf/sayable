"""VB.NET locale emitter for sayable-date — single file with all locales."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header

HEADER = make_header("codegen/targets/vbnet/emitter.py", line_prefix="' ")

# VB.NET reserved keywords that may collide with uppercase locale codes
_VB_KEYWORDS = frozenset({
    "AS", "BY", "DO", "IF", "IN", "IS", "ME", "MY", "OF", "ON", "OR", "TO",
    "AND", "DIM", "END", "FOR", "GET", "LET", "LIB", "MOD", "NEW", "NOT", "REM",
    "SET", "SUB", "TRY", "XOR",
})


def _ident(code: str) -> str:
    """Return a safe VB.NET identifier for a locale code, escaping keywords."""
    uc = code.upper()
    if uc in _VB_KEYWORDS:
        return f"[{uc}]"
    return uc


def _quote(s: str) -> str:
    escaped = s.replace('"', '""')
    return f'"{escaped}"'


def _str_array(items: list[str]) -> str:
    """Emit a VB.NET array initializer on one line."""
    return "New String() { " + ", ".join(_quote(s) for s in items) + " }"


def _str_dict(d: dict[str, str]) -> str:
    """Emit a VB.NET Dictionary initializer on one line."""
    if not d:
        return "New Dictionary(Of String, String)()"
    pairs = [f'{{ {_quote(k)}, {_quote(v)} }}' for k, v in d.items()]
    return "New Dictionary(Of String, String) From { " + ", ".join(pairs) + " }"


def _nullable_str(value: str | None) -> str:
    if value is None:
        return "Nothing"
    return _quote(value)


def _emit_compactness_override(ovr: dict, indent: str) -> list[str]:
    """Emit a CompactnessOverride constructor call fields."""
    lines: list[str] = []

    for key in ("months", "monthsInDate", "weekdays"):
        if key in ovr:
            lines.append(f"{indent}    {_str_array(ovr[key])},")
        else:
            lines.append(f"{indent}    Nothing,")

    if "dayFormat" in ovr:
        lines.append(f"{indent}    {_quote(ovr['dayFormat'])},")
    else:
        lines.append(f"{indent}    Nothing,")

    if "dayFormatExceptions" in ovr:
        lines.append(f"{indent}    {_str_dict(ovr['dayFormatExceptions'])},")
    else:
        lines.append(f"{indent}    Nothing,")

    for key in ("datePattern", "datePatternWithYear", "today", "tomorrow"):
        if key in ovr:
            lines.append(f"{indent}    {_quote(ovr[key])},")
        else:
            lines.append(f"{indent}    Nothing,")

    # yesterday (last field, no trailing comma)
    if "yesterday" in ovr:
        lines.append(f"{indent}    {_quote(ovr['yesterday'])}")
    else:
        lines.append(f"{indent}    Nothing")

    return lines


def emit_all(all_locales: list[dict]) -> str:
    """Generate the single Locales.vb file with all locales."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])

    lines = [HEADER]
    lines.append("Imports System.Collections.Generic\n")
    lines.append("Namespace SayableDateLib\n")
    lines.append("''' <summary>")
    lines.append(f"''' All {len(all_locales)} locale definitions for sayable-date.")
    lines.append("''' </summary>")
    lines.append("Public Module Locales")

    # Emit locale constants
    for data in sorted_locs:
        code = data["code"]
        name = data["name"]
        ident = _ident(code)
        uc = code.upper()

        lines.append("")
        comment = locale_source_comment(code, line_prefix="' ").rstrip()
        lines.append(f"    {comment}")
        lines.append("    ' ================================================================")
        lines.append(f"    ' {uc} — {name}")
        lines.append("    ' ================================================================")

        lines.append(f"    Public ReadOnly {ident} As New DateLocale(")
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
            lines.append("        Nothing,")

        # Short override
        if "short" in data:
            lines.append("        New CompactnessOverride(")
            lines.extend(_emit_compactness_override(data["short"], "        "))
            lines.append("        ),")
        else:
            lines.append("        Nothing,")

        # Compact override
        if "compact" in data:
            lines.append("        New CompactnessOverride(")
            lines.extend(_emit_compactness_override(data["compact"], "        "))
            lines.append("        )")
        else:
            lines.append("        Nothing")

        lines.append("    )")

    # ALL dictionary
    lines.append("")
    lines.append("    Public ReadOnly All As New Dictionary(Of String, DateLocale) From {")
    for i, data in enumerate(sorted_locs):
        code = data["code"]
        ident = _ident(code)
        comma = "," if i < len(sorted_locs) - 1 else ""
        lines.append(f'        {{ "{code}", {ident} }}{comma}')
    lines.append("    }")

    # Get() method
    lines.append("")
    lines.append("    Public Function [Get](code As String) As DateLocale")
    lines.append("        Dim locale As DateLocale = Nothing")
    lines.append("        If All.TryGetValue(code, locale) Then Return locale")
    lines.append("        Return Nothing")
    lines.append("    End Function")

    lines.append("")
    lines.append("End Module")
    lines.append("")
    lines.append("End Namespace")
    lines.append("")

    return "\n".join(lines)


def output_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "vbnet", "SayableDate", "Locales", "Locales.vb")
