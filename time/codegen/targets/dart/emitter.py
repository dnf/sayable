"""Dart locale emitter for sayable-time."""

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


_PATTERN_MINUTES = ("0", "5", "10", "15", "20", "25", "30", "35", "40", "45", "50", "55")


def _clock(clock: dict) -> Group:
    patterns = map_literal([
        (minute, Atom(_quote(clock["patterns"][minute])))
        for minute in _PATTERN_MINUTES
        if minute in clock["patterns"]
    ])
    return call(
        "ClockConfig",
        hours=_str_list(clock["hours"]),
        midnight=Atom(_quote(clock["midnight"])),
        noon=Atom(_quote(clock["noon"])),
        patterns=patterns,
    )


def _override(ovr: dict) -> Group:
    sc = ovr.get("clock", {})
    fields: dict[str, Node] = {
        "use24h": Atom("true" if sc.get("use24h", True) else "false"),
        "format": Atom(_quote(sc.get("format", "{h}:{mm}"))),
    }
    am_pm = sc.get("amPm")
    if am_pm:
        fields["amPm"] = _str_list(am_pm[:2])
    return call("CompactnessOverride", clock=call("ShortClockConfig", **fields))


def emit_locale(data: dict) -> str:
    code = data["code"]
    name = data["name"]

    fields: dict[str, Node] = {
        "code": Atom(_quote(code)),
        "clock": _clock(data["clock"]),
    }
    for mode in ("short", "compact"):
        if mode in data:
            fields[mode] = _override(data[mode])

    lines = [HEADER + locale_source_comment(code)]
    lines.append("import '../types.dart';")
    lines.append("")
    lines.append(f"/// {name} locale.")
    lines.append(render(call("TimeLocale", **fields), lead=f"final {_safe_id(code)} = ", trail=";"))
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
    lines.append("TimeLocale? getLocale(String code) {")
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
