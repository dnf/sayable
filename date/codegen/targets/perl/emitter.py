"""Perl locale emitter for sayable-date."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header

HEADER = make_header("codegen/targets/perl/emitter.py", line_prefix="# ")


def _quote(s: str) -> str:
    escaped = s.replace("\\", "\\\\").replace("'", "\\'")
    return f"'{escaped}'"


def _str_array(items: list[str]) -> str:
    return "(" + ", ".join(_quote(s) for s in items) + ")"


def _str_hash(d: dict[str, str]) -> str:
    if not d:
        return "()"
    pairs = [f"{_quote(k)} => {_quote(v)}" for k, v in d.items()]
    return "(" + ", ".join(pairs) + ")"


def emit_locale(data: dict) -> str:
    code = data["code"]
    uc = code.upper()

    lines = []
    lines.append("use strict;")
    lines.append("use warnings;")
    lines.append("use utf8;")
    lines.append("")
    lines.append((HEADER + locale_source_comment(code, line_prefix="# ")).rstrip())
    lines.append(f"package SayableDate::Locales::{uc};")
    lines.append("")
    lines.append("sub locale {{")

    # Code
    lines.append(f"  code => {_quote(code)},")

    # Months
    lines.append(f"  months => [{', '.join(_quote(m) for m in data['months'])}],")

    # Weekdays
    lines.append(f"  weekdays => [{', '.join(_quote(w) for w in data['weekdays'])}],")

    # DayFormat
    lines.append(f"  day_format => {_quote(data['dayFormat'])},")

    # DayFormatExceptions
    exceptions = data.get("dayFormatExceptions", {})
    if exceptions:
        pairs = [f"{_quote(k)} => {_quote(v)}" for k, v in exceptions.items()]
        lines.append(f"  day_format_exceptions => {{ {', '.join(pairs)} }},")
    else:
        lines.append("  day_format_exceptions => {},")

    # Date patterns
    lines.append(f"  date_pattern => {_quote(data['datePattern'])},")
    lines.append(f"  date_pattern_with_year => {_quote(data['datePatternWithYear'])},")

    # Required strings
    lines.append(f"  today => {_quote(data['today'])},")
    lines.append(f"  tomorrow => {_quote(data['tomorrow'])},")
    lines.append(f"  yesterday => {_quote(data['yesterday'])},")

    # Optional strings
    if "dayAfterTomorrow" in data:
        lines.append(f"  day_after_tomorrow => {_quote(data['dayAfterTomorrow'])},")
    if "dayBeforeYesterday" in data:
        lines.append(f"  day_before_yesterday => {_quote(data['dayBeforeYesterday'])},")
    if "thisWeekday" in data:
        lines.append(f"  this_weekday => {_quote(data['thisWeekday'])},")
    if "nextWeekday" in data:
        lines.append(f"  next_weekday => {_quote(data['nextWeekday'])},")
    if "lastWeekday" in data:
        lines.append(f"  last_weekday => {_quote(data['lastWeekday'])},")
    if "monthsInDate" in data:
        lines.append(f"  months_in_date => [{', '.join(_quote(m) for m in data['monthsInDate'])}],")

    # Short override
    if "short" in data:
        ovr = data["short"]
        lines.append("  short => {")
        if "months" in ovr:
            lines.append(f"    months => [{', '.join(_quote(m) for m in ovr['months'])}],")
        if "monthsInDate" in ovr:
            lines.append(f"    months_in_date => [{', '.join(_quote(m) for m in ovr['monthsInDate'])}],")
        if "weekdays" in ovr:
            lines.append(f"    weekdays => [{', '.join(_quote(w) for w in ovr['weekdays'])}],")
        if "dayFormat" in ovr:
            lines.append(f"    day_format => {_quote(ovr['dayFormat'])},")
        if "dayFormatExceptions" in ovr:
            ex = ovr["dayFormatExceptions"]
            pairs = [f"{_quote(k)} => {_quote(v)}" for k, v in ex.items()]
            lines.append(f"    day_format_exceptions => {{ {', '.join(pairs)} }},")
        if "datePattern" in ovr:
            lines.append(f"    date_pattern => {_quote(ovr['datePattern'])},")
        if "datePatternWithYear" in ovr:
            lines.append(f"    date_pattern_with_year => {_quote(ovr['datePatternWithYear'])},")
        lines.append("  },")

    # Compact override
    if "compact" in data:
        ovr = data["compact"]
        lines.append("  compact => {")
        if "datePattern" in ovr:
            lines.append(f"    date_pattern => {_quote(ovr['datePattern'])},")
        if "datePatternWithYear" in ovr:
            lines.append(f"    date_pattern_with_year => {_quote(ovr['datePatternWithYear'])},")
        lines.append("  },")

    lines.append("}}")
    lines.append("")
    lines.append("1;")
    lines.append("")

    return "\n".join(lines)


def emit_barrel(all_locales: list[dict]) -> str | None:
    return None


def emit_registry(all_locales: list[dict]) -> str:
    """Generate Locales.pm with get($code) function."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = ["use strict;", "use warnings;", "", HEADER.rstrip()]
    lines.append("package SayableDate::Locales;")
    lines.append("")

    for loc in sorted_locs:
        uc = loc["code"].upper()
        lines.append(f"use SayableDate::Locales::{uc};")
    lines.append("")

    lines.append("my %_LOCALES = (")
    for loc in sorted_locs:
        code = loc["code"]
        uc = code.upper()
        lines.append(f"  {_quote(code)} => SayableDate::Locales::{uc}::locale(),")
    lines.append(");")
    lines.append("")

    lines.append("sub get {")
    lines.append("  my ($class, $code) = @_;")
    lines.append("  return $_LOCALES{$code};")
    lines.append("}")
    lines.append("")
    lines.append("1;")
    lines.append("")

    return "\n".join(lines)


def output_path(code: str, root: str) -> str:
    import os
    return os.path.join(root, "impl", "perl", "lib", "SayableDate", "Locales", f"{code.upper()}.pm")


def registry_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "perl", "lib", "SayableDate", "Locales.pm")


def barrel_path(root: str) -> str | None:
    return None
