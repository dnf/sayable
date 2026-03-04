"""Gleam locale emitter."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header
from codegen.targets.gleam.plural_rules import get_gleam_plural

HEADER = make_header("codegen/targets/gleam/emitter.py")


def _module_name(code: str) -> str:
    """Convert locale code to Gleam module name (lowercase, hyphens to underscores)."""
    return code.replace("-", "_")


def _quote(s: str) -> str:
    escaped = s.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def _unit_forms(unit: object) -> str:
    if isinstance(unit, str):
        return f"types.SimpleUnit({_quote(unit)})"
    cats = ["zero", "one", "two", "few", "many", "other"]
    pairs = []
    for cat in cats:
        if cat in unit:
            gleam_cat = f"types.{cat.capitalize()}"
            pairs.append(f"#({gleam_cat}, {_quote(unit[cat])})")
    return "types.PluralUnit([" + ", ".join(pairs) + "])"


def _stage_label(stage: object) -> str:
    if isinstance(stage, str):
        return f"types.NeutralStage({_quote(stage)})"
    return f"types.GenderedStage({_quote(stage['m'])}, {_quote(stage['f'])})"


def _build_compactness(ovr: dict, indent: str) -> str:
    inner = indent + "  "
    parts = []
    for unit_name in ("day", "week", "month", "year"):
        if "units" in ovr and unit_name in ovr["units"]:
            val = _unit_forms(ovr["units"][unit_name])
            parts.append(f"{inner}{unit_name}: Ok({val}),")
        else:
            parts.append(f"{inner}{unit_name}: Error(Nil),")
    if "half" in ovr:
        parts.append(f"{inner}half: Ok({_quote(ovr['half'])}),")
    else:
        parts.append(f"{inner}half: Error(Nil),")
    if "delimiter" in ovr:
        parts.append(f"{inner}delimiter: Ok({_quote(ovr['delimiter'])}),")
    else:
        parts.append(f"{inner}delimiter: Error(Nil),")
    if "justBorn" in ovr:
        parts.append(f"{inner}just_born: Ok({_quote(ovr['justBorn'])}),")
    else:
        parts.append(f"{inner}just_born: Error(Nil),")
    return "\n".join(parts)


def emit_locale(data: dict) -> str:
    code = data["code"]
    rule = data["pluralRule"]
    mod = _module_name(code)
    indent = "  "

    lines = [HEADER + locale_source_comment(code)]
    lines.append("import sayableage/types")
    lines.append("")
    lines.append(f"pub fn locale() -> types.AgeLocale {{")
    lines.append(f"  types.AgeLocale(")

    # Code
    lines.append(f"    code: {_quote(code)},")

    # Plural
    plural = get_gleam_plural(rule)
    lines.append(f"    plural: {plural},")

    # Units
    for unit_name in ("day", "week", "month", "year"):
        val = _unit_forms(data["units"][unit_name])
        lines.append(f"    {unit_name}: {val},")

    # Simple fields
    lines.append(f"    half: {_quote(data['half'])},")
    lines.append(f"    delimiter: {_quote(data['delimiter'])},")
    lines.append(f"    just_born: {_quote(data['justBorn'])},")

    # Stages
    for stage in ("newborn", "infant", "toddler", "child", "teenager", "adult"):
        val = _stage_label(data["stages"][stage])
        lines.append(f"    {stage}: {val},")

    # Short/compact
    for mode in ("short", "compact"):
        if mode in data:
            lines.append(f"    {mode}: Ok(types.CompactnessOverride(")
            lines.append(_build_compactness(data[mode], "    "))
            lines.append(f"    )),")
        else:
            lines.append(f"    {mode}: Error(Nil),")

    lines.append("  )")
    lines.append("}")
    lines.append("")

    return "\n".join(lines)


def emit_registry(all_locales: list[dict]) -> str:
    """Generate the locales module with get(code) function."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER]
    lines.append("import sayableage/types")

    # Import each locale module
    for loc in sorted_locs:
        code = loc["code"]
        mod = _module_name(code)
        lines.append(f"import sayableage/locales/{mod} as locale_{mod}")
    lines.append("")

    lines.append("pub fn get(code: String) -> Result(types.AgeLocale, Nil) {")
    lines.append("  case code {")
    for loc in sorted_locs:
        code = loc["code"]
        mod = _module_name(code)
        lines.append(f"    {_quote(code)} -> Ok(locale_{mod}.locale())")
    lines.append("    _ -> Error(Nil)")
    lines.append("  }")
    lines.append("}")
    lines.append("")

    return "\n".join(lines)


def output_path(code: str, root: str) -> str:
    import os
    mod = code.replace("-", "_")
    return os.path.join(root, "src", "gleam", "src", "sayableage", "locales", f"{mod}.gleam")


def registry_path(root: str) -> str:
    import os
    return os.path.join(root, "src", "gleam", "src", "sayableage", "locales", "locales.gleam")
