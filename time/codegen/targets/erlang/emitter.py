"""Erlang locale emitter for sayable-time."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header

HEADER = make_header("codegen/targets/erlang/emitter.py", line_prefix="%% ")


def _module_name(code: str) -> str:
    """Convert locale code to Erlang module suffix (lowercase, underscores for hyphens)."""
    return code.replace("-", "_")


def _quote(s: str) -> str:
    escaped = s.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def _str_list_12(items: list[str]) -> str:
    """Emit an Erlang list of 12 strings (hours)."""
    return "[" + ", ".join(_quote(s) for s in items) + "]"


def _patterns_list(patterns: dict[str, str]) -> str:
    """Emit an Erlang proplist for minute patterns."""
    keys = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55]
    pairs = []
    for key in keys:
        skey = str(key)
        if skey in patterns:
            pairs.append(f"{{{key}, {_quote(patterns[skey])}}}")
    return "[" + ", ".join(pairs) + "]"


def _clock_override(clock: dict) -> str:
    """Emit a short_clock_config record for short/compact overrides."""
    use24h = "true" if clock.get("use24h", True) else "false"
    am_pm = clock.get("amPm")
    fmt = clock.get("format", "{h}:{mm}")

    if am_pm:
        return (f"#short_clock_config{{use24h = {use24h}, "
                f"format = {_quote(fmt)}, "
                f"am_pm = {{just, {{{_quote(am_pm[0])}, {_quote(am_pm[1])}}}}}}}")
    else:
        return (f"#short_clock_config{{use24h = {use24h}, "
                f"format = {_quote(fmt)}, "
                f"am_pm = nothing}}")


def emit_locale(data: dict) -> str:
    """Generate an Erlang locale file from canonical JSON."""
    code = data["code"]
    clock = data["clock"]
    mod = _module_name(code)

    lines = [HEADER + locale_source_comment(code, line_prefix="%% ")]
    lines.append(f"-module(sayabletime_locales_{mod}).")
    lines.append('-include("sayabletime.hrl").')
    lines.append("-export([locale/0]).")
    lines.append("")
    lines.append("locale() ->")
    lines.append("    #time_locale{")

    parts = []
    parts.append(f"        code = {_quote(code)}")
    parts.append(f"        clock = #clock_config{{hours = {_str_list_12(clock['hours'])}, midnight = {_quote(clock['midnight'])}, noon = {_quote(clock['noon'])}, patterns = {_patterns_list(clock['patterns'])}}}")

    # Short override
    if "short" in data:
        parts.append(f"        short = {{just, #time_compactness_override{{clock = {{just, {_clock_override(data['short']['clock'])}}}}}}}")
    else:
        parts.append("        short = nothing")

    # Compact override
    if "compact" in data:
        parts.append(f"        compact = {{just, #time_compactness_override{{clock = {{just, {_clock_override(data['compact']['clock'])}}}}}}}")
    else:
        parts.append("        compact = nothing")

    lines.append(",\n".join(parts))
    lines.append("    }.")
    lines.append("")

    return "\n".join(lines)


def emit_barrel(all_locales: list[dict]) -> str:
    """Generate the sayabletime_locales.erl barrel module."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER]
    lines.append("-module(sayabletime_locales).")
    lines.append('-include("sayabletime.hrl").')
    lines.append("-export([get_locale/1]).")
    lines.append("")

    for loc in sorted_locs:
        code = loc["code"]
        mod = _module_name(code)
        lines.append(f'get_locale({_quote(code)}) -> {{ok, sayabletime_locales_{mod}:locale()}};')

    lines.append("get_locale(_) -> error.")
    lines.append("")

    return "\n".join(lines)


def output_path(code: str, root: str) -> str:
    import os
    mod = _module_name(code)
    return os.path.join(root, "impl", "erlang", "src", "locales", f"sayabletime_locales_{mod}.erl")


def barrel_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "erlang", "src", "locales", "sayabletime_locales.erl")
