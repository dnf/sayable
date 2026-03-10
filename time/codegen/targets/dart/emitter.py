"""Dart locale emitter for sayable-time."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header

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


def _str_list(items: list[str]) -> str:
    return "[" + ", ".join(_quote(s) for s in items) + "]"


def emit_locale(data: dict) -> str:
    code = data["code"]
    name = data["name"]
    clock = data["clock"]

    lines = [HEADER + locale_source_comment(code)]
    lines.append("import '../types.dart';")
    lines.append("")
    lines.append(f"/// {name} locale.")
    lines.append(f"final {_safe_id(code)} = TimeLocale(")

    # Code
    lines.append(f"  code: {_quote(code)},")

    # Clock config
    lines.append("  clock: ClockConfig(")
    lines.append(f"    hours: {_str_list(clock['hours'])},")
    lines.append(f"    midnight: {_quote(clock['midnight'])},")
    lines.append(f"    noon: {_quote(clock['noon'])},")
    lines.append("    patterns: {")
    for key in ("0", "5", "10", "15", "20", "25", "30", "35", "40", "45", "50", "55"):
        if key in clock["patterns"]:
            lines.append(f"      {key}: {_quote(clock['patterns'][key])},")
    lines.append("    },")
    lines.append("  ),")

    # Short override
    if "short" in data:
        sc = data["short"].get("clock", {})
        use24h = "true" if sc.get("use24h", True) else "false"
        fmt = sc.get("format", "{h}:{mm}")
        am_pm = sc.get("amPm")
        lines.append("  short: CompactnessOverride(")
        if am_pm:
            lines.append(f"    clock: ShortClockConfig(use24h: {use24h}, format: {_quote(fmt)}, amPm: [{_quote(am_pm[0])}, {_quote(am_pm[1])}]),")
        else:
            lines.append(f"    clock: ShortClockConfig(use24h: {use24h}, format: {_quote(fmt)}),")
        lines.append("  ),")

    # Compact override
    if "compact" in data:
        sc = data["compact"].get("clock", {})
        use24h = "true" if sc.get("use24h", True) else "false"
        fmt = sc.get("format", "{h}:{mm}")
        am_pm = sc.get("amPm")
        lines.append("  compact: CompactnessOverride(")
        if am_pm:
            lines.append(f"    clock: ShortClockConfig(use24h: {use24h}, format: {_quote(fmt)}, amPm: [{_quote(am_pm[0])}, {_quote(am_pm[1])}]),")
        else:
            lines.append(f"    clock: ShortClockConfig(use24h: {use24h}, format: {_quote(fmt)}),")
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
