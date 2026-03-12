"""D locale emitter for sayable-duration — single-file strategy."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header
from codegen.targets.d.plural_rules import get_d_plural

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


def _unit_forms(unit: object) -> str:
    if isinstance(unit, str):
        return f"simpleUnit({_quote(unit)})"
    cats = ["zero", "one", "two", "few", "many", "other"]
    parts = []
    for cat in cats:
        if cat in unit:
            parts.append(f"{cat}: {_quote(unit[cat])}")
    return "makePluralUnit(" + ", ".join(parts) + ")"


def _emit_locale_block(data: dict) -> list[str]:
    """Emit a single locale as a block within the all-locales file."""
    code = data["code"]
    rule = data["pluralRule"]
    name = data["name"]
    safe = _safe_id(code)

    lines = []
    lines.append(f"// {locale_source_comment(code).strip()}")
    lines.append(f"// {name} locale.")
    lines.append(f"immutable DurationLocale {safe.upper()} = DurationLocale(")
    lines.append(f"    code: {_quote(code)},")

    plural = get_d_plural(rule)
    lines.append(f"    plural: {plural.strip()},")

    for unit_name in ("second", "minute", "hour", "day", "week", "month", "year"):
        val = _unit_forms(data["units"][unit_name])
        lines.append(f"    {unit_name}: {val},")

    lines.append(f"    half: {_quote(data['half'])},")
    lines.append(f"    delimiter: {_quote(data['delimiter'])},")
    lines.append(f"    justNow: {_quote(data['justNow'])},")
    lines.append(f"    ago: {_quote(data['ago'])},")
    lines.append(f"    inFuture: {_quote(data['inFuture'])},")

    for mode in ("short", "compact"):
        if mode in data:
            ovr = data[mode]
            field = "short_" if mode == "short" else "compact_"
            lines.append(f"    {field}: DurationCompactnessOverride(")
            if "units" in ovr:
                for unit_name in ("second", "minute", "hour", "day", "week", "month", "year"):
                    if unit_name in ovr["units"]:
                        val = ovr["units"][unit_name]
                        if isinstance(val, str):
                            lines.append(f"        {unit_name}: simpleUnit({_quote(val)}),")
                        else:
                            lines.append(f"        {unit_name}: {_unit_forms(val)},")
            if "delimiter" in ovr:
                lines.append(f"        delimiter: nullable({_quote(ovr['delimiter'])}),")
            if "half" in ovr:
                lines.append(f"        half: nullable({_quote(ovr['half'])}),")
            if "ago" in ovr:
                lines.append(f"        ago: nullable({_quote(ovr['ago'])}),")
            if "inFuture" in ovr:
                lines.append(f"        inFuture: nullable({_quote(ovr['inFuture'])}),")
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
    lines.append("// All locale data for sayable-duration.\n")
    lines.append("module sayableduration.locales;")
    lines.append("")
    lines.append("import sayableduration.locale;")
    lines.append("")

    # Emit all locale definitions
    for loc in sorted_locs:
        block = _emit_locale_block(loc)
        lines.extend(block)
        lines.append("")

    # getLocale function
    lines.append("/// Returns the locale for the given code, or null if not found.")
    lines.append("const(DurationLocale)* getLocale(string code) {")
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
    return os.path.join(root, "impl", "d", "source", "sayableduration", "locales", "UNUSED")


def barrel_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "d", "source", "sayableduration", "locales.d")
