"""F# locale emitter — single file with all locales."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header
from codegen.targets.fsharp.plural_rules import (
    get_fsharp_named_functions,
    get_fsharp_plural,
    is_simple_plural,
)

HEADER = make_header("codegen/targets/fsharp/emitter.py")

_CAT_MAP = {
    "zero": "Zero", "one": "One",
    "two": "Two", "few": "Few",
    "many": "Many", "other": "Other",
}


def _quote(s: str) -> str:
    escaped = s.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def _unit_forms(unit: object) -> str:
    if isinstance(unit, str):
        return f"Simple {_quote(unit)}"
    cats = ["zero", "one", "two", "few", "many", "other"]
    pairs = []
    for cat in cats:
        if cat in unit:
            pairs.append(f"({_CAT_MAP[cat]}, {_quote(unit[cat])})")
    return "Plural (Map.ofList [ " + "; ".join(pairs) + " ])"


def _stage_label(stage: object) -> str:
    if isinstance(stage, str):
        return f"Neutral {_quote(stage)}"
    return f"Gendered({_quote(stage['m'])}, {_quote(stage['f'])})"


def emit_all(all_locales: list[dict]) -> str:
    """Generate the single Locales.fs file with all locales."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])

    # Collect which named functions we need
    needed_functions: dict[str, str] = {}
    all_named = get_fsharp_named_functions()
    for data in sorted_locs:
        rule = data["pluralRule"]
        if not is_simple_plural(rule) and rule in all_named:
            needed_functions[rule] = all_named[rule]

    lines = [HEADER]
    lines.append(f"/// All {len(all_locales)} locale definitions for sayable-age.")
    lines.append("module SayableAgeLib.Locales\n")
    lines.append("open SayableAgeLib.Types\n")

    # Emit named plural functions
    for rule in sorted(needed_functions.keys()):
        lines.append("")
        lines.append(needed_functions[rule])

    # Emit locale constants
    for data in sorted_locs:
        code = data["code"]
        name = data["name"]
        rule = data["pluralRule"]
        uc = code.upper()

        lines.append("")
        lines.append(f"{locale_source_comment(code).rstrip()}")
        lines.append("// ================================================================")
        lines.append(f"// {uc} — {name}")
        lines.append("// ================================================================")

        lines.append(f"let {uc}: AgeLocale =")
        lines.append("    {")
        lines.append(f"        Code = {_quote(code)}")

        # Plural
        plural = get_fsharp_plural(rule)
        lines.append(f"        Plural = {plural}")

        # Units
        lines.append("        Units =")
        lines.append("            {")
        lines.append(f"                Day = {_unit_forms(data['units']['day'])}")
        lines.append(f"                Week = {_unit_forms(data['units']['week'])}")
        lines.append(f"                Month = {_unit_forms(data['units']['month'])}")
        lines.append(f"                Year = {_unit_forms(data['units']['year'])}")
        lines.append("            }")

        # Simple fields
        lines.append(f"        Half = {_quote(data['half'])}")
        lines.append(f"        Delimiter = {_quote(data['delimiter'])}")
        lines.append(f"        JustBorn = {_quote(data['justBorn'])}")

        # Stages
        lines.append("        Stages =")
        lines.append("            {")
        lines.append(f"                Newborn = {_stage_label(data['stages']['newborn'])}")
        lines.append(f"                Infant = {_stage_label(data['stages']['infant'])}")
        lines.append(f"                Toddler = {_stage_label(data['stages']['toddler'])}")
        lines.append(f"                Child = {_stage_label(data['stages']['child'])}")
        lines.append(f"                Teenager = {_stage_label(data['stages']['teenager'])}")
        lines.append(f"                Adult = {_stage_label(data['stages']['adult'])}")
        lines.append("            }")

        # Short/compact
        has_short = "short" in data
        has_compact = "compact" in data

        if has_short:
            lines.append(f"        ShortOverride = Some {_compactness_override(data['short'])}")
        else:
            lines.append("        ShortOverride = None")

        if has_compact:
            lines.append(f"        CompactOverride = Some {_compactness_override(data['compact'])}")
        else:
            lines.append("        CompactOverride = None")

        lines.append("        FormatNumber = None")
        lines.append("        FormatUnit = None")
        lines.append("    }")

    # ALL map
    lines.append("")
    lines.append("let All: Map<string, AgeLocale> =")
    lines.append("    Map.ofList")
    lines.append("        [")
    for data in sorted_locs:
        code = data["code"]
        uc = code.upper()
        lines.append(f'            ("{code}", {uc})')
    lines.append("        ]")

    # Get function
    lines.append("")
    lines.append("let get (code: string) : AgeLocale option = Map.tryFind code All")
    lines.append("")

    return "\n".join(lines)


def _compactness_override(ovr: dict) -> str:
    parts = []

    for unit_name in ("Day", "Week", "Month", "Year"):
        key = unit_name.lower()
        if "units" in ovr and key in ovr["units"]:
            val = ovr["units"][key]
            parts.append(f"            {unit_name} = Some ({_unit_forms(val)})")
        else:
            parts.append(f"            {unit_name} = None")

    for field_name, key in [("Half", "half"), ("Delimiter", "delimiter"), ("JustBorn", "justBorn")]:
        if key in ovr:
            parts.append(f"            {field_name} = Some {_quote(ovr[key])}")
        else:
            parts.append(f"            {field_name} = None")

    return "{\n" + "\n".join(parts) + "\n            }"


def output_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "fsharp", "SayableAge", "Locales", "Locales.fs")
