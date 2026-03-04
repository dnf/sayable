"""Go locale emitter for sayable-date."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header

HEADER = make_header("codegen/targets/go/emitter.py")


def _quote(s: str) -> str:
    escaped = s.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def _str_array_12(items: list[str]) -> str:
    """Emit a Go [12]string{...} literal."""
    return "[12]string{" + ", ".join(_quote(s) for s in items) + "}"


def _str_array_7(items: list[str]) -> str:
    """Emit a Go [7]string{...} literal."""
    return "[7]string{" + ", ".join(_quote(s) for s in items) + "}"


def _str_map(d: dict[str, str]) -> str:
    """Emit a Go map[string]string{...} literal."""
    if not d:
        return "map[string]string{}"
    pairs = [f"{_quote(k)}: {_quote(v)}" for k, v in d.items()]
    return "map[string]string{" + ", ".join(pairs) + "}"


def _str_ptr(s: str) -> str:
    """Emit strPtr("...") call."""
    return f"strPtr({_quote(s)})"


def _opt_str(data: dict, key: str) -> str:
    """Return strPtr(...) if key present, else nil."""
    if key in data:
        return _str_ptr(data[key])
    return "nil"


def emit_locale(data: dict) -> str:
    """Generate a Go locale file from canonical JSON."""
    code = data["code"]
    name = data["name"]
    uc = code.upper()

    lines = [HEADER + locale_source_comment(code), "package locales\n"]
    lines.append('import sdate "github.com/dnf/sayable/date/impl/go"\n')
    lines.append(f"// {uc} is the {name} locale.")
    lines.append(f"var {uc} = sdate.DateLocale{{")

    # Code
    lines.append(f"\tCode: {_quote(code)},")

    # Months & Weekdays
    lines.append(f"\tMonths:   {_str_array_12(data['months'])},")
    lines.append(f"\tWeekdays: {_str_array_7(data['weekdays'])},")

    # DayFormat
    lines.append(f"\tDayFormat: {_quote(data['dayFormat'])},")

    # DayFormatExceptions
    exceptions = data.get("dayFormatExceptions", {})
    lines.append(f"\tDayFormatExceptions: {_str_map(exceptions)},")

    # Date patterns
    lines.append(f"\tDatePattern:         {_quote(data['datePattern'])},")
    lines.append(f"\tDatePatternWithYear: {_quote(data['datePatternWithYear'])},")

    # Required strings
    lines.append(f"\tToday:     {_quote(data['today'])},")
    lines.append(f"\tTomorrow:  {_quote(data['tomorrow'])},")
    lines.append(f"\tYesterday: {_quote(data['yesterday'])},")

    # Optional strings
    lines.append(f"\tDayAfterTomorrow:  {_opt_str(data, 'dayAfterTomorrow')},")
    lines.append(f"\tDayBeforeYesterday: {_opt_str(data, 'dayBeforeYesterday')},")
    lines.append(f"\tThisWeekday:       {_opt_str(data, 'thisWeekday')},")
    lines.append(f"\tNextWeekday:       {_opt_str(data, 'nextWeekday')},")
    lines.append(f"\tLastWeekday:       {_opt_str(data, 'lastWeekday')},")

    # MonthsInDate (optional *[12]string)
    if "monthsInDate" in data:
        lines.append(f"\tMonthsInDate: &{_str_array_12(data['monthsInDate'])},")
    else:
        lines.append("\tMonthsInDate: nil,")

    # Short override
    if "short" in data:
        ovr = data["short"]
        lines.append("\tShort: &sdate.CompactnessOverride{")
        if "months" in ovr:
            lines.append(f"\t\tMonths:   &{_str_array_12(ovr['months'])},")
        else:
            lines.append("\t\tMonths:   nil,")
        if "weekdays" in ovr:
            lines.append(f"\t\tWeekdays: &{_str_array_7(ovr['weekdays'])},")
        else:
            lines.append("\t\tWeekdays: nil,")
        if "dayFormat" in ovr:
            lines.append(f"\t\tDayFormat:            {_str_ptr(ovr['dayFormat'])},")
        if "datePattern" in ovr:
            lines.append(f"\t\tDatePattern:          {_str_ptr(ovr['datePattern'])},")
        if "datePatternWithYear" in ovr:
            lines.append(f"\t\tDatePatternWithYear:  {_str_ptr(ovr['datePatternWithYear'])},")
        lines.append("\t},")
    else:
        lines.append("\tShort: nil,")

    # Compact override
    if "compact" in data:
        ovr = data["compact"]
        lines.append("\tCompact: &sdate.CompactnessOverride{")
        if "datePattern" in ovr:
            lines.append(f"\t\tDatePattern:         {_str_ptr(ovr['datePattern'])},")
        if "datePatternWithYear" in ovr:
            lines.append(f"\t\tDatePatternWithYear: {_str_ptr(ovr['datePatternWithYear'])},")
        lines.append("\t},")
    else:
        lines.append("\tCompact: nil,")

    lines.append("}")
    lines.append("")

    return "\n".join(lines)


def emit_barrel(all_locales: list[dict]) -> str | None:
    return None  # Go doesn't have barrel files


def emit_registry(all_locales: list[dict]) -> str:
    """Generate locale_registry.go with GetLocale function."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER, "package locales\n"]
    lines.append('import sdate "github.com/dnf/sayable/date/impl/go"\n')
    lines.append("// GetLocale returns the locale for the given code, or nil if not found.")
    lines.append("func GetLocale(code string) *sdate.DateLocale {")
    lines.append("\tswitch code {")
    for loc in sorted_locs:
        code = loc["code"]
        lines.append(f'\tcase {_quote(code)}:')
        lines.append(f"\t\treturn &{code.upper()}")
    lines.append("\tdefault:")
    lines.append("\t\treturn nil")
    lines.append("\t}")
    lines.append("}")
    lines.append("")
    return "\n".join(lines)


def emit_helpers() -> str:
    """Generate helpers.go with strPtr for the locales subpackage."""
    lines = [HEADER, "package locales\n"]
    lines.append("func strPtr(s string) *string { return &s }")
    lines.append("")
    return "\n".join(lines)


def output_path(code: str, root: str) -> str:
    import os
    return os.path.join(root, "impl", "go", "locales", f"locale_{code}.go")


def registry_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "go", "locales", "locale_registry.go")


def helpers_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "go", "locales", "helpers.go")


def barrel_path(root: str) -> str | None:
    return None
