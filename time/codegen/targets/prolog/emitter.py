"""Prolog locale emitter for sayable-time."""

from __future__ import annotations

import os

from codegen.banner import locale_source_comment, make_header

HEADER = make_header("codegen/targets/prolog/emitter.py", line_prefix="% ")


def _quote(s: str) -> str:
    """Quote a string as a Prolog atom using single quotes."""
    escaped = s.replace("\\", "\\\\").replace("'", "\\'")
    return f"'{escaped}'"


def _list(items: list[str]) -> str:
    """Emit a Prolog list of quoted atoms."""
    return "[" + ", ".join(_quote(s) for s in items) + "]"


def emit_locale(data: dict) -> str:
    """Generate a Prolog locale file from canonical JSON."""
    code = data["code"]
    name = data["name"]
    clock = data["clock"]

    lines = [HEADER + locale_source_comment(code, line_prefix="% ")]
    lines.append(f"% {name} locale.\n")

    # Clock hours
    lines.append(f"st_hours({_quote(code)}, {_list(clock['hours'])}).")

    # Midnight and noon
    lines.append(f"st_midnight({_quote(code)}, {_quote(clock['midnight'])}).")
    lines.append(f"st_noon({_quote(code)}, {_quote(clock['noon'])}).")
    lines.append("")

    # Clock patterns
    for key in ["0", "5", "10", "15", "20", "25", "30", "35", "40", "45", "50", "55"]:
        if key in clock["patterns"]:
            lines.append(f"st_pattern({_quote(code)}, {key}, {_quote(clock['patterns'][key])}).")
    lines.append("")

    # Short override
    if "short" in data and "clock" in data["short"]:
        sc = data["short"]["clock"]
        use24h = "true" if sc.get("use24h", True) else "false"
        fmt = sc.get("format", "{h}:{mm}")
        lines.append(f"short_st_use24h({_quote(code)}, {use24h}).")
        lines.append(f"short_st_format({_quote(code)}, {_quote(fmt)}).")
        if "amPm" in sc:
            lines.append(f"short_st_am({_quote(code)}, {_quote(sc['amPm'][0])}).")
            lines.append(f"short_st_pm({_quote(code)}, {_quote(sc['amPm'][1])}).")
        lines.append("")

    # Compact override
    if "compact" in data and "clock" in data["compact"]:
        sc = data["compact"]["clock"]
        use24h = "true" if sc.get("use24h", True) else "false"
        fmt = sc.get("format", "{h}:{mm}")
        lines.append(f"compact_st_use24h({_quote(code)}, {use24h}).")
        lines.append(f"compact_st_format({_quote(code)}, {_quote(fmt)}).")
        if "amPm" in sc:
            lines.append(f"compact_st_am({_quote(code)}, {_quote(sc['amPm'][0])}).")
            lines.append(f"compact_st_pm({_quote(code)}, {_quote(sc['amPm'][1])}).")
        lines.append("")

    return "\n".join(lines)


def emit_barrel(all_locales: list[dict]) -> str:
    """Generate the locales/registry.pl barrel file."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER, "% Locale registry — loads all locale files.\n"]

    # Discontiguous declarations
    lines.append(":- discontiguous st_hours/2.")
    lines.append(":- discontiguous st_midnight/2.")
    lines.append(":- discontiguous st_noon/2.")
    lines.append(":- discontiguous st_pattern/3.")
    lines.append(":- discontiguous short_st_use24h/2.")
    lines.append(":- discontiguous short_st_format/2.")
    lines.append(":- discontiguous short_st_am/2.")
    lines.append(":- discontiguous short_st_pm/2.")
    lines.append(":- discontiguous compact_st_use24h/2.")
    lines.append(":- discontiguous compact_st_format/2.")
    lines.append(":- discontiguous compact_st_am/2.")
    lines.append(":- discontiguous compact_st_pm/2.")
    lines.append("")

    # Include all locale files
    for loc in sorted_locs:
        code = loc["code"]
        lines.append(f":- include('{code}').")

    lines.append("")

    # st_locale/1: succeeds if code is known
    lines.append("% st_locale(+Code) - succeeds if Code is a known locale.")
    for loc in sorted_locs:
        lines.append(f"st_locale({_quote(loc['code'])}).")
    lines.append("")

    return "\n".join(lines)


def output_path(code: str, root: str) -> str:
    return os.path.join(root, "impl", "prolog", "locales", f"{code}.pl")


def barrel_path(root: str) -> str:
    return os.path.join(root, "impl", "prolog", "locales", "registry.pl")
