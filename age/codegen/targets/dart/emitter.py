"""Dart locale emitter."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header
from codegen.targets.dart.layout import Atom, Group, Node, call, map_literal, render
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


def _unit_forms(unit: object) -> Group:
    if isinstance(unit, str):
        return call("simpleUnit", Atom(_quote(unit)))
    cats = ["zero", "one", "two", "few", "many", "other"]
    pairs = [(_CAT_MAP[cat], Atom(_quote(unit[cat]))) for cat in cats if cat in unit]
    return call("pluralUnit", map_literal(pairs))


def _stage_label(stage: object) -> Group:
    if isinstance(stage, str):
        return call("stageNeutral", Atom(_quote(stage)))
    return call("stageGendered", Atom(_quote(stage["m"])), Atom(_quote(stage["f"])))


def _override(ovr: dict) -> Group:
    fields: dict[str, Node] = {}
    units = ovr.get("units", {})
    for unit_name in ("day", "week", "month", "year"):
        if unit_name in units:
            fields[unit_name] = _unit_forms(units[unit_name])
    for key in ("delimiter", "half", "justBorn"):
        if key in ovr:
            fields[key] = Atom(_quote(ovr[key]))
    return call("CompactnessOverride", **fields)


def emit_locale(data: dict) -> str:
    code = data["code"]
    rule = data["pluralRule"]
    name = data["name"]

    fields: dict[str, Node] = {
        "code": Atom(_quote(code)),
        "plural": Atom(get_dart_plural(rule).strip()),
    }
    for unit_name in ("day", "week", "month", "year"):
        fields[unit_name] = _unit_forms(data["units"][unit_name])
    fields["half"] = Atom(_quote(data["half"]))
    fields["delimiter"] = Atom(_quote(data["delimiter"]))
    fields["justBorn"] = Atom(_quote(data["justBorn"]))
    for stage in ("newborn", "infant", "toddler", "child", "teenager", "adult"):
        fields[stage] = _stage_label(data["stages"][stage])
    for mode in ("short", "compact"):
        if mode in data:
            fields[mode] = _override(data[mode])

    lines = [HEADER + locale_source_comment(code)]
    lines.append("import '../types.dart';")
    lines.append("")
    lines.append(f"/// {name} locale.")
    lines.append(render(call("AgeLocale", **fields), lead=f"final {_safe_id(code)} = ", trail=";"))
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
