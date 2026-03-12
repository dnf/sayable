"""Elixir locale emitter for sayable-time."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header

HEADER = make_header("codegen/targets/elixir/emitter.py", line_prefix="# ")


def _module_name(code: str) -> str:
    """Convert locale code to Elixir module suffix (uppercase, hyphens to underscores)."""
    return code.replace("-", "_").upper()


def _quote(s: str) -> str:
    escaped = s.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def _str_list(items: list[str], indent: str) -> str:
    inner = indent + "  "
    parts = [f"{inner}{_quote(s)}" for s in items]
    return f"[\n" + ",\n".join(parts) + f"\n{indent}]"


def emit_locale(data: dict) -> str:
    code = data["code"]
    mod = _module_name(code)
    clock = data["clock"]
    indent = "      "

    lines = [HEADER + locale_source_comment(code, line_prefix="# ")]
    lines.append(f"defmodule SayableTime.Locales.{mod} do")
    lines.append("  @moduledoc false")
    lines.append("")
    lines.append("  def locale do")
    lines.append("    %{")

    parts = []
    parts.append(f"{indent}code: {_quote(code)}")

    # Clock config
    clock_parts = []
    clock_parts.append(f"{indent}  hours: {_str_list(clock['hours'], indent + '  ')}")
    clock_parts.append(f"{indent}  midnight: {_quote(clock['midnight'])}")
    clock_parts.append(f"{indent}  noon: {_quote(clock['noon'])}")

    # Patterns as a map with integer keys
    pattern_keys = ["0", "5", "10", "15", "20", "25", "30", "35", "40", "45", "50", "55"]
    pat_parts = []
    for key in pattern_keys:
        if key in clock["patterns"]:
            pat_parts.append(f"{indent}    {key} => {_quote(clock['patterns'][key])}")
    clock_parts.append(f"{indent}  patterns: %{{\n" + ",\n".join(pat_parts) + f"\n{indent}  }}")
    parts.append(f"{indent}clock: %{{\n" + ",\n".join(clock_parts) + f"\n{indent}}}")

    # Short override
    if "short" in data:
        sc = data["short"].get("clock", {})
        use24h = "true" if sc.get("use24h", True) else "false"
        fmt = sc.get("format", "{h}:{mm}")
        am_pm = sc.get("amPm")
        sc_parts = []
        sc_parts.append(f"{indent}  use24h: {use24h}")
        sc_parts.append(f"{indent}  format: {_quote(fmt)}")
        if am_pm:
            sc_parts.append(f'{indent}  am_pm: {{{_quote(am_pm[0])}, {_quote(am_pm[1])}}}')
        else:
            sc_parts.append(f"{indent}  am_pm: nil")
        parts.append(f"{indent}short: %{{\n{indent}  clock: %{{\n" + ",\n".join(sc_parts) + f"\n{indent}  }}\n{indent}}}")

    # Compact override
    if "compact" in data:
        sc = data["compact"].get("clock", {})
        use24h = "true" if sc.get("use24h", True) else "false"
        fmt = sc.get("format", "{h}:{mm}")
        am_pm = sc.get("amPm")
        sc_parts = []
        sc_parts.append(f"{indent}  use24h: {use24h}")
        sc_parts.append(f"{indent}  format: {_quote(fmt)}")
        if am_pm:
            sc_parts.append(f'{indent}  am_pm: {{{_quote(am_pm[0])}, {_quote(am_pm[1])}}}')
        else:
            sc_parts.append(f"{indent}  am_pm: nil")
        parts.append(f"{indent}compact: %{{\n{indent}  clock: %{{\n" + ",\n".join(sc_parts) + f"\n{indent}  }}\n{indent}}}")

    lines.append(",\n".join(parts))
    lines.append("    }")
    lines.append("  end")
    lines.append("end")
    lines.append("")

    return "\n".join(lines)


def emit_registry(all_locales: list[dict]) -> str:
    """Generate the SayableTime.Locales module with get(code) function."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER]
    lines.append("defmodule SayableTime.Locales do")
    lines.append("  @moduledoc false")
    lines.append("")

    for loc in sorted_locs:
        code = loc["code"]
        mod = _module_name(code)
        lines.append(f'  def get({_quote(code)}), do: {{:ok, SayableTime.Locales.{mod}.locale()}}')

    lines.append("  def get(_), do: :error")
    lines.append("end")
    lines.append("")

    return "\n".join(lines)


def output_path(code: str, root: str) -> str:
    import os
    mod = code.replace("-", "_")
    return os.path.join(root, "impl", "elixir", "lib", "sayable_time", "locales", f"{mod}.ex")


def registry_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "elixir", "lib", "sayable_time", "locales.ex")
