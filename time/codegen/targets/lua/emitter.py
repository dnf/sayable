"""Lua locale emitter for sayable-time."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header

HEADER = make_header("codegen/targets/lua/emitter.py", line_prefix="-- ")


def _quote(s: str) -> str:
    """Quote a string for Lua."""
    escaped = s.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def _str_list(items: list[str]) -> str:
    """Emit a Lua array of strings."""
    return "{ " + ", ".join(_quote(s) for s in items) + " }"


def emit_locale(data: dict) -> str:
    """Generate a Lua locale file from canonical JSON."""
    code = data["code"]
    clock = data["clock"]
    lines = [HEADER + locale_source_comment(code, line_prefix="-- ")]

    # Module table
    lines.append("local M = {}")
    lines.append("")
    lines.append(f"M.code = {_quote(code)}")

    # Clock config
    lines.append("M.clock = {")
    lines.append(f"    hours = {_str_list(clock['hours'])},")
    lines.append(f"    midnight = {_quote(clock['midnight'])},")
    lines.append(f"    noon = {_quote(clock['noon'])},")
    lines.append("    patterns = {")
    for key in ("0", "5", "10", "15", "20", "25", "30", "35", "40", "45", "50", "55"):
        if key in clock["patterns"]:
            lines.append(f"        [{key}] = {_quote(clock['patterns'][key])},")
    lines.append("    },")
    lines.append("}")

    # Short/compact overrides
    for mode in ("short", "compact"):
        if mode in data:
            ovr = data[mode]
            sc = ovr.get("clock", {})
            use24h = sc.get("use24h", True)
            fmt = sc.get("format", "{h}:{mm}")
            am_pm = sc.get("amPm")
            lines.append(f"M.{mode} = {{")
            lines.append("    clock = {")
            lines.append(f"        use24h = {str(use24h).lower()},")
            lines.append(f"        format = {_quote(fmt)},")
            if am_pm:
                lines.append(f"        am_pm = {{ {_quote(am_pm[0])}, {_quote(am_pm[1])} }},")
            lines.append("    },")
            lines.append("}")

    lines.append("")
    lines.append("return M")
    lines.append("")

    return "\n".join(lines)


def emit_barrel(all_locales: list[dict]) -> str:
    """Generate the registry module that maps locale codes to modules."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER]
    lines.append("local M = {}")
    lines.append("")
    lines.append("local cache = {}")
    lines.append("")
    lines.append("function M.get_locale(code)")
    lines.append("    if cache[code] ~= nil then return cache[code] end")

    for loc in sorted_locs:
        code = loc["code"]
        lines.append(f'    if code == "{code}" then')
        lines.append(f'        cache[code] = require("locales.{code}")')
        lines.append(f"        return cache[code]")
        lines.append("    end")

    lines.append("    return nil")
    lines.append("end")
    lines.append("")
    lines.append("return M")
    lines.append("")

    return "\n".join(lines)


def output_path(code: str, root: str) -> str:
    import os
    return os.path.join(root, "impl", "lua", "locales", f"{code}.lua")


def barrel_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "lua", "locales", "init.lua")
