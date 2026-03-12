"""VB.NET locale emitter — single file with all locales."""

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


_CAT_MAP = {
    "zero": "PluralCategory.Zero", "one": "PluralCategory.One",
    "two": "PluralCategory.Two", "few": "PluralCategory.Few",
    "many": "PluralCategory.Many", "other": "PluralCategory.Other",
}


def _quote(s: str) -> str:
    escaped = s.replace('"', '""')
    return f'"{escaped}"'


def _unit_forms(unit: object) -> str:
    if isinstance(unit, str):
        return f"UnitForms.Simple({_quote(unit)})"
    cats = ["zero", "one", "two", "few", "many", "other"]
    pairs = []
    for cat in cats:
        if cat in unit:
            pairs.append(f"{{ {_CAT_MAP[cat]}, {_quote(unit[cat])} }}")
    return "UnitForms.Plural(New Dictionary(Of PluralCategory, String) From { " + ", ".join(pairs) + " })"


def _stage_label(stage: object) -> str:
    if isinstance(stage, str):
        return f"StageLabel.Neutral({_quote(stage)})"
    return f"StageLabel.Gendered({_quote(stage['m'])}, {_quote(stage['f'])})"


def emit_all(all_locales: list[dict]) -> str:
    """Generate the single Locales.vb file with all locales."""
    from codegen.targets.vbnet.plural_rules import (
        get_vbnet_named_methods,
        get_vbnet_plural,
        is_simple_plural,
    )

    sorted_locs = sorted(all_locales, key=lambda d: d["code"])

    # Collect which named methods we need
    needed_methods: dict[str, str] = {}
    all_named = get_vbnet_named_methods()
    for data in sorted_locs:
        rule = data["pluralRule"]
        if not is_simple_plural(rule) and rule in all_named:
            needed_methods[rule] = all_named[rule]

    lines = [HEADER]
    lines.append("Imports System.Collections.Generic\n")
    lines.append("Namespace SayableAgeLib\n")
    lines.append("''' <summary>")
    lines.append(f"''' All {len(all_locales)} locale definitions for sayable-age.")
    lines.append("''' </summary>")
    lines.append("Public Module Locales")

    # Emit named plural methods
    for rule in sorted(needed_methods.keys()):
        lines.append("")
        lines.append(needed_methods[rule])

    # Emit locale constants
    for data in sorted_locs:
        code = data["code"]
        name = data["name"]
        rule = data["pluralRule"]
        ident = _ident(code)
        uc = code.upper()

        lines.append("")
        comment = locale_source_comment(code, line_prefix="' ").rstrip()
        lines.append(f"    {comment}")
        lines.append("    ' ================================================================")
        lines.append(f"    ' {uc} — {name}")
        lines.append("    ' ================================================================")

        lines.append(f"    Public ReadOnly {ident} As New AgeLocale(")
        lines.append(f"        {_quote(code)},")

        # Plural
        plural = get_vbnet_plural(rule)
        lines.append(f"        {plural},")

        # Units
        unit_names = ("day", "week", "month", "year")
        lines.append("        New Units(")
        for j, unit_name in enumerate(unit_names):
            val = _unit_forms(data["units"][unit_name])
            comma = "," if j < len(unit_names) - 1 else ""
            lines.append(f"            {val}{comma}")
        lines.append("        ),")

        # Simple fields
        lines.append(f"        {_quote(data['half'])},")
        lines.append(f"        {_quote(data['delimiter'])},")
        lines.append(f"        {_quote(data['justBorn'])},")

        # Stages
        stage_names = ("newborn", "infant", "toddler", "child", "teenager", "adult")
        lines.append("        New Stages(")
        for j, stage in enumerate(stage_names):
            val = _stage_label(data["stages"][stage])
            comma = "," if j < len(stage_names) - 1 else ""
            lines.append(f"            {val}{comma}")
        lines.append("        ),")

        # Short/compact
        has_short = "short" in data
        has_compact = "compact" in data

        if has_short:
            _emit_compactness_override(lines, data["short"], trailing_comma=True)
        else:
            lines.append("        Nothing,")

        if has_compact:
            _emit_compactness_override(lines, data["compact"], trailing_comma=False)
        else:
            lines.append("        Nothing")

        lines.append("    )")

    # ALL dictionary
    lines.append("")
    lines.append("    Public ReadOnly All As New Dictionary(Of String, AgeLocale) From {")
    for i, data in enumerate(sorted_locs):
        code = data["code"]
        ident = _ident(code)
        comma = "," if i < len(sorted_locs) - 1 else ""
        lines.append(f'        {{ "{code}", {ident} }}{comma}')
    lines.append("    }")

    # Get() method
    lines.append("")
    lines.append("    Public Function [Get](code As String) As AgeLocale")
    lines.append("        Dim locale As AgeLocale = Nothing")
    lines.append("        If All.TryGetValue(code, locale) Then Return locale")
    lines.append("        Return Nothing")
    lines.append("    End Function")

    lines.append("")
    lines.append("End Module")
    lines.append("")
    lines.append("End Namespace")
    lines.append("")

    return "\n".join(lines)


def _emit_compactness_override(lines: list[str], ovr: dict, trailing_comma: bool = True) -> None:
    lines.append("        New CompactnessOverride(")
    # Build all 7 fields: day, week, month, year, half, delimiter, justBorn
    fields: list[str] = []
    for unit_name in ("day", "week", "month", "year"):
        if "units" in ovr and unit_name in ovr["units"]:
            val = ovr["units"][unit_name]
            if isinstance(val, str):
                fields.append(f"UnitForms.Simple({_quote(val)})")
            else:
                fields.append(_unit_forms(val))
        else:
            fields.append("Nothing")
    for key in ("half", "delimiter", "justBorn"):
        if key in ovr:
            fields.append(_quote(ovr[key]))
        else:
            fields.append("Nothing")
    for j, field in enumerate(fields):
        comma = "," if j < len(fields) - 1 else ""
        lines.append(f"            {field}{comma}")
    tc = "," if trailing_comma else ""
    lines.append(f"        ){tc}")


def output_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "vbnet", "SayableAge", "Locales", "Locales.vb")
