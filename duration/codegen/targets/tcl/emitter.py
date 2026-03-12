"""Tcl locale emitter for sayable-duration."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header
from codegen.targets.tcl.plural_rules import get_tcl_plural

HEADER = make_header("codegen/targets/tcl/emitter.py", line_prefix="# ")


def _quote(s: str) -> str:
    """Quote a string for Tcl — use braces for literal strings."""
    if "{" in s or "}" in s or "\\" in s:
        escaped = s.replace("\\", "\\\\").replace('"', '\\"').replace("[", "\\[").replace("$", "\\$")
        return f'"{escaped}"'
    return "{" + s + "}"


def _unit_forms(unit: object) -> str:
    """Emit a unit forms value as a Tcl dict."""
    if isinstance(unit, str):
        return _quote(unit)
    cats = ["zero", "one", "two", "few", "many", "other"]
    pairs = []
    for cat in cats:
        if cat in unit:
            pairs.append(f"{cat} {_quote(unit[cat])}")
    return "[dict create " + " ".join(pairs) + "]"


def emit_locale(data: dict) -> str:
    code = data["code"]
    rule = data["pluralRule"]

    lines = [HEADER + locale_source_comment(code, line_prefix="# ")]

    # Plural rule proc
    plural_body = get_tcl_plural(rule).replace("$CODE", code)
    lines.append(plural_body)
    lines.append("")

    # Locale proc that returns a dict
    lines.append(f"proc locale_duration_{code} {{}} {{")
    lines.append(f"    set code {_quote(code)}")

    # Units (7 time units for duration)
    lines.append("    set units [dict create \\")
    for unit_name in ("second", "minute", "hour", "day", "week", "month", "year"):
        val = _unit_forms(data["units"][unit_name])
        lines.append(f"        {unit_name} {val} \\")
    lines.append("    ]")

    # Simple fields
    lines.append(f"    set half {_quote(data['half'])}")
    lines.append(f"    set delimiter {_quote(data['delimiter'])}")
    lines.append(f"    set just_now {_quote(data['justNow'])}")
    lines.append(f"    set ago {_quote(data['ago'])}")
    lines.append(f"    set in_future {_quote(data['inFuture'])}")

    # Short/compact overrides
    for mode in ("short", "compact"):
        if mode in data:
            ovr = data[mode]
            lines.append(f"    set {mode} [dict create \\")
            if "units" in ovr:
                unit_parts = []
                for unit_name in ("second", "minute", "hour", "day", "week", "month", "year"):
                    if unit_name in ovr["units"]:
                        val = _unit_forms(ovr["units"][unit_name])
                        unit_parts.append(f"            {unit_name} {val}")
                lines.append("        units [dict create \\")
                for p in unit_parts:
                    lines.append(p + " \\")
                lines.append("        ] \\")
            if "half" in ovr:
                lines.append(f"        half {_quote(ovr['half'])} \\")
            if "delimiter" in ovr:
                lines.append(f"        delimiter {_quote(ovr['delimiter'])} \\")
            if "ago" in ovr:
                lines.append(f"        ago {_quote(ovr['ago'])} \\")
            if "inFuture" in ovr:
                lines.append(f"        in_future {_quote(ovr['inFuture'])} \\")
            lines.append("    ]")
        else:
            lines.append(f"    set {mode} [dict create]")

    # Build the locale dict
    lines.append("    return [dict create \\")
    lines.append(f"        code $code \\")
    lines.append(f"        plural plural_{code} \\")
    lines.append(f"        units $units \\")
    lines.append(f"        half $half \\")
    lines.append(f"        delimiter $delimiter \\")
    lines.append(f"        just_now $just_now \\")
    lines.append(f"        ago $ago \\")
    lines.append(f"        in_future $in_future \\")
    lines.append(f"        short $short \\")
    lines.append(f"        compact $compact \\")
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
    lines.append("set _sayableduration_locales_dir [file dirname [info script]]")
    lines.append("")
    for loc in sorted_locs:
        code = loc["code"]
        lines.append(f'source [file join $_sayableduration_locales_dir "{code}.tcl"]')
    lines.append("")

    # Registry dict
    lines.append("# Build locale registry")
    lines.append("proc _sayableduration_build_registry {} {")
    lines.append("    set registry [dict create]")
    for loc in sorted_locs:
        code = loc["code"]
        lines.append(f"    dict set registry {_quote(code)} [locale_duration_{code}]")
    lines.append("    return $registry")
    lines.append("}")
    lines.append("")
    lines.append("set ::_sayableduration_registry [_sayableduration_build_registry]")
    lines.append("")

    # get_locale
    lines.append("proc sayableduration_get_locale {code} {")
    lines.append("    if {[dict exists $::_sayableduration_registry $code]} {")
    lines.append("        return [dict get $::_sayableduration_registry $code]")
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
