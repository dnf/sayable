"""Lua locale emitter."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header
from codegen.targets.lua.plural_rules import get_lua_named_function, get_lua_plural, is_simple_plural

HEADER = make_header("codegen/targets/lua/emitter.py", line_prefix="-- ")


def _quote(s: str) -> str:
    """Quote a string for Lua."""
    escaped = s.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def _unit_forms(unit: object) -> str:
    """Emit a UnitForms value."""
    if isinstance(unit, str):
        return _quote(unit)
    cats = ["zero", "one", "two", "few", "many", "other"]
    pairs = []
    for cat in cats:
        if cat in unit:
            pairs.append(f'{cat} = {_quote(unit[cat])}')
    return "{ " + ", ".join(pairs) + " }"


def _stage_label(stage: object) -> str:
    if isinstance(stage, str):
        return _quote(stage)
    return "{ m = " + _quote(stage["m"]) + ", f = " + _quote(stage["f"]) + " }"


def emit_locale(data: dict) -> str:
    code = data["code"]
    rule = data["pluralRule"]

    lines = [HEADER + locale_source_comment(code, line_prefix="-- ")]

    # Named plural function
    named_fn = get_lua_named_function(rule)
    if named_fn:
        lines.append(named_fn)
        lines.append("")

    # Module table
    lines.append("local M = {}")
    lines.append("")
    lines.append(f"M.code = {_quote(code)}")

    # Plural
    plural_expr = get_lua_plural(rule)
    lines.append(f"M.plural = {plural_expr}")

    # Units
    lines.append("M.units = {")
    for unit_name in ("day", "week", "month", "year"):
        val = _unit_forms(data["units"][unit_name])
        lines.append(f"    {unit_name} = {val},")
    lines.append("}")

    # Simple fields
    lines.append(f"M.half = {_quote(data['half'])}")
    lines.append(f"M.delimiter = {_quote(data['delimiter'])}")
    lines.append(f"M.just_born = {_quote(data['justBorn'])}")

    # Stages
    lines.append("M.stages = {")
    for stage in ("newborn", "infant", "toddler", "child", "teenager", "adult"):
        val = _stage_label(data["stages"][stage])
        lines.append(f"    {stage} = {val},")
    lines.append("}")

    # Short/compact
    for mode in ("short", "compact"):
        if mode in data:
            ovr = data[mode]
            lines.append(f"M.{mode} = {{")
            if "units" in ovr:
                lines.append("    units = {")
                for unit_name in ("day", "week", "month", "year"):
                    if unit_name in ovr["units"]:
                        val = _unit_forms(ovr["units"][unit_name])
                        lines.append(f"        {unit_name} = {val},")
                lines.append("    },")
            if "half" in ovr:
                lines.append(f"    half = {_quote(ovr['half'])},")
            if "delimiter" in ovr:
                lines.append(f"    delimiter = {_quote(ovr['delimiter'])},")
            if "justBorn" in ovr:
                lines.append(f"    just_born = {_quote(ovr['justBorn'])},")
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
    lines.append("--- Every locale code, sorted.")
    lines.append("M.CODES = {")
    for loc in sorted_locs:
        lines.append(f'    "{loc["code"]}",')
    lines.append("}")
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
