"""TypeScript locale emitter."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header
from codegen.targets.typescript.plural_rules import get_ts_named_function, get_ts_plural, is_simple_plural

HEADER = make_header("codegen/targets/typescript/emitter.py")


def _quote(s: str) -> str:
    """Quote a string for TypeScript, using single quotes and escaping."""
    escaped = s.replace("\\", "\\\\").replace("'", "\\'")
    return f"'{escaped}'"


def _unit_forms(unit: object) -> str:
    """Emit a UnitForms value."""
    if isinstance(unit, str):
        return _quote(unit)
    cats = ["zero", "one", "two", "few", "many", "other"]
    pairs = []
    for cat in cats:
        if cat in unit:
            pairs.append(f"{cat}: {_quote(unit[cat])}")
    return "{ " + ", ".join(pairs) + " }"


def _stage_label(stage: object) -> str:
    """Emit a StageLabel value."""
    if isinstance(stage, str):
        return _quote(stage)
    return f"{{ m: {_quote(stage['m'])}, f: {_quote(stage['f'])} }}"


def emit_locale(data: dict) -> str:
    """Generate a TypeScript locale file from canonical JSON."""
    code = data["code"]
    rule = data["pluralRule"]
    lines = [HEADER + locale_source_comment(code)]

    # Imports
    if is_simple_plural(rule):
        lines.append("import type { AgeLocale } from '../locale.js';\n")
    else:
        lines.append("import type { AgeLocale, PluralCategory } from '../locale.js';\n")

    # Named plural function for complex rules
    named_fn = get_ts_named_function(rule)
    if named_fn:
        lines.append(named_fn + "\n")

    # Locale export
    lines.append(f"export const {code}: AgeLocale = {{")
    lines.append(f"  code: {_quote(code)},")

    # Plural
    if is_simple_plural(rule):
        lines.append(f"  plural: {get_ts_plural(rule)},")
    else:
        lines.append("  plural,")

    # Units
    lines.append("  units: {")
    for unit_name in ("day", "week", "month", "year"):
        comma = "," if unit_name != "year" else ","
        val = _unit_forms(data["units"][unit_name])
        pad = " " * (6 - len(unit_name))
        lines.append(f"    {unit_name}:{pad}{val}{comma}")
    lines.append("  },")

    # Simple fields
    lines.append(f"  half: {_quote(data['half'])},")
    lines.append(f"  delimiter: {_quote(data['delimiter'])},")
    lines.append(f"  justBorn: {_quote(data['justBorn'])},")

    # Stages
    lines.append("  stages: {")
    stage_names = ["newborn", "infant", "toddler", "child", "teenager", "adult"]
    for stage in stage_names:
        val = _stage_label(data["stages"][stage])
        lines.append(f"    {stage}: {val},")
    lines.append("  },")

    # Short/compact overrides
    for mode in ("short", "compact"):
        if mode in data:
            ovr = data[mode]
            lines.append(f"  {mode}: {{")
            if "units" in ovr:
                lines.append("    units: {")
                for unit_name in ("day", "week", "month", "year"):
                    if unit_name in ovr["units"]:
                        val = _unit_forms(ovr["units"][unit_name])
                        pad = " " * (6 - len(unit_name))
                        lines.append(f"      {unit_name}:{pad}{val},")
                lines.append("    },")
            if "half" in ovr:
                lines.append(f"    half: {_quote(ovr['half'])},")
            if "delimiter" in ovr:
                lines.append(f"    delimiter: {_quote(ovr['delimiter'])},")
            if "justBorn" in ovr:
                lines.append(f"    justBorn: {_quote(ovr['justBorn'])},")
            lines.append("  },")

    lines.append("};")
    lines.append("")

    return "\n".join(lines)


def emit_barrel(all_locales: list[dict]) -> str:
    """Generate the locales/index.ts barrel file."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER]

    lines.append("import type { AgeLocale } from '../locale.js';")

    for loc in sorted_locs:
        code = loc["code"]
        lines.append(f"import {{ {code} }} from './{code}.js';")

    lines.append("")

    # Lookup map + function
    codes = ", ".join(loc["code"] for loc in sorted_locs)
    lines.append(f"const _ALL: Record<string, AgeLocale> = {{ {codes} }};")
    lines.append("")
    lines.append("export function getLocale(code: string): AgeLocale | undefined {")
    lines.append("  return _ALL[code];")
    lines.append("}")
    lines.append("")

    # Re-export all locale constants
    lines.append(f"export {{ {codes} }};")
    lines.append("")
    return "\n".join(lines)


def output_path(code: str, root: str) -> str:
    import os
    return os.path.join(root, "src", "typescript", "src", "locales", f"{code}.ts")


def barrel_path(root: str) -> str:
    import os
    return os.path.join(root, "src", "typescript", "src", "locales", "index.ts")
