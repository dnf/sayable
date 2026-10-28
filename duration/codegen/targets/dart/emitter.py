"""Dart locale emitter for sayable-duration."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header
from codegen.targets.dart.layout import Atom, Group, Node, call, map_literal, render
from codegen.targets.dart.plural_rules import get_dart_plural

HEADER = make_header("codegen/targets/dart/emitter.py")

_CAT_MAP = {
    "zero": "PluralCategory.zero",
    "one": "PluralCategory.one",
    "two": "PluralCategory.two",
    "few": "PluralCategory.few",
    "many": "PluralCategory.many",
    "other": "PluralCategory.other",
}


_DART_KEYWORDS = frozenset({
    "abstract", "as", "assert", "async", "await", "break", "case", "catch",
    "class", "const", "continue", "covariant", "default", "deferred", "do",
    "dynamic", "else", "enum", "export", "extends", "extension", "external",
    "factory", "false", "final", "finally", "for", "Function", "get", "hide",
    "if", "implements", "import", "in", "interface", "is", "late", "library",
    "mixin", "new", "null", "of", "on", "operator", "part", "required",
    "rethrow", "return", "sealed", "set", "show", "static", "super", "switch",
    "sync", "this", "throw", "true", "try", "typedef", "var", "void", "when",
    "while", "with", "yield",
})


def _safe_id(code: str) -> str:
    """Make a locale code safe as a Dart identifier."""
    ident = code.replace("-", "_")
    if ident in _DART_KEYWORDS:
        return f"locale_{ident}"
    return ident


def _quote(s: str) -> str:
    escaped = s.replace("\\", "\\\\").replace("'", "\\'").replace("$", "\\$")
    return f"'{escaped}'"


_UNIT_NAMES = ("second", "minute", "hour", "day", "week", "month", "year")


def _unit_forms(unit: object) -> Group:
    if isinstance(unit, str):
        return call("simpleUnit", Atom(_quote(unit)))
    cats = ["zero", "one", "two", "few", "many", "other"]
    pairs = [(_CAT_MAP[cat], Atom(_quote(unit[cat]))) for cat in cats if cat in unit]
    return call("pluralUnit", map_literal(pairs))


def _units(units: dict) -> Group:
    return map_literal([
        (_quote(unit_name), _unit_forms(units[unit_name]))
        for unit_name in _UNIT_NAMES
        if unit_name in units
    ])


def _override(ovr: dict) -> Group:
    fields: dict[str, Node] = {}
    if "units" in ovr:
        fields["units"] = _units(ovr["units"])
    for key in ("half", "delimiter", "ago", "inFuture"):
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
        "units": _units({unit_name: data["units"][unit_name] for unit_name in _UNIT_NAMES}),
    }
    for key in ("half", "delimiter", "justNow", "ago", "inFuture"):
        fields[key] = Atom(_quote(data[key]))
    for mode in ("short", "compact"):
        if mode in data:
            fields[mode] = _override(data[mode])

    lines = [HEADER + locale_source_comment(code)]
    lines.append("import '../types.dart';")
    lines.append("")
    lines.append(f"/// {name} locale.")
    lines.append(render(call("DurationLocale", **fields), lead=f"final {_safe_id(code)} = ", trail=";"))
    lines.append("")

    return "\n".join(lines)


def emit_barrel(all_locales: list[dict]) -> str | None:
    return None


def emit_registry(all_locales: list[dict]) -> str:
    """Generate locales.dart with getLocale function."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER]
    lines.append("import '../types.dart';")

    for loc in sorted_locs:
        code = loc["code"]
        lines.append(f"import '{code}.dart' as loc_{code.replace('-', '_')};")
    lines.append("")

    lines.append("/// Returns the locale for the given code, or null if not found.")
    lines.append("DurationLocale? getLocale(String code) {")
    lines.append("  switch (code) {")
    for loc in sorted_locs:
        code = loc["code"]
        safe = code.replace("-", "_")
        lines.append(f"    case {_quote(code)}:")
        lines.append(f"      return loc_{safe}.{_safe_id(code)};")
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
