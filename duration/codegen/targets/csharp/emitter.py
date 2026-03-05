"""C# locale emitter for sayable-duration — single file with all locales."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header
from codegen.targets.csharp.plural_rules import (
    get_csharp_named_methods,
    get_csharp_plural,
    is_simple_plural,
)

HEADER = make_header("codegen/targets/csharp/emitter.py")

_CAT_MAP = {
    "zero": "PluralCategory.Zero", "one": "PluralCategory.One",
    "two": "PluralCategory.Two", "few": "PluralCategory.Few",
    "many": "PluralCategory.Many", "other": "PluralCategory.Other",
}

# Duration has 7 unit names
_UNIT_NAMES = ("second", "minute", "hour", "day", "week", "month", "year")


def _quote(s: str) -> str:
    escaped = s.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def _unit_forms(unit: object) -> str:
    if isinstance(unit, str):
        return f"UnitForms.Simple({_quote(unit)})"
    cats = ["zero", "one", "two", "few", "many", "other"]
    pairs = []
    for cat in cats:
        if cat in unit:
            pairs.append(f"{{ {_CAT_MAP[cat]}, {_quote(unit[cat])} }}")
    return "UnitForms.Plural(new Dictionary<PluralCategory, string> { " + ", ".join(pairs) + " })"


def emit_all(all_locales: list[dict]) -> str:
    """Generate the single Locales.cs file with all locales."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])

    # Collect which named methods we need
    needed_methods: dict[str, str] = {}
    all_named = get_csharp_named_methods()
    for data in sorted_locs:
        rule = data["pluralRule"]
        if not is_simple_plural(rule) and rule in all_named:
            needed_methods[rule] = all_named[rule]

    lines = [HEADER]
    lines.append("using System.Collections.Generic;\n")
    lines.append("namespace SayableDurationLib;\n")
    lines.append("/// <summary>")
    lines.append(f"/// All {len(all_locales)} locale definitions for sayable-duration.")
    lines.append("/// </summary>")
    lines.append("public static class Locales")
    lines.append("{")

    # Emit named plural methods
    for rule in sorted(needed_methods.keys()):
        lines.append("")
        lines.append(needed_methods[rule])

    # Emit locale constants
    for data in sorted_locs:
        code = data["code"]
        name = data["name"]
        rule = data["pluralRule"]
        uc = code.upper()

        lines.append("")
        lines.append(f"    {locale_source_comment(code).rstrip()}")
        lines.append("    // ================================================================")
        lines.append(f"    // {uc} — {name}")
        lines.append("    // ================================================================")

        lines.append(f"    public static readonly DurationLocale {uc} = new(")
        lines.append(f"        {_quote(code)},")

        # Plural
        plural = get_csharp_plural(rule)
        lines.append(f"        {plural},")

        # Units
        lines.append("        new Units(")
        for j, unit_name in enumerate(_UNIT_NAMES):
            val = _unit_forms(data["units"][unit_name])
            comma = "," if j < len(_UNIT_NAMES) - 1 else ""
            lines.append(f"            {val}{comma}")
        lines.append("        ),")

        # Simple fields
        lines.append(f"        {_quote(data['half'])},")
        lines.append(f"        {_quote(data['delimiter'])},")
        lines.append(f"        {_quote(data['justNow'])},")
        lines.append(f"        {_quote(data['ago'])},")
        lines.append(f"        {_quote(data['inFuture'])},")

        # Short/compact
        has_short = "short" in data
        has_compact = "compact" in data

        if has_short:
            _emit_compactness_override(lines, data["short"], trailing_comma=True)
        else:
            lines.append("        null,")

        if has_compact:
            _emit_compactness_override(lines, data["compact"], trailing_comma=False)
        else:
            lines.append("        null")

        lines.append("    );")

    # ALL dictionary
    lines.append("")
    lines.append("    public static readonly IReadOnlyDictionary<string, DurationLocale> All =")
    lines.append("        new Dictionary<string, DurationLocale>")
    lines.append("        {")
    for data in sorted_locs:
        code = data["code"]
        uc = code.upper()
        lines.append(f'            {{ "{code}", {uc} }},')
    lines.append("        };")

    # Get() method
    lines.append("")
    lines.append("    public static DurationLocale? Get(string code)")
    lines.append("    {")
    lines.append("        return All.TryGetValue(code, out var locale) ? locale : null;")
    lines.append("    }")

    lines.append("}")
    lines.append("")

    return "\n".join(lines)


def _emit_compactness_override(lines: list[str], ovr: dict, trailing_comma: bool = True) -> None:
    lines.append("        new CompactnessOverride(")
    # Build all 11 fields: second, minute, hour, day, week, month, year, half, delimiter, ago, inFuture
    fields: list[str] = []
    for unit_name in _UNIT_NAMES:
        if "units" in ovr and unit_name in ovr["units"]:
            val = ovr["units"][unit_name]
            if isinstance(val, str):
                fields.append(f"UnitForms.Simple({_quote(val)})")
            else:
                fields.append(_unit_forms(val))
        else:
            fields.append("null")
    for key in ("half", "delimiter", "ago", "inFuture"):
        if key in ovr:
            fields.append(_quote(ovr[key]))
        else:
            fields.append("null")
    for j, field in enumerate(fields):
        comma = "," if j < len(fields) - 1 else ""
        lines.append(f"            {field}{comma}")
    tc = "," if trailing_comma else ""
    lines.append(f"        ){tc}")


def output_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "csharp", "SayableDuration", "Locales", "Locales.cs")
