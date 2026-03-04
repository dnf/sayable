"""Elixir locale emitter."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header
from codegen.targets.elixir.plural_rules import get_ex_plural

HEADER = make_header("codegen/targets/elixir/emitter.py", line_prefix="# ")


def _module_name(code: str) -> str:
    """Convert locale code to Elixir module suffix (uppercase, hyphens to underscores)."""
    return code.replace("-", "_").upper()


def _quote(s: str) -> str:
    escaped = s.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def _unit_forms(unit: object) -> str:
    if isinstance(unit, str):
        return _quote(unit)
    cats = ["zero", "one", "two", "few", "many", "other"]
    pairs = []
    for cat in cats:
        if cat in unit:
            pairs.append(f"{cat}: {_quote(unit[cat])}")
    return "%{" + ", ".join(pairs) + "}"


def _stage_label(stage: object) -> str:
    if isinstance(stage, str):
        return _quote(stage)
    return "%{m: " + _quote(stage["m"]) + ", f: " + _quote(stage["f"]) + "}"


def _build_units_map(units: dict, indent: str) -> str:
    inner = indent + "  "
    items = []
    for unit_name in ("day", "week", "month", "year"):
        val = _unit_forms(units[unit_name])
        items.append(f"{inner}{unit_name}: {val}")
    return f"{indent}units: %{{\n" + ",\n".join(items) + f"\n{indent}}}"


def _build_stages_map(stages: dict, indent: str) -> str:
    inner = indent + "  "
    stage_names = ["newborn", "infant", "toddler", "child", "teenager", "adult"]
    items = []
    for stage in stage_names:
        items.append(f"{inner}{stage}: {_stage_label(stages[stage])}")
    return f"{indent}stages: %{{\n" + ",\n".join(items) + f"\n{indent}}}"


def _build_compactness(mode: str, ovr: dict, indent: str) -> str:
    inner = indent + "  "
    ovr_parts = []
    if "units" in ovr:
        inner2 = inner + "  "
        u_items = []
        for unit_name in ("day", "week", "month", "year"):
            if unit_name in ovr["units"]:
                val = _unit_forms(ovr["units"][unit_name])
                u_items.append(f"{inner2}{unit_name}: {val}")
        ovr_parts.append(f"{inner}units: %{{\n" + ",\n".join(u_items) + f"\n{inner}}}")
    if "half" in ovr:
        ovr_parts.append(f"{inner}half: {_quote(ovr['half'])}")
    if "delimiter" in ovr:
        ovr_parts.append(f"{inner}delimiter: {_quote(ovr['delimiter'])}")
    if "justBorn" in ovr:
        ovr_parts.append(f"{inner}just_born: {_quote(ovr['justBorn'])}")
    return f"{indent}{mode}: %{{\n" + ",\n".join(ovr_parts) + f"\n{indent}}}"


def emit_locale(data: dict) -> str:
    code = data["code"]
    rule = data["pluralRule"]
    mod = _module_name(code)
    indent = "      "

    lines = [HEADER + locale_source_comment(code, line_prefix="# ")]
    lines.append(f"defmodule SayableAge.Locales.{mod} do")
    lines.append("  @moduledoc false")
    lines.append("")
    lines.append("  def locale do")
    lines.append("    %{")

    parts = []
    parts.append(f"{indent}code: {_quote(code)}")

    plural = get_ex_plural(rule)
    parts.append(f"{indent}plural: ({plural})")

    parts.append(_build_units_map(data["units"], indent))

    parts.append(f"{indent}half: {_quote(data['half'])}")
    parts.append(f"{indent}delimiter: {_quote(data['delimiter'])}")
    parts.append(f"{indent}just_born: {_quote(data['justBorn'])}")

    parts.append(_build_stages_map(data["stages"], indent))

    for mode in ("short", "compact"):
        if mode in data:
            parts.append(_build_compactness(mode, data[mode], indent))

    lines.append(",\n".join(parts))
    lines.append("    }")
    lines.append("  end")
    lines.append("end")
    lines.append("")

    return "\n".join(lines)


def emit_registry(all_locales: list[dict]) -> str:
    """Generate the SayableAge.Locales module with get(code) function."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER]
    lines.append("defmodule SayableAge.Locales do")
    lines.append("  @moduledoc false")
    lines.append("")

    for loc in sorted_locs:
        code = loc["code"]
        mod = _module_name(code)
        lines.append(f'  def get({_quote(code)}), do: {{:ok, SayableAge.Locales.{mod}.locale()}}')

    lines.append("  def get(_), do: :error")
    lines.append("end")
    lines.append("")

    return "\n".join(lines)


def output_path(code: str, root: str) -> str:
    import os
    mod = code.replace("-", "_")
    return os.path.join(root, "src", "elixir", "lib", "sayable_age", "locales", f"{mod}.ex")


def registry_path(root: str) -> str:
    import os
    return os.path.join(root, "src", "elixir", "lib", "sayable_age", "locales.ex")
