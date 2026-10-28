"""Elixir locale emitter for sayable-duration."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header
from codegen.targets.elixir.plural_rules import get_ex_plural

HEADER = make_header("codegen/targets/elixir/emitter.py", line_prefix="# ")

# `mix format`'s default :line_length.
_LINE_LENGTH = 98


def _module_name(code: str) -> str:
    """Convert locale code to Elixir module suffix (uppercase, hyphens to underscores)."""
    return code.replace("-", "_").upper()


def _quote(s: str) -> str:
    escaped = s.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def _keyed_map(key: str, pairs: list[str], indent: str) -> str:
    """Return ``key: %{...}`` at ``indent`` the way `mix format` lays it out.

    The map stays on one line when it fits, trailing comma included; otherwise
    each pair goes on its own line, which `mix format` keeps because the map
    opens and closes on a newline. Python counts code points and `mix format`
    counts graphemes, which are never more, so a line that fits here fits there.
    """
    flat = f"{indent}{key}: %{{" + ", ".join(pairs) + "}"
    if len(flat) + len(",") <= _LINE_LENGTH:
        return flat
    inner = indent + "  "
    return f"{indent}{key}: %{{\n" + ",\n".join(inner + pair for pair in pairs) + f"\n{indent}}}"


def _unit_entry(name: str, unit: object, indent: str) -> str:
    if isinstance(unit, str):
        return f"{indent}{name}: {_quote(unit)}"
    cats = ["zero", "one", "two", "few", "many", "other"]
    pairs = [f"{cat}: {_quote(unit[cat])}" for cat in cats if cat in unit]
    return _keyed_map(name, pairs, indent)


def _build_units_map(units: dict, indent: str) -> str:
    inner = indent + "  "
    items = []
    for unit_name in ("second", "minute", "hour", "day", "week", "month", "year"):
        items.append(_unit_entry(unit_name, units[unit_name], inner))
    return f"{indent}units: %{{\n" + ",\n".join(items) + f"\n{indent}}}"


def _build_compactness(mode: str, ovr: dict, indent: str) -> str:
    inner = indent + "  "
    ovr_parts = []
    if "units" in ovr:
        inner2 = inner + "  "
        u_items = []
        for unit_name in ("second", "minute", "hour", "day", "week", "month", "year"):
            if unit_name in ovr["units"]:
                u_items.append(_unit_entry(unit_name, ovr["units"][unit_name], inner2))
        ovr_parts.append(f"{inner}units: %{{\n" + ",\n".join(u_items) + f"\n{inner}}}")
    if "half" in ovr:
        ovr_parts.append(f"{inner}half: {_quote(ovr['half'])}")
    if "delimiter" in ovr:
        ovr_parts.append(f"{inner}delimiter: {_quote(ovr['delimiter'])}")
    if "ago" in ovr:
        ovr_parts.append(f"{inner}ago: {_quote(ovr['ago'])}")
    if "inFuture" in ovr:
        ovr_parts.append(f"{inner}in_future: {_quote(ovr['inFuture'])}")
    return f"{indent}{mode}: %{{\n" + ",\n".join(ovr_parts) + f"\n{indent}}}"


def emit_locale(data: dict) -> str:
    code = data["code"]
    rule = data["pluralRule"]
    mod = _module_name(code)
    indent = "      "

    lines = [HEADER + locale_source_comment(code, line_prefix="# ")]
    lines.append(f"defmodule SayableDuration.Locales.{mod} do")
    lines.append("  @moduledoc false")
    lines.append("")
    lines.append("  def locale do")
    lines.append("    %{")

    parts = []
    parts.append(f"{indent}code: {_quote(code)}")

    plural = get_ex_plural(rule, indent)
    parts.append(f"{indent}plural: {plural}")

    parts.append(_build_units_map(data["units"], indent))

    parts.append(f"{indent}half: {_quote(data['half'])}")
    parts.append(f"{indent}delimiter: {_quote(data['delimiter'])}")
    parts.append(f"{indent}just_now: {_quote(data['justNow'])}")
    parts.append(f"{indent}ago: {_quote(data['ago'])}")
    parts.append(f"{indent}in_future: {_quote(data['inFuture'])}")

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
    """Generate the SayableDuration.Locales module with get(code) function."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER]
    lines.append("defmodule SayableDuration.Locales do")
    lines.append("  @moduledoc false")
    lines.append("")

    for loc in sorted_locs:
        code = loc["code"]
        mod = _module_name(code)
        lines.append(f'  def get({_quote(code)}), do: {{:ok, SayableDuration.Locales.{mod}.locale()}}')

    lines.append("  def get(_), do: :error")
    lines.append("end")
    lines.append("")

    return "\n".join(lines)


def output_path(code: str, root: str) -> str:
    import os
    mod = code.replace("-", "_")
    return os.path.join(root, "impl", "elixir", "lib", "sayable_duration", "locales", f"{mod}.ex")


def registry_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "elixir", "lib", "sayable_duration", "locales.ex")
