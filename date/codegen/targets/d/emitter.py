"""D locale emitter for sayable-date — single-file strategy."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header

HEADER = make_header("codegen/targets/d/emitter.py")

_D_RESERVED = {
    "abstract", "alias", "align", "asm", "assert", "auto",
    "body", "bool", "break", "byte",
    "case", "cast", "catch", "cdouble", "cent", "cfloat", "char",
    "class", "const", "continue", "creal",
    "dchar", "debug", "default", "delegate", "delete", "deprecated", "do", "double",
    "else", "enum", "export", "extern",
    "false", "final", "finally", "float", "for", "foreach", "foreach_reverse",
    "function",
    "goto",
    "idouble", "if", "ifloat", "immutable", "import", "in", "inout", "int",
    "interface", "invariant", "ireal", "is",
    "lazy", "long",
    "macro", "mixin", "module",
    "new", "nothrow", "null",
    "out", "override",
    "package", "pragma", "private", "protected", "public", "pure",
    "real", "ref", "return",
    "scope", "shared", "short", "static", "struct", "super", "switch",
    "synchronized",
    "template", "this", "throw", "true", "try", "typeid", "typeof",
    "ubyte", "ucent", "uint", "ulong", "union", "unittest", "ushort",
    "version", "void", "volatile",
    "wchar", "while", "with",
    "__FILE__", "__LINE__", "__gshared", "__traits", "__vector",
}


def _safe_id(code: str) -> str:
    safe = code.replace("-", "_")
    if safe in _D_RESERVED:
        return f"{safe}_"
    return safe


def _quote(s: str) -> str:
    escaped = s.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def _str_array(items: list[str]) -> str:
    """Emit a D static array literal of strings."""
    return "[" + ", ".join(_quote(s) for s in items) + "]"


def _emit_locale_block(data: dict) -> list[str]:
    """Emit a single locale as a block within the all-locales file."""
    code = data["code"]
    name = data["name"]
    safe = _safe_id(code)

    lines = []
    lines.append(f"// {locale_source_comment(code).strip()}")
    lines.append(f"// {name} locale.")
    lines.append(f"immutable DateLocale {safe.upper()} = DateLocale(")
    lines.append(f"    code: {_quote(code)},")
    lines.append(f"    months: {_str_array(data['months'])},")
    lines.append(f"    weekdays: {_str_array(data['weekdays'])},")
    lines.append(f"    dayFormat: {_quote(data['dayFormat'])},")

    # Day format exceptions
    if "dayFormatExceptions" in data and data["dayFormatExceptions"]:
        exc = data["dayFormatExceptions"]
        pairs = []
        for k in sorted(exc.keys(), key=lambda x: int(x)):
            pairs.append(f"        DayFormatException({k}, {_quote(exc[k])})")
        lines.append("    dayFormatExceptions: [")
        lines.append(",\n".join(pairs))
        lines.append("    ],")
    else:
        lines.append("    dayFormatExceptions: [],")

    lines.append(f"    datePattern: {_quote(data['datePattern'])},")
    lines.append(f"    datePatternWithYear: {_quote(data['datePatternWithYear'])},")
    lines.append(f"    today: {_quote(data['today'])},")
    lines.append(f"    tomorrow: {_quote(data['tomorrow'])},")
    lines.append(f"    yesterday: {_quote(data['yesterday'])},")

    # Optional fields
    if "dayAfterTomorrow" in data:
        lines.append(f"    dayAfterTomorrow: nullable({_quote(data['dayAfterTomorrow'])}),")
    if "dayBeforeYesterday" in data:
        lines.append(f"    dayBeforeYesterday: nullable({_quote(data['dayBeforeYesterday'])}),")
    if "thisWeekday" in data:
        lines.append(f"    thisWeekday: nullable({_quote(data['thisWeekday'])}),")
    if "nextWeekday" in data:
        lines.append(f"    nextWeekday: nullable({_quote(data['nextWeekday'])}),")
    if "lastWeekday" in data:
        lines.append(f"    lastWeekday: nullable({_quote(data['lastWeekday'])}),")
    if "monthsInDate" in data:
        lines.append(f"    monthsInDate: NullableStringArray({_str_array(data['monthsInDate'])}),")

    # Short override
    if "short" in data:
        ovr = data["short"]
        lines.append("    short_: DateCompactnessOverride(")
        if "months" in ovr:
            lines.append(f"        months: NullableStringArray({_str_array(ovr['months'])}),")
        if "weekdays" in ovr:
            lines.append(f"        weekdays: NullableStringArray({_str_array(ovr['weekdays'])}),")
        if "dayFormat" in ovr:
            lines.append(f"        dayFormat: nullable({_quote(ovr['dayFormat'])}),")
        if "dayFormatExceptions" in ovr:
            exc = ovr["dayFormatExceptions"]
            pairs = []
            for k in sorted(exc.keys(), key=lambda x: int(x)):
                pairs.append(f"            DayFormatException({k}, {_quote(exc[k])})")
            lines.append("        dayFormatExceptions: [")
            lines.append(",\n".join(pairs))
            lines.append("        ],")
        if "datePattern" in ovr:
            lines.append(f"        datePattern: nullable({_quote(ovr['datePattern'])}),")
        if "datePatternWithYear" in ovr:
            lines.append(f"        datePatternWithYear: nullable({_quote(ovr['datePatternWithYear'])}),")
        lines.append("    ),")

    # Compact override
    if "compact" in data:
        ovr = data["compact"]
        lines.append("    compact_: DateCompactnessOverride(")
        if "datePattern" in ovr:
            lines.append(f"        datePattern: nullable({_quote(ovr['datePattern'])}),")
        if "datePatternWithYear" in ovr:
            lines.append(f"        datePatternWithYear: nullable({_quote(ovr['datePatternWithYear'])}),")
        lines.append("    ),")

    lines.append(");")
    return lines


def emit_locale(data: dict) -> str:
    """Not used in single-file strategy — exists for API compatibility."""
    return ""


def emit_barrel(all_locales: list[dict]) -> str:
    """Generate a single locales.d with all locale data + getLocale."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER]
    lines.append("// All locale data for sayable-date.\n")
    lines.append("module sayabledate.locales;")
    lines.append("")
    lines.append("import sayabledate.locale;")
    lines.append("")

    # Emit all locale definitions
    for loc in sorted_locs:
        block = _emit_locale_block(loc)
        lines.extend(block)
        lines.append("")

    # getLocale function
    lines.append("/// Returns the locale for the given code, or null if not found.")
    lines.append("const(DateLocale)* getLocale(string code) {")
    lines.append("    switch (code) {")
    for loc in sorted_locs:
        code = loc["code"]
        safe = _safe_id(code)
        lines.append(f"        case {_quote(code)}: return &{safe.upper()};")
    lines.append("        default: return null;")
    lines.append("    }")
    lines.append("}")
    lines.append("")

    return "\n".join(lines)


def output_path(code: str, root: str) -> str:
    """Not used in single-file strategy."""
    import os
    return os.path.join(root, "impl", "d", "source", "sayabledate", "locales", "UNUSED")


def barrel_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "d", "source", "sayabledate", "locales.d")
