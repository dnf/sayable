"""Odin locale emitter for sayable-time — single file with all locales.

Odin's package system equates directories with packages. The generated locale
file lives in the main package directory as the language-idiomatic equivalent.
"""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header

HEADER = make_header("codegen/targets/odin/emitter.py")

_ODIN_KEYWORDS = frozenset([
    "auto_cast", "bit_set", "break", "case", "cast", "context", "continue",
    "defer", "distinct", "do", "dynamic", "else", "enum", "fallthrough",
    "for", "foreign", "if", "import", "in", "map", "matrix", "not_in",
    "or_else", "or_return", "package", "proc", "return", "struct", "switch",
    "transmute", "typeid", "union", "using", "when", "where",
])


def _ident(name: str) -> str:
    if name in _ODIN_KEYWORDS or (name and name[0].isdigit()):
        return f'`{name}`'
    return name


def _quote(s: str) -> str:
    escaped = s.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def _str_list(items: list[str]) -> str:
    parts = ", ".join(_quote(s) for s in items)
    return "{" + parts + "}"


def emit_all(all_locales: list[dict]) -> str:
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])

    lines = [HEADER]
    lines.append("package sayabletime")
    lines.append("")

    for data in sorted_locs:
        code = data["code"]
        var_name = "locale_" + code.replace("-", "_")
        clock = data["clock"]

        lines.append(locale_source_comment(code).rstrip())
        lines.append(f"{_ident(var_name)} : Time_Locale = {{")
        lines.append(f"    code = {_quote(code)},")

        # clock config
        lines.append("    clock = Clock_Config{")
        lines.append(f"        hours = {_str_list(clock['hours'])},")
        lines.append(f"        midnight = {_quote(clock['midnight'])},")
        lines.append(f"        noon = {_quote(clock['noon'])},")

        # patterns: map of int -> string
        patterns = clock["patterns"]
        pat_parts = []
        for k in sorted(patterns.keys(), key=lambda x: int(x)):
            pat_parts.append(f"Clock_Pattern{{minute = {k}, pattern = {_quote(patterns[k])}}}")
        lines.append(f"        patterns = {{{', '.join(pat_parts)}}},")
        lines.append("    },")

        # short override
        if "short" in data and "clock" in data["short"]:
            sc = data["short"]["clock"]
            lines.append("    short_override = Time_Compactness_Override{")
            lines.append("        clock = Short_Clock_Config{")
            lines.append(f"            use_24h = {'true' if sc['use24h'] else 'false'},")
            lines.append(f"            format = {_quote(sc['format'])},")
            if "amPm" in sc:
                lines.append(f"            am_pm = [2]string{{{_quote(sc['amPm'][0])}, {_quote(sc['amPm'][1])}}},")
            else:
                lines.append("            am_pm = nil,")
            lines.append("        },")
            lines.append("    },")
        else:
            lines.append("    short_override = nil,")

        # compact override
        if "compact" in data and "clock" in data["compact"]:
            sc = data["compact"]["clock"]
            lines.append("    compact_override = Time_Compactness_Override{")
            lines.append("        clock = Short_Clock_Config{")
            lines.append(f"            use_24h = {'true' if sc['use24h'] else 'false'},")
            lines.append(f"            format = {_quote(sc['format'])},")
            if "amPm" in sc:
                lines.append(f"            am_pm = [2]string{{{_quote(sc['amPm'][0])}, {_quote(sc['amPm'][1])}}},")
            else:
                lines.append("            am_pm = nil,")
            lines.append("        },")
            lines.append("    },")
        else:
            lines.append("    compact_override = nil,")

        lines.append("}")
        lines.append("")

    # get_locale function
    lines.append("get_locale :: proc(code: string) -> ^Time_Locale {")
    lines.append("    switch code {")
    for data in sorted_locs:
        c = data["code"]
        var_name = "locale_" + c.replace("-", "_")
        lines.append(f'    case {_quote(c)}: return &{_ident(var_name)}')
    lines.append("    case: return nil")
    lines.append("    }")
    lines.append("}")
    lines.append("")

    return "\n".join(lines)


def output_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "odin", "locales.odin")
