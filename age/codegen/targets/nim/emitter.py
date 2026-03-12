"""Nim locale emitter for sayable-age."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header
from codegen.targets.nim.plural_rules import get_nim_named_function, get_nim_plural, is_simple_plural

HEADER = make_header("codegen/targets/nim/emitter.py", line_prefix="# ")

_NIM_RESERVED = {
    "addr", "and", "as", "asm", "bind", "block", "break", "case", "cast",
    "concept", "const", "continue", "converter", "defer", "discard", "distinct",
    "div", "do", "elif", "else", "end", "enum", "except", "export", "finally",
    "for", "from", "func", "if", "import", "in", "include", "interface",
    "is", "isnot", "iterator", "let", "macro", "method", "mixin", "mod",
    "nil", "not", "notin", "object", "of", "or", "out", "proc", "ptr",
    "raise", "ref", "return", "shl", "shr", "static", "template", "try",
    "tuple", "type", "using", "var", "when", "while", "xor", "yield",
}


def _safe_id(code: str) -> str:
    """Escape locale codes that are Nim reserved keywords."""
    safe = code.replace("-", "_")
    if safe in _NIM_RESERVED:
        return f"{safe}Locale"
    return safe


def _const_name(code: str) -> str:
    """Generate constant name for a locale."""
    return _safe_id(code).upper()


def _quote(s: str) -> str:
    escaped = s.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def _unit_forms(unit: object) -> str:
    if isinstance(unit, str):
        return f"simpleUnit({_quote(unit)})"
    cats = ["zero", "one", "two", "few", "many", "other"]
    pairs = []
    for cat in cats:
        if cat in unit:
            pairs.append(f"(pc{cat.capitalize()}, {_quote(unit[cat])})")
    return "pluralUnit(@[" + ", ".join(pairs) + "])"


def _stage_label(stage: object) -> str:
    if isinstance(stage, str):
        return f"stageNeutral({_quote(stage)})"
    return f"stageGendered({_quote(stage['m'])}, {_quote(stage['f'])})"


def emit_locale(data: dict) -> str:
    code = data["code"]
    rule = data["pluralRule"]
    name = data["name"]

    lines = [HEADER + locale_source_comment(code, line_prefix="# ")]
    lines.append(f"## {name} locale.")
    lines.append("")
    lines.append("import ../locale")
    lines.append("")

    # Named plural function
    named_fn = get_nim_named_function(rule)
    if named_fn:
        lines.append(named_fn)
        lines.append("")

    # Locale constant
    plural_expr = get_nim_plural(rule)
    lines.append(f"let {_const_name(code)}* = AgeLocale(")
    lines.append(f"  code: {_quote(code)},")
    lines.append(f"  plural: {plural_expr},")

    # Units
    lines.append("  units: {")
    for unit_name in ("day", "week", "month", "year"):
        val = _unit_forms(data["units"][unit_name])
        lines.append(f"    {_quote(unit_name)}: {val},")
    lines.append("  }.toOrderedTable,")

    # Simple fields
    lines.append(f"  half: {_quote(data['half'])},")
    lines.append(f"  delimiter: {_quote(data['delimiter'])},")
    lines.append(f"  justBorn: {_quote(data['justBorn'])},")

    # Stages
    lines.append("  stages: {")
    for stage in ("newborn", "infant", "toddler", "child", "teenager", "adult"):
        val = _stage_label(data["stages"][stage])
        lines.append(f"    {_quote(stage)}: {val},")
    lines.append("  }.toOrderedTable,")

    # Short/compact
    for mode in ("short", "compact"):
        if mode in data:
            ovr = data[mode]
            lines.append(f"  {mode}: some(CompactnessOverride(")
            if "units" in ovr:
                lines.append("    units: some({")
                for unit_name in ("day", "week", "month", "year"):
                    if unit_name in ovr["units"]:
                        val = _unit_forms(ovr["units"][unit_name])
                        lines.append(f"      {_quote(unit_name)}: {val},")
                lines.append("    }.toOrderedTable),")
            else:
                lines.append("    units: none(OrderedTable[string, UnitForms]),")
            if "half" in ovr:
                lines.append(f"    half: some({_quote(ovr['half'])}),")
            else:
                lines.append("    half: none(string),")
            if "delimiter" in ovr:
                lines.append(f"    delimiter: some({_quote(ovr['delimiter'])}),")
            else:
                lines.append("    delimiter: none(string),")
            if "justBorn" in ovr:
                lines.append(f"    justBorn: some({_quote(ovr['justBorn'])}),")
            else:
                lines.append("    justBorn: none(string),")
            lines.append("  )),")

    if "short" not in data:
        lines.append("  short: none(CompactnessOverride),")
    if "compact" not in data:
        lines.append("  compact: none(CompactnessOverride),")

    lines.append(")")
    lines.append("")

    return "\n".join(lines)


def emit_registry(all_locales: list[dict]) -> str:
    """Generate the registry.nim file."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER]
    lines.append("## Locale registry for all supported languages.")
    lines.append("")
    lines.append("import std/[options, tables]")
    lines.append("import ../locale")

    # Import each locale file
    for loc in sorted_locs:
        code = loc["code"]
        lines.append(f"import {_safe_id(code)}")
    lines.append("")

    # Re-export
    lines.append("export locale")
    lines.append("")

    # getLocale function
    lines.append("let allLocales = {")
    for loc in sorted_locs:
        code = loc["code"]
        lines.append(f"  {_quote(code)}: {_const_name(code)},")
    lines.append("}.toTable")
    lines.append("")
    lines.append("proc getLocale*(code: string): Option[AgeLocale] =")
    lines.append("  if code in allLocales: some(allLocales[code])")
    lines.append("  else: none(AgeLocale)")
    lines.append("")

    return "\n".join(lines)


def emit_barrel(all_locales: list[dict]) -> str | None:
    return None


def output_path(code: str, root: str) -> str:
    import os
    return os.path.join(root, "impl", "nim", "src", "sayable_age", "locales", f"{_safe_id(code)}.nim")


def registry_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "nim", "src", "sayable_age", "locales", "registry.nim")


def barrel_path(root: str) -> str | None:
    return None
