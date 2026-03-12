"""VB.NET locale emitter for sayable-time — single file with all locales."""

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
    """Quote a string for VB.NET using double quotes."""
    escaped = s.replace('"', '""')
    return f'"{escaped}"'


def _str_array_12(items: list[str]) -> str:
    """Emit a VB.NET array initializer with 12 hour-name strings."""
    return "New String() { " + ", ".join(_quote(s) for s in items) + " }"


def _patterns_dict(patterns: dict[str, str]) -> str:
    """Emit a VB.NET Dictionary(Of Integer, String) initializer for minute patterns."""
    keys = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55]
    pairs = []
    for key in keys:
        skey = str(key)
        if skey in patterns:
            pairs.append(f"{{ {key}, {_quote(patterns[skey])} }}")
    return "New Dictionary(Of Integer, String) From { " + ", ".join(pairs) + " }"


def _clock_override(clock: dict, indent: str) -> list[str]:
    """Emit a ShortClockConfig for short/compact overrides."""
    lines = []
    use24h = "True" if clock.get("use24h", True) else "False"
    am_pm = clock.get("amPm")
    fmt = clock.get("format", "{h}:{mm}")

    if am_pm:
        lines.append(f"{indent}New ShortClockConfig({use24h}, ({_quote(am_pm[0])}, {_quote(am_pm[1])}), {_quote(fmt)})")
    else:
        lines.append(f"{indent}New ShortClockConfig({use24h}, Nothing, {_quote(fmt)})")

    return lines


def emit_all(all_locales: list[dict]) -> str:
    """Generate the single Locales.vb file with all time locales."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])

    lines = [HEADER]
    lines.append("Imports System.Collections.Generic\n")
    lines.append("Namespace SayableTimeLib\n")
    lines.append("''' <summary>")
    lines.append(f"''' All {len(all_locales)} locale definitions for sayable-time.")
    lines.append("''' </summary>")
    lines.append("Public Module Locales")

    for data in sorted_locs:
        code = data["code"]
        name = data["name"]
        ident = _ident(code)
        uc = code.upper()
        clock = data["clock"]

        lines.append("")
        comment = locale_source_comment(code, line_prefix="' ").rstrip()
        lines.append(f"    {comment}")
        lines.append("    ' ================================================================")
        lines.append(f"    ' {uc} — {name}")
        lines.append("    ' ================================================================")

        lines.append(f"    Public ReadOnly {ident} As New TimeLocale(")
        lines.append(f"        {_quote(code)},")

        # Clock config
        lines.append("        New ClockConfig(")
        lines.append(f"            {_str_array_12(clock['hours'])},")
        lines.append(f"            {_quote(clock['midnight'])},")
        lines.append(f"            {_quote(clock['noon'])},")
        lines.append(f"            {_patterns_dict(clock['patterns'])}")
        lines.append("        ),")

        # Short override
        has_short = "short" in data
        has_compact = "compact" in data

        if has_short:
            override_lines = _clock_override(data["short"]["clock"], "            ")
            lines.append("        New CompactnessOverride(")
            for ol in override_lines:
                lines.append(ol)
            lines.append("        ),")
        else:
            lines.append("        Nothing,")

        # Compact override
        if has_compact:
            override_lines = _clock_override(data["compact"]["clock"], "            ")
            lines.append("        New CompactnessOverride(")
            for ol in override_lines:
                lines.append(ol)
            lines.append("        )")
        else:
            lines.append("        Nothing")

        lines.append("    )")

    # ALL dictionary
    lines.append("")
    lines.append("    Public ReadOnly All As New Dictionary(Of String, TimeLocale) From {")
    for i, data in enumerate(sorted_locs):
        code = data["code"]
        ident = _ident(code)
        comma = "," if i < len(sorted_locs) - 1 else ""
        lines.append(f'        {{ "{code}", {ident} }}{comma}')
    lines.append("    }")

    # Get() method
    lines.append("")
    lines.append("    Public Function [Get](code As String) As TimeLocale")
    lines.append("        Dim locale As TimeLocale = Nothing")
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
    return os.path.join(root, "impl", "vbnet", "SayableTime", "Locales", "Locales.vb")
