"""D locale emitter for sayable-time — single-file strategy."""

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


def _emit_short_clock(sc: dict) -> str:
    """Emit a ShortClockConfig struct literal."""
    use24h = "true" if sc.get("use24h", True) else "false"
    fmt = sc.get("format", "{h}:{mm}")
    am_pm = sc.get("amPm")
    parts = [f"use24h: {use24h}", f"format: {_quote(fmt)}"]
    if am_pm:
        parts.append(f"amPm: nullable(AmPm({_quote(am_pm[0])}, {_quote(am_pm[1])}))")
    parts.append("isSet: true")
    return "ShortClockConfig(" + ", ".join(parts) + ")"


def _emit_locale_block(data: dict) -> list[str]:
    """Emit a single locale as a block within the all-locales file."""
    code = data["code"]
    name = data["name"]
    clock = data["clock"]
    safe = _safe_id(code)

    lines = []
    lines.append(f"// {locale_source_comment(code).strip()}")
    lines.append(f"// {name} locale.")
    lines.append(f"immutable TimeLocale {safe.upper()} = TimeLocale(")
    lines.append(f"    code: {_quote(code)},")

    # Clock config
    lines.append("    clock: ClockConfig(")
    lines.append(f"        hours: {_str_array(clock['hours'])},")
    lines.append(f"        midnight: {_quote(clock['midnight'])},")
    lines.append(f"        noon: {_quote(clock['noon'])},")

    # Patterns — emit as array of PatternEntry
    lines.append("        patterns: [")
    for key in ["0", "5", "10", "15", "20", "25", "30", "35", "40", "45", "50", "55"]:
        if key in clock["patterns"]:
            lines.append(f"            PatternEntry({key}, {_quote(clock['patterns'][key])}),")
    lines.append("        ],")
    lines.append("    ),")

    # Short override
    if "short" in data:
        sc = data["short"].get("clock", {})
        lines.append("    short_: TimeCompactnessOverride(")
        lines.append(f"        clock: {_emit_short_clock(sc)},")
        lines.append("    ),")

    # Compact override
    if "compact" in data:
        sc = data["compact"].get("clock", {})
        lines.append("    compact_: TimeCompactnessOverride(")
        lines.append(f"        clock: {_emit_short_clock(sc)},")
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
    lines.append("// All locale data for sayable-time.\n")
    lines.append("module sayabletime.locales;")
    lines.append("")
    lines.append("import sayabletime.locale;")
    lines.append("")

    # Emit all locale definitions
    for loc in sorted_locs:
        block = _emit_locale_block(loc)
        lines.extend(block)
        lines.append("")

    # getLocale function
    lines.append("/// Returns the locale for the given code, or null if not found.")
    lines.append("const(TimeLocale)* getLocale(string code) {")
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
    return os.path.join(root, "impl", "d", "source", "sayabletime", "locales", "UNUSED")


def barrel_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "d", "source", "sayabletime", "locales.d")
