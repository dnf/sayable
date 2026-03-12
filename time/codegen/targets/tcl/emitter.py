"""Tcl locale emitter for sayable-time."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header

HEADER = make_header("codegen/targets/tcl/emitter.py", line_prefix="# ")


def _quote(s: str) -> str:
    """Quote a string for Tcl — use braces for literal strings."""
    if "{" in s or "}" in s or "\\" in s:
        escaped = s.replace("\\", "\\\\").replace('"', '\\"').replace("[", "\\[").replace("$", "\\$")
        return f'"{escaped}"'
    return "{" + s + "}"


def _str_list(items: list[str]) -> str:
    """Emit a Tcl list of strings."""
    return "[list " + " ".join(_quote(s) for s in items) + "]"


def emit_locale(data: dict) -> str:
    """Generate a Tcl locale file from canonical JSON."""
    code = data["code"]
    clock = data["clock"]

    lines = [HEADER + locale_source_comment(code, line_prefix="# ")]

    # Locale proc that returns a dict
    lines.append(f"proc locale_time_{code} {{}} {{")
    lines.append(f"    set code {_quote(code)}")

    # Clock config
    lines.append(f"    set hours {_str_list(clock['hours'])}")
    lines.append(f"    set midnight {_quote(clock['midnight'])}")
    lines.append(f"    set noon {_quote(clock['noon'])}")

    # Patterns dict
    lines.append("    set patterns [dict create \\")
    for key in ["0", "5", "10", "15", "20", "25", "30", "35", "40", "45", "50", "55"]:
        if key in clock["patterns"]:
            lines.append(f"        {key} {_quote(clock['patterns'][key])} \\")
    lines.append("    ]")

    lines.append("    set clock_config [dict create \\")
    lines.append("        hours $hours \\")
    lines.append("        midnight $midnight \\")
    lines.append("        noon $noon \\")
    lines.append("        patterns $patterns \\")
    lines.append("    ]")

    # Short/compact overrides
    for mode in ("short", "compact"):
        if mode in data:
            sc = data[mode].get("clock", {})
            use24h = "1" if sc.get("use24h", True) else "0"
            fmt = sc.get("format", "{h}:{mm}")
            am_pm = sc.get("amPm")
            lines.append(f"    set {mode} [dict create \\")
            lines.append(f"        clock [dict create \\")
            lines.append(f"            use24h {use24h} \\")
            lines.append(f"            format {_quote(fmt)} \\")
            if am_pm:
                lines.append(f"            am {_quote(am_pm[0])} \\")
                lines.append(f"            pm {_quote(am_pm[1])} \\")
            else:
                lines.append(f'            am "" \\')
                lines.append(f'            pm "" \\')
            lines.append("        ] \\")
            lines.append("    ]")
        else:
            lines.append(f"    set {mode} [dict create]")

    # Build the locale dict
    lines.append("    return [dict create \\")
    lines.append("        code $code \\")
    lines.append("        clock $clock_config \\")
    lines.append("        short $short \\")
    lines.append("        compact $compact \\")
    lines.append("    ]")
    lines.append("}")
    lines.append("")

    return "\n".join(lines)


def emit_registry(all_locales: list[dict]) -> str:
    """Generate registry.tcl with get_locale proc."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER]

    # Source all locale files
    lines.append("# Source all locale files relative to this script's directory")
    lines.append("set _sayabletime_locales_dir [file dirname [info script]]")
    lines.append("")
    for loc in sorted_locs:
        code = loc["code"]
        lines.append(f'source [file join $_sayabletime_locales_dir "{code}.tcl"]')
    lines.append("")

    # Registry dict
    lines.append("# Build locale registry")
    lines.append("proc _sayabletime_build_registry {} {")
    lines.append("    set registry [dict create]")
    for loc in sorted_locs:
        code = loc["code"]
        lines.append(f"    dict set registry {_quote(code)} [locale_time_{code}]")
    lines.append("    return $registry")
    lines.append("}")
    lines.append("")
    lines.append("set ::_sayabletime_registry [_sayabletime_build_registry]")
    lines.append("")

    # get_locale
    lines.append("proc sayabletime_get_locale {code} {")
    lines.append("    if {[dict exists $::_sayabletime_registry $code]} {")
    lines.append("        return [dict get $::_sayabletime_registry $code]")
    lines.append("    }")
    lines.append('    return ""')
    lines.append("}")
    lines.append("")

    return "\n".join(lines)


def output_path(code: str, root: str) -> str:
    import os
    return os.path.join(root, "impl", "tcl", "locales", f"{code}.tcl")


def registry_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "tcl", "locales", "registry.tcl")
