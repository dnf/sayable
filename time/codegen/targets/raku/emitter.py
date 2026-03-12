"""Raku locale emitter for sayable-time."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header

HEADER = make_header("codegen/targets/raku/emitter.py", line_prefix="# ")


def _quote(s: str) -> str:
    escaped = s.replace("\\", "\\\\").replace("'", "\\'")
    return f"'{escaped}'"


def _str_list(items: list[str]) -> str:
    return "(" + ", ".join(_quote(s) for s in items) + ")"


def emit_locale(data: dict) -> str:
    code = data["code"]
    uc = code.upper()
    clock = data["clock"]

    lines = []
    lines.append("use v6.d;")
    lines.append("")
    lines.append((HEADER + locale_source_comment(code, line_prefix="# ")).rstrip())
    lines.append(f"unit module SayableTime::Locales::{uc};")
    lines.append("")
    lines.append("our sub locale() {")
    lines.append("    {")

    # Code
    lines.append(f"        code => {_quote(code)},")

    # Clock config
    lines.append("        clock => {")
    lines.append(f"            hours => {_str_list(clock['hours'])},")
    lines.append(f"            midnight => {_quote(clock['midnight'])},")
    lines.append(f"            noon => {_quote(clock['noon'])},")
    lines.append("            patterns => {")
    for key in ("0", "5", "10", "15", "20", "25", "30", "35", "40", "45", "50", "55"):
        if key in clock["patterns"]:
            lines.append(f"                {key} => {_quote(clock['patterns'][key])},")
    lines.append("            },")
    lines.append("        },")

    # Short override
    if "short" in data:
        sc = data["short"].get("clock", {})
        use24h = "True" if sc.get("use24h", True) else "False"
        fmt = sc.get("format", "{h}:{mm}")
        am_pm = sc.get("amPm")
        lines.append("        short => {")
        lines.append("            clock => {")
        lines.append(f"                use24h => {use24h},")
        lines.append(f"                format => {_quote(fmt)},")
        if am_pm:
            lines.append(f"                am-pm => ({_quote(am_pm[0])}, {_quote(am_pm[1])}),")
        lines.append("            },")
        lines.append("        },")

    # Compact override
    if "compact" in data:
        sc = data["compact"].get("clock", {})
        use24h = "True" if sc.get("use24h", True) else "False"
        fmt = sc.get("format", "{h}:{mm}")
        am_pm = sc.get("amPm")
        lines.append("        compact => {")
        lines.append("            clock => {")
        lines.append(f"                use24h => {use24h},")
        lines.append(f"                format => {_quote(fmt)},")
        if am_pm:
            lines.append(f"                am-pm => ({_quote(am_pm[0])}, {_quote(am_pm[1])}),")
        lines.append("            },")
        lines.append("        },")

    lines.append("    }")
    lines.append("}")
    lines.append("")

    return "\n".join(lines)


def emit_barrel(all_locales: list[dict]) -> str:
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = ["use v6.d;", "", HEADER.rstrip()]
    lines.append("unit module SayableTime::Locales::Registry;")
    lines.append("")

    for loc in sorted_locs:
        uc = loc["code"].upper()
        lines.append(f"use SayableTime::Locales::{uc};")
    lines.append("")

    lines.append("my %locales = (")
    for loc in sorted_locs:
        code = loc["code"]
        uc = code.upper()
        lines.append(f"    '{code}' => SayableTime::Locales::{uc}::locale(),")
    lines.append(");")
    lines.append("")

    lines.append("our sub get-locale(Str $code) {")
    lines.append("    %locales{$code} // Nil;")
    lines.append("}")
    lines.append("")

    return "\n".join(lines)


def output_path(code: str, root: str) -> str:
    import os
    return os.path.join(root, "impl", "raku", "lib", "SayableTime", "Locales", f"{code.upper()}.rakumod")


def barrel_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "raku", "lib", "SayableTime", "Locales", "Registry.rakumod")
