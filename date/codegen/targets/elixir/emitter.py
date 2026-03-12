"""Elixir locale emitter for sayable-date."""

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


def _str_map(d: dict[str, str], indent: str) -> str:
    inner = indent + "  "
    parts = [f"{inner}{_quote(k)} => {_quote(v)}" for k, v in d.items()]
    return f"%{{\n" + ",\n".join(parts) + f"\n{indent}}}"


def emit_locale(data: dict) -> str:
    code = data["code"]
    mod = _module_name(code)
    indent = "      "

    lines = [HEADER + locale_source_comment(code, line_prefix="# ")]
    lines.append(f"defmodule SayableDate.Locales.{mod} do")
    lines.append("  @moduledoc false")
    lines.append("")
    lines.append("  def locale do")
    lines.append("    %{")

    parts = []
    parts.append(f"{indent}code: {_quote(code)}")
    parts.append(f"{indent}months: {_str_list(data['months'], indent)}")
    parts.append(f"{indent}weekdays: {_str_list(data['weekdays'], indent)}")
    parts.append(f"{indent}day_format: {_quote(data['dayFormat'])}")

    if "dayFormatExceptions" in data and data["dayFormatExceptions"]:
        parts.append(f"{indent}day_format_exceptions: {_str_map(data['dayFormatExceptions'], indent)}")
    else:
        parts.append(f"{indent}day_format_exceptions: %{{}}")

    parts.append(f"{indent}date_pattern: {_quote(data['datePattern'])}")
    parts.append(f"{indent}date_pattern_with_year: {_quote(data['datePatternWithYear'])}")
    parts.append(f"{indent}today: {_quote(data['today'])}")
    parts.append(f"{indent}tomorrow: {_quote(data['tomorrow'])}")
    parts.append(f"{indent}yesterday: {_quote(data['yesterday'])}")

    if "dayAfterTomorrow" in data:
        parts.append(f"{indent}day_after_tomorrow: {_quote(data['dayAfterTomorrow'])}")
    else:
        parts.append(f"{indent}day_after_tomorrow: nil")

    if "dayBeforeYesterday" in data:
        parts.append(f"{indent}day_before_yesterday: {_quote(data['dayBeforeYesterday'])}")
    else:
        parts.append(f"{indent}day_before_yesterday: nil")

    if "thisWeekday" in data:
        parts.append(f"{indent}this_weekday: {_quote(data['thisWeekday'])}")
    else:
        parts.append(f"{indent}this_weekday: nil")

    if "nextWeekday" in data:
        parts.append(f"{indent}next_weekday: {_quote(data['nextWeekday'])}")
    else:
        parts.append(f"{indent}next_weekday: nil")

    if "lastWeekday" in data:
        parts.append(f"{indent}last_weekday: {_quote(data['lastWeekday'])}")
    else:
        parts.append(f"{indent}last_weekday: nil")

    if "monthsInDate" in data:
        parts.append(f"{indent}months_in_date: {_str_list(data['monthsInDate'], indent)}")
    else:
        parts.append(f"{indent}months_in_date: nil")

    # Short override
    if "short" in data:
        ovr = data["short"]
        ovr_parts = []
        if "months" in ovr:
            ovr_parts.append(f"{indent}  months: {_str_list(ovr['months'], indent + '  ')}")
        if "monthsInDate" in ovr:
            ovr_parts.append(f"{indent}  months_in_date: {_str_list(ovr['monthsInDate'], indent + '  ')}")
        if "weekdays" in ovr:
            ovr_parts.append(f"{indent}  weekdays: {_str_list(ovr['weekdays'], indent + '  ')}")
        if "dayFormat" in ovr:
            ovr_parts.append(f"{indent}  day_format: {_quote(ovr['dayFormat'])}")
        if "dayFormatExceptions" in ovr:
            ovr_parts.append(f"{indent}  day_format_exceptions: {_str_map(ovr['dayFormatExceptions'], indent + '  ')}")
        if "datePattern" in ovr:
            ovr_parts.append(f"{indent}  date_pattern: {_quote(ovr['datePattern'])}")
        if "datePatternWithYear" in ovr:
            ovr_parts.append(f"{indent}  date_pattern_with_year: {_quote(ovr['datePatternWithYear'])}")
        if "today" in ovr:
            ovr_parts.append(f"{indent}  today: {_quote(ovr['today'])}")
        if "tomorrow" in ovr:
            ovr_parts.append(f"{indent}  tomorrow: {_quote(ovr['tomorrow'])}")
        if "yesterday" in ovr:
            ovr_parts.append(f"{indent}  yesterday: {_quote(ovr['yesterday'])}")
        parts.append(f"{indent}short: %{{\n" + ",\n".join(ovr_parts) + f"\n{indent}}}")

    # Compact override
    if "compact" in data:
        ovr = data["compact"]
        ovr_parts = []
        if "datePattern" in ovr:
            ovr_parts.append(f"{indent}  date_pattern: {_quote(ovr['datePattern'])}")
        if "datePatternWithYear" in ovr:
            ovr_parts.append(f"{indent}  date_pattern_with_year: {_quote(ovr['datePatternWithYear'])}")
        if "today" in ovr:
            ovr_parts.append(f"{indent}  today: {_quote(ovr['today'])}")
        if "tomorrow" in ovr:
            ovr_parts.append(f"{indent}  tomorrow: {_quote(ovr['tomorrow'])}")
        if "yesterday" in ovr:
            ovr_parts.append(f"{indent}  yesterday: {_quote(ovr['yesterday'])}")
        parts.append(f"{indent}compact: %{{\n" + ",\n".join(ovr_parts) + f"\n{indent}}}")

    lines.append(",\n".join(parts))
    lines.append("    }")
    lines.append("  end")
    lines.append("end")
    lines.append("")

    return "\n".join(lines)


def emit_registry(all_locales: list[dict]) -> str:
    """Generate the SayableDate.Locales module with get(code) function."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER]
    lines.append("defmodule SayableDate.Locales do")
    lines.append("  @moduledoc false")
    lines.append("")

    for loc in sorted_locs:
        code = loc["code"]
        mod = _module_name(code)
        lines.append(f'  def get({_quote(code)}), do: {{:ok, SayableDate.Locales.{mod}.locale()}}')

    lines.append("  def get(_), do: :error")
    lines.append("end")
    lines.append("")

    return "\n".join(lines)


def output_path(code: str, root: str) -> str:
    import os
    mod = code.replace("-", "_")
    return os.path.join(root, "impl", "elixir", "lib", "sayable_date", "locales", f"{mod}.ex")


def registry_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "elixir", "lib", "sayable_date", "locales.ex")
