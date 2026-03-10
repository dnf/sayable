"""Dart locale emitter for sayable-date."""

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


def _str_map(d: dict[str, str]) -> str:
    pairs = [f"{_quote(k)}: {_quote(v)}" for k, v in d.items()]
    return "{" + ", ".join(pairs) + "}"


def emit_locale(data: dict) -> str:
    code = data["code"]
    name = data["name"]

    lines = [HEADER + locale_source_comment(code)]
    lines.append("import '../types.dart';")
    lines.append("")
    lines.append(f"/// {name} locale.")
    lines.append(f"final {_safe_id(code)} = DateLocale(")

    lines.append(f"  code: {_quote(code)},")
    lines.append(f"  months: {_str_list(data['months'])},")
    lines.append(f"  weekdays: {_str_list(data['weekdays'])},")
    lines.append(f"  dayFormat: {_quote(data['dayFormat'])},")

    if "dayFormatExceptions" in data and data["dayFormatExceptions"]:
        lines.append(f"  dayFormatExceptions: {_str_map(data['dayFormatExceptions'])},")

    lines.append(f"  datePattern: {_quote(data['datePattern'])},")
    lines.append(f"  datePatternWithYear: {_quote(data['datePatternWithYear'])},")
    lines.append(f"  today: {_quote(data['today'])},")
    lines.append(f"  tomorrow: {_quote(data['tomorrow'])},")
    lines.append(f"  yesterday: {_quote(data['yesterday'])},")

    if "dayAfterTomorrow" in data:
        lines.append(f"  dayAfterTomorrow: {_quote(data['dayAfterTomorrow'])},")
    if "dayBeforeYesterday" in data:
        lines.append(f"  dayBeforeYesterday: {_quote(data['dayBeforeYesterday'])},")
    if "thisWeekday" in data:
        lines.append(f"  thisWeekday: {_quote(data['thisWeekday'])},")
    if "nextWeekday" in data:
        lines.append(f"  nextWeekday: {_quote(data['nextWeekday'])},")
    if "lastWeekday" in data:
        lines.append(f"  lastWeekday: {_quote(data['lastWeekday'])},")
    if "monthsInDate" in data:
        lines.append(f"  monthsInDate: {_str_list(data['monthsInDate'])},")

    # Short override
    if "short" in data:
        ovr = data["short"]
        lines.append("  short: CompactnessOverride(")
        if "months" in ovr:
            lines.append(f"    months: {_str_list(ovr['months'])},")
        if "weekdays" in ovr:
            lines.append(f"    weekdays: {_str_list(ovr['weekdays'])},")
        if "dayFormat" in ovr:
            lines.append(f"    dayFormat: {_quote(ovr['dayFormat'])},")
        if "dayFormatExceptions" in ovr:
            lines.append(f"    dayFormatExceptions: {_str_map(ovr['dayFormatExceptions'])},")
        if "datePattern" in ovr:
            lines.append(f"    datePattern: {_quote(ovr['datePattern'])},")
        if "datePatternWithYear" in ovr:
            lines.append(f"    datePatternWithYear: {_quote(ovr['datePatternWithYear'])},")
        lines.append("  ),")

    # Compact override
    if "compact" in data:
        ovr = data["compact"]
        lines.append("  compact: CompactnessOverride(")
        if "datePattern" in ovr:
            lines.append(f"    datePattern: {_quote(ovr['datePattern'])},")
        if "datePatternWithYear" in ovr:
            lines.append(f"    datePatternWithYear: {_quote(ovr['datePatternWithYear'])},")
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
