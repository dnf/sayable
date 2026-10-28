"""Dart locale emitter for sayable-date."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header
from codegen.targets.dart.layout import Atom, Group, Node, call, list_literal, map_literal, render

HEADER = make_header("codegen/targets/dart/emitter.py")


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


def _str_list(items: list[str]) -> Group:
    return list_literal([Atom(_quote(s)) for s in items])


def _str_map(d: dict[str, str]) -> Group:
    return map_literal([(_quote(k), Atom(_quote(v))) for k, v in d.items()])


_STRING_LISTS = ("months", "weekdays", "monthsInDate")
_STRING_MAPS = ("dayFormatExceptions",)


def _fields(data: dict, keys: tuple[str, ...]) -> dict[str, Node]:
    """The Dart argument for each of ``keys`` that ``data`` has, in order."""
    fields: dict[str, Node] = {}
    for key in keys:
        if key not in data:
            continue
        if key in _STRING_LISTS:
            fields[key] = _str_list(data[key])
        elif key in _STRING_MAPS:
            fields[key] = _str_map(data[key])
        else:
            fields[key] = Atom(_quote(data[key]))
    return fields


_LOCALE_KEYS = (
    "code", "months", "weekdays", "dayFormat", "dayFormatExceptions",
    "datePattern", "datePatternWithYear", "today", "tomorrow", "yesterday",
    "dayAfterTomorrow", "dayBeforeYesterday", "thisWeekday", "nextWeekday",
    "lastWeekday", "monthsInDate",
)
_SHORT_KEYS = (
    "months", "weekdays", "dayFormat", "dayFormatExceptions",
    "datePattern", "datePatternWithYear",
)
_COMPACT_KEYS = ("datePattern", "datePatternWithYear")


def emit_locale(data: dict) -> str:
    code = data["code"]
    name = data["name"]

    # An empty dayFormatExceptions is left out at the top level only.
    top = {k: v for k, v in data.items() if k != "dayFormatExceptions" or v}
    fields = _fields(top, _LOCALE_KEYS)
    if "short" in data:
        fields["short"] = call("CompactnessOverride", **_fields(data["short"], _SHORT_KEYS))
    if "compact" in data:
        fields["compact"] = call("CompactnessOverride", **_fields(data["compact"], _COMPACT_KEYS))

    lines = [HEADER + locale_source_comment(code)]
    lines.append("import '../types.dart';")
    lines.append("")
    lines.append(f"/// {name} locale.")
    lines.append(render(call("DateLocale", **fields), lead=f"final {_safe_id(code)} = ", trail=";"))
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
    lines.append("DateLocale? getLocale(String code) {")
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
