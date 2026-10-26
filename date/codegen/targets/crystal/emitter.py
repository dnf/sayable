"""Crystal locale emitter for sayable-date."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header

HEADER = make_header("codegen/targets/crystal/emitter.py", line_prefix="# ")


def _quote(s: str) -> str:
    escaped = s.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def _str_array(items: list[str]) -> str:
    return "[" + ", ".join(_quote(s) for s in items) + "]"


def _str_hash(d: dict[str, str], indent: str) -> str:
    """A multi-line hash for a field at `indent`, laid out as `crystal tool format` does."""
    if not d:
        return "{} of String => String"
    width = max(len(_quote(k)) for k in d)
    entries = "".join(f"{indent}  {_quote(k).ljust(width)} => {_quote(v)},\n" for k, v in d.items())
    return "{\n" + entries + indent + "}"


def emit_locale(data: dict) -> str:
    code = data["code"]
    uc = code.upper()

    lines = [(HEADER + locale_source_comment(code, line_prefix="# ")).rstrip()]
    lines.append("module SayableDate")
    lines.append("  module Locales")
    lines.append(f"    {uc} = DateLocale.new(")

    # Code
    lines.append(f"      code: {_quote(code)},")

    # Months & Weekdays
    lines.append(f"      months: {_str_array(data['months'])},")
    lines.append(f"      weekdays: {_str_array(data['weekdays'])},")

    # DayFormat
    lines.append(f"      day_format: {_quote(data['dayFormat'])},")

    # DayFormatExceptions
    exceptions = data.get("dayFormatExceptions", {})
    lines.append(f"      day_format_exceptions: {_str_hash(exceptions, '      ')},")

    # Date patterns
    lines.append(f"      date_pattern: {_quote(data['datePattern'])},")
    lines.append(f"      date_pattern_with_year: {_quote(data['datePatternWithYear'])},")

    # Required strings
    lines.append(f"      today: {_quote(data['today'])},")
    lines.append(f"      tomorrow: {_quote(data['tomorrow'])},")
    lines.append(f"      yesterday: {_quote(data['yesterday'])},")

    # Optional strings
    if "dayAfterTomorrow" in data:
        lines.append(f"      day_after_tomorrow: {_quote(data['dayAfterTomorrow'])},")
    if "dayBeforeYesterday" in data:
        lines.append(f"      day_before_yesterday: {_quote(data['dayBeforeYesterday'])},")
    if "thisWeekday" in data:
        lines.append(f"      this_weekday: {_quote(data['thisWeekday'])},")
    if "nextWeekday" in data:
        lines.append(f"      next_weekday: {_quote(data['nextWeekday'])},")
    if "lastWeekday" in data:
        lines.append(f"      last_weekday: {_quote(data['lastWeekday'])},")
    if "monthsInDate" in data:
        lines.append(f"      months_in_date: {_str_array(data['monthsInDate'])},")

    # Short override
    if "short" in data:
        ovr = data["short"]
        lines.append("      short: CompactnessOverride.new(")
        if "months" in ovr:
            lines.append(f"        months: {_str_array(ovr['months'])},")
        if "monthsInDate" in ovr:
            lines.append(f"        months_in_date: {_str_array(ovr['monthsInDate'])},")
        if "weekdays" in ovr:
            lines.append(f"        weekdays: {_str_array(ovr['weekdays'])},")
        if "dayFormat" in ovr:
            lines.append(f"        day_format: {_quote(ovr['dayFormat'])},")
        if "dayFormatExceptions" in ovr:
            lines.append(f"        day_format_exceptions: {_str_hash(ovr['dayFormatExceptions'], '        ')},")
        if "datePattern" in ovr:
            lines.append(f"        date_pattern: {_quote(ovr['datePattern'])},")
        if "datePatternWithYear" in ovr:
            lines.append(f"        date_pattern_with_year: {_quote(ovr['datePatternWithYear'])},")
        lines.append("      ),")

    # Compact override
    if "compact" in data:
        ovr = data["compact"]
        lines.append("      compact: CompactnessOverride.new(")
        if "datePattern" in ovr:
            lines.append(f"        date_pattern: {_quote(ovr['datePattern'])},")
        if "datePatternWithYear" in ovr:
            lines.append(f"        date_pattern_with_year: {_quote(ovr['datePatternWithYear'])},")
        lines.append("      ),")

    lines.append("    )")
    lines.append("  end")
    lines.append("end")
    lines.append("")

    return "\n".join(lines)


def emit_barrel(all_locales: list[dict]) -> str | None:
    return None


def emit_registry(all_locales: list[dict]) -> str:
    """Generate locales/registry.cr with self.get(code) method."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER.rstrip()]
    lines.append("module SayableDate")
    lines.append("  module Locales")
    lines.append("    def self.get(code : String) : DateLocale?")
    lines.append("      case code")
    code_width = max(len(_quote(loc["code"])) for loc in sorted_locs)
    for loc in sorted_locs:
        code = loc["code"]
        lines.append(f"      when {_quote(code).ljust(code_width)} then {code.upper()}")
    # `crystal tool format` aligns every branch's result, `else` included.
    lines.append(f"      {'else'.ljust(len('when ') + code_width + len(' then '))}nil")
    lines.append("      end")
    lines.append("    end")
    lines.append("  end")
    lines.append("end")
    lines.append("")
    return "\n".join(lines)


def output_path(code: str, root: str) -> str:
    import os
    return os.path.join(root, "impl", "crystal", "src", "sayable_date", "locales", f"{code}.cr")


def registry_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "crystal", "src", "sayable_date", "locales", "registry.cr")


def barrel_path(root: str) -> str | None:
    return None
