"""Julia locale emitter for sayable-time."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header

HEADER = make_header("codegen/targets/julia/emitter.py", line_prefix="# ")


def _quote(s: str) -> str:
    """Quote a string for Julia."""
    escaped = s.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def _str_list(items: list[str]) -> str:
    """Emit a Julia vector of strings on one line."""
    return "[" + ", ".join(_quote(s) for s in items) + "]"


def emit_locale(data: dict) -> str:
    """Generate a Julia locale file from canonical JSON."""
    code = data["code"]
    name = data["name"]
    clock = data["clock"]
    lines = [HEADER + locale_source_comment(code, line_prefix="# "), f"# {name} locale.\n"]

    # Locale constant
    lines.append(f"const {code.upper()} = TimeLocale(")
    lines.append(f"    code = {_quote(code)},")

    # Clock config
    lines.append("    clock = ClockConfig(")
    lines.append(f"        hours = {_str_list(clock['hours'])},")
    lines.append(f"        midnight = {_quote(clock['midnight'])},")
    lines.append(f"        noon = {_quote(clock['noon'])},")
    lines.append("        patterns = Dict{Int, String}(")
    for key in ("0", "5", "10", "15", "20", "25", "30", "35", "40", "45", "50", "55"):
        if key in clock["patterns"]:
            lines.append(f"            {key} => {_quote(clock['patterns'][key])},")
    lines.append("        ),")
    lines.append("    ),")

    # Short override
    has_short = "short" in data
    has_compact = "compact" in data

    if has_short:
        sc = data["short"].get("clock", {})
        use24h = "true" if sc.get("use24h", True) else "false"
        fmt = sc.get("format", "{h}:{mm}")
        am_pm = sc.get("amPm")
        if am_pm:
            lines.append("    short_override = TimeCompactnessOverride(")
            lines.append(f"        clock = ShortClockConfig(use24h = {use24h}, format = {_quote(fmt)}, am_pm = ({_quote(am_pm[0])}, {_quote(am_pm[1])})),")
            lines.append("    ),")
        else:
            lines.append("    short_override = TimeCompactnessOverride(")
            lines.append(f"        clock = ShortClockConfig(use24h = {use24h}, format = {_quote(fmt)}),")
            lines.append("    ),")

    # Compact override
    if has_compact:
        sc = data["compact"].get("clock", {})
        use24h = "true" if sc.get("use24h", True) else "false"
        fmt = sc.get("format", "{h}:{mm}")
        am_pm = sc.get("amPm")
        if am_pm:
            lines.append("    compact_override = TimeCompactnessOverride(")
            lines.append(f"        clock = ShortClockConfig(use24h = {use24h}, format = {_quote(fmt)}, am_pm = ({_quote(am_pm[0])}, {_quote(am_pm[1])})),")
            lines.append("    ),")
        else:
            lines.append("    compact_override = TimeCompactnessOverride(")
            lines.append(f"        clock = ShortClockConfig(use24h = {use24h}, format = {_quote(fmt)}),")
            lines.append("    ),")

    lines.append(")")
    lines.append("")

    return "\n".join(lines)


def emit_barrel(all_locales: list[dict]) -> str:
    """Generate the locales/registry.jl barrel file."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER, "# Locale registry for all supported languages.\n"]

    # Include all locale files
    for loc in sorted_locs:
        code = loc["code"]
        lines.append(f'include("{code}.jl")')

    lines.append("")

    # Lookup dict + function
    lines.append("const _ALL = Dict{String, TimeLocale}(")
    for loc in sorted_locs:
        code = loc["code"]
        lines.append(f'    "{code}" => {code.upper()},')
    lines.append(")")
    lines.append("")
    lines.append("function get_locale(code::String)::Union{TimeLocale, Nothing}")
    lines.append("    get(_ALL, code, nothing)")
    lines.append("end")
    lines.append("")

    return "\n".join(lines)


def output_path(code: str, root: str) -> str:
    import os
    return os.path.join(root, "impl", "julia", "src", "locales", f"{code}.jl")


def barrel_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "julia", "src", "locales", "registry.jl")
