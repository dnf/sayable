"""Dart locale emitter."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header
from codegen.targets.dart.plural_rules import get_dart_plural

HEADER = make_header("codegen/targets/dart/emitter.py")

# Plural category name mapping
_CAT_MAP = {
    "zero": "PluralCategory.zero",
    "one": "PluralCategory.one",
    "two": "PluralCategory.two",
    "few": "PluralCategory.few",
    "many": "PluralCategory.many",
    "other": "PluralCategory.other",
}


_DART_RESERVED = {
    "abstract", "as", "assert", "async", "await", "break", "case", "catch",
    "class", "const", "continue", "covariant", "default", "deferred", "do",
    "dynamic", "else", "enum", "export", "extends", "extension", "external",
    "factory", "false", "final", "finally", "for", "function", "get", "hide",
    "if", "implements", "import", "in", "interface", "is", "late", "library",
    "mixin", "new", "null", "on", "operator", "part", "required", "rethrow",
    "return", "sealed", "set", "show", "static", "super", "switch", "sync",
    "this", "throw", "true", "try", "type", "typedef", "var", "void", "when",
    "while", "with", "yield",
}


def _safe_id(code: str) -> str:
    """Escape locale codes that are Dart reserved keywords."""
    safe = code.replace("-", "_")
    if safe in _DART_RESERVED:
        return f"{safe}_"
    return safe


def _quote(s: str) -> str:
    escaped = s.replace("\\", "\\\\").replace("'", "\\'").replace("$", "\\$")
    return f"'{escaped}'"


def _unit_forms(unit: object) -> str:
    if isinstance(unit, str):
        return f"simpleUnit({_quote(unit)})"
    cats = ["zero", "one", "two", "few", "many", "other"]
    pairs = []
    for cat in cats:
        if cat in unit:
            pairs.append(f"{_CAT_MAP[cat]}: {_quote(unit[cat])}")
    return "pluralUnit({" + ", ".join(pairs) + "})"


def _stage_label(stage: object) -> str:
    if isinstance(stage, str):
        return f"stageNeutral({_quote(stage)})"
    return f"stageGendered({_quote(stage['m'])}, {_quote(stage['f'])})"


def emit_locale(data: dict) -> str:
    code = data["code"]
    rule = data["pluralRule"]
    name = data["name"]

    lines = [HEADER + locale_source_comment(code)]
    lines.append("import '../types.dart';")
    lines.append("")
    lines.append(f"/// {name} locale.")
    lines.append(f"final {_safe_id(code)} = AgeLocale(")

    # Code
    lines.append(f"  code: {_quote(code)},")

    # Plural
    plural = get_dart_plural(rule)
    lines.append(f"  plural: {plural.strip()},")

    # Units
    for unit_name in ("day", "week", "month", "year"):
        val = _unit_forms(data["units"][unit_name])
        lines.append(f"  {unit_name}: {val},")

    # Simple fields
    lines.append(f"  half: {_quote(data['half'])},")
    lines.append(f"  delimiter: {_quote(data['delimiter'])},")
    lines.append(f"  justBorn: {_quote(data['justBorn'])},")

    # Stages
    for stage in ("newborn", "infant", "toddler", "child", "teenager", "adult"):
        val = _stage_label(data["stages"][stage])
        lines.append(f"  {stage}: {val},")

    # Short/compact
    for mode in ("short", "compact"):
        if mode in data:
            ovr = data[mode]
            lines.append(f"  {mode}: CompactnessOverride(")
            if "units" in ovr:
                for unit_name in ("day", "week", "month", "year"):
                    if unit_name in ovr["units"]:
                        val = ovr["units"][unit_name]
                        if isinstance(val, str):
                            lines.append(f"    {unit_name}: simpleUnit({_quote(val)}),")
                        else:
                            lines.append(f"    {unit_name}: {_unit_forms(val)},")
            if "delimiter" in ovr:
                lines.append(f"    delimiter: {_quote(ovr['delimiter'])},")
            if "half" in ovr:
                lines.append(f"    half: {_quote(ovr['half'])},")
            if "justBorn" in ovr:
                lines.append(f"    justBorn: {_quote(ovr['justBorn'])},")
            lines.append("  ),")

    lines.append(");")
    lines.append("")

    return "\n".join(lines)


def emit_barrel(all_locales: list[dict]) -> str | None:
    return None


def emit_registry(all_locales: list[dict]) -> str:
    """Generate locales.dart with getLocale function."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER]
    lines.append("import '../types.dart';")

    # Import each locale file
    for loc in sorted_locs:
        code = loc["code"]
        lines.append(f"import '{code}.dart' as loc_{_safe_id(code)};")
    lines.append("")

    lines.append("/// Returns the locale for the given code, or null if not found.")
    lines.append("AgeLocale? getLocale(String code) {")
    lines.append("  switch (code) {")
    for loc in sorted_locs:
        code = loc["code"]
        safe = _safe_id(code)
        lines.append(f"    case {_quote(code)}:")
        lines.append(f"      return loc_{safe}.{safe};")
    lines.append("    default:")
    lines.append("      return null;")
    lines.append("  }")
    lines.append("}")
    lines.append("")
    return "\n".join(lines)


def output_path(code: str, root: str) -> str:
    import os
    return os.path.join(root, "impl", "dart", "lib", "src", "locales", f"{code}.dart")


def registry_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "dart", "lib", "src", "locales", "locales.dart")


def barrel_path(root: str) -> str | None:
    return None
