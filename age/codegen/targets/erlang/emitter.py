"""Erlang locale emitter."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header
from codegen.targets.erlang.plural_rules import get_erl_plural

HEADER = make_header("codegen/targets/erlang/emitter.py", line_prefix="%% ")

_CAT_MAP = {
    "zero": "zero", "one": "one", "two": "two",
    "few": "few", "many": "many", "other": "other",
}


def _module_name(code: str) -> str:
    """Convert locale code to Erlang module suffix (lowercase, underscores for hyphens)."""
    return code.replace("-", "_")


def _quote(s: str) -> str:
    escaped = s.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def _unit_forms(unit: object) -> str:
    if isinstance(unit, str):
        return f"{{simple, {_quote(unit)}}}"
    cats = ["zero", "one", "two", "few", "many", "other"]
    pairs = []
    for cat in cats:
        if cat in unit:
            pairs.append(f"{{{_CAT_MAP[cat]}, {_quote(unit[cat])}}}")
    return "{pluralized, [" + ", ".join(pairs) + "]}"


def _stage_label(stage: object) -> str:
    if isinstance(stage, str):
        return f"{{neutral, {_quote(stage)}}}"
    return f"{{gendered, {_quote(stage['m'])}, {_quote(stage['f'])}}}"


def _compactness_override(ovr: dict) -> str:
    parts = []
    for unit_name in ("day", "week", "month", "year"):
        if "units" in ovr and unit_name in ovr["units"]:
            val = ovr["units"][unit_name]
            parts.append(f"{unit_name} = {{just, {_unit_forms(val)}}}")
        else:
            parts.append(f"{unit_name} = nothing")
    if "half" in ovr:
        parts.append(f"half = {{just, {_quote(ovr['half'])}}}")
    else:
        parts.append("half = nothing")
    if "delimiter" in ovr:
        parts.append(f"delimiter = {{just, {_quote(ovr['delimiter'])}}}")
    else:
        parts.append("delimiter = nothing")
    if "justBorn" in ovr:
        parts.append(f"just_born = {{just, {_quote(ovr['justBorn'])}}}")
    else:
        parts.append("just_born = nothing")
    return "#compactness_override{" + ", ".join(parts) + "}"


def emit_locale(data: dict) -> str:
    code = data["code"]
    rule = data["pluralRule"]
    mod = _module_name(code)

    lines = [HEADER + locale_source_comment(code, line_prefix="%% ")]
    lines.append(f"-module(sayableage_locales_{mod}).")
    lines.append('-include("sayableage.hrl").')
    lines.append("-export([locale/0]).")
    lines.append("")
    lines.append("locale() ->")
    lines.append("    #locale{")

    parts = []
    parts.append(f"        code = {_quote(code)}")

    plural = get_erl_plural(rule)
    parts.append(f"        plural = {plural}")

    for unit_name in ("day", "week", "month", "year"):
        val = _unit_forms(data["units"][unit_name])
        parts.append(f"        {unit_name} = {val}")

    parts.append(f"        half = {_quote(data['half'])}")
    parts.append(f"        delimiter = {_quote(data['delimiter'])}")
    parts.append(f"        just_born = {_quote(data['justBorn'])}")

    stages = data["stages"]
    stage_names = ["newborn", "infant", "toddler", "child", "teenager", "adult"]
    stage_parts = []
    for stage in stage_names:
        stage_parts.append(f"{stage} = {_stage_label(stages[stage])}")
    parts.append("        stages = #stages{" + ", ".join(stage_parts) + "}")

    for mode in ("short", "compact"):
        if mode in data:
            parts.append(f"        {mode} = {{just, {_compactness_override(data[mode])}}}")
        else:
            parts.append(f"        {mode} = nothing")

    lines.append(",\n".join(parts))
    lines.append("    }.")
    lines.append("")

    return "\n".join(lines)


def emit_barrel(all_locales: list[dict]) -> str:
    """Generate the sayableage_locales.erl barrel module."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER]
    lines.append("-module(sayableage_locales).")
    lines.append('-include("sayableage.hrl").')
    lines.append("-export([get_locale/1]).")
    lines.append("")

    for loc in sorted_locs:
        code = loc["code"]
        mod = _module_name(code)
        lines.append(f'get_locale({_quote(code)}) -> {{ok, sayableage_locales_{mod}:locale()}};')

    lines.append("get_locale(_) -> error.")
    lines.append("")

    return "\n".join(lines)


def output_path(code: str, root: str) -> str:
    import os
    mod = _module_name(code)
    return os.path.join(root, "src", "erlang", "src", "locales", f"sayableage_locales_{mod}.erl")


def barrel_path(root: str) -> str:
    import os
    return os.path.join(root, "src", "erlang", "src", "locales", "sayableage_locales.erl")
