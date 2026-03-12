"""Odin locale emitter for sayable-date — single file with all locales.

Odin's package system equates directories with packages. A subdirectory
importing its parent creates a cyclic import. The generated locale file
therefore lives in the main package directory.
"""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header

HEADER = make_header("codegen/targets/odin/emitter.py")

_ODIN_KEYWORDS = frozenset([
    "auto_cast", "bit_set", "break", "case", "cast", "context", "continue",
    "defer", "distinct", "do", "dynamic", "else", "enum", "fallthrough",
    "for", "foreign", "if", "import", "in", "map", "matrix", "not_in",
    "or_else", "or_return", "package", "proc", "return", "struct", "switch",
    "transmute", "typeid", "union", "using", "when", "where",
])


def _ident(name: str) -> str:
    if name in _ODIN_KEYWORDS or (name and name[0].isdigit()):
        return f'`{name}`'
    return name


def _quote(s: str) -> str:
    escaped = s.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def _str_list(items: list[str], type_prefix: str = "") -> str:
    """Build an Odin array literal.

    When assigned to a Maybe field, Odin needs the explicit type prefix
    (e.g. ``[12]string{"a","b",...}``).  For non-Maybe fields the bare
    ``{"a","b",...}`` form is fine, so *type_prefix* defaults to empty.
    """
    parts = ", ".join(_quote(s) for s in items)
    return type_prefix + "{" + parts + "}"


def _int_str_map(d: dict[str, str]) -> str:
    if not d:
        return "{}"
    parts = []
    for k, v in d.items():
        parts.append(f"{k} = {_quote(v)}")
    return "{" + ", ".join(parts) + "}"


def emit_all(all_locales: list[dict]) -> str:
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])

    lines = [HEADER]
    lines.append("package sayabledate")
    lines.append("")

    for data in sorted_locs:
        code = data["code"]
        var_name = "locale_" + code.replace("-", "_")

        lines.append(locale_source_comment(code).rstrip())
        lines.append(f"{_ident(var_name)} : Date_Locale = {{")
        lines.append(f"    code = {_quote(code)},")

        # months
        lines.append(f"    months = {_str_list(data['months'])},")

        # weekdays
        lines.append(f"    weekdays = {_str_list(data['weekdays'])},")

        # day_format
        lines.append(f"    day_format = {_quote(data['dayFormat'])},")

        # day_format_exceptions
        if "dayFormatExceptions" in data:
            exc = data["dayFormatExceptions"]
            parts = []
            for k, v in exc.items():
                parts.append(f"Day_Format_Exception{{day = {k}, format = {_quote(v)}}}")
            lines.append(f"    day_format_exceptions = {{{', '.join(parts)}}},")
        else:
            lines.append("    day_format_exceptions = {},")

        # date_pattern, date_pattern_with_year
        lines.append(f"    date_pattern = {_quote(data['datePattern'])},")
        lines.append(f"    date_pattern_with_year = {_quote(data['datePatternWithYear'])},")

        # today, tomorrow, yesterday
        lines.append(f"    today = {_quote(data['today'])},")
        lines.append(f"    tomorrow = {_quote(data['tomorrow'])},")
        lines.append(f"    yesterday = {_quote(data['yesterday'])},")

        # optional proximity fields
        if "dayAfterTomorrow" in data:
            lines.append(f"    day_after_tomorrow = {_quote(data['dayAfterTomorrow'])},")
        else:
            lines.append("    day_after_tomorrow = nil,")

        if "dayBeforeYesterday" in data:
            lines.append(f"    day_before_yesterday = {_quote(data['dayBeforeYesterday'])},")
        else:
            lines.append("    day_before_yesterday = nil,")

        if "thisWeekday" in data:
            lines.append(f"    this_weekday = {_quote(data['thisWeekday'])},")
        else:
            lines.append("    this_weekday = nil,")

        if "nextWeekday" in data:
            lines.append(f"    next_weekday = {_quote(data['nextWeekday'])},")
        else:
            lines.append("    next_weekday = nil,")

        if "lastWeekday" in data:
            lines.append(f"    last_weekday = {_quote(data['lastWeekday'])},")
        else:
            lines.append("    last_weekday = nil,")

        if "monthsInDate" in data:
            lines.append(f"    months_in_date = {_str_list(data['monthsInDate'], '[12]string')},")
        else:
            lines.append("    months_in_date = nil,")

        # short override
        if "short" in data:
            ovr = data["short"]
            lines.append("    short_override = Date_Compactness_Override{")
            if "months" in ovr:
                lines.append(f"        months = {_str_list(ovr['months'], '[12]string')},")
            else:
                lines.append("        months = nil,")
            if "monthsInDate" in ovr:
                lines.append(f"        months_in_date = {_str_list(ovr['monthsInDate'], '[12]string')},")
            else:
                lines.append("        months_in_date = nil,")
            if "weekdays" in ovr:
                lines.append(f"        weekdays = {_str_list(ovr['weekdays'], '[7]string')},")
            else:
                lines.append("        weekdays = nil,")
            if "dayFormat" in ovr:
                lines.append(f"        day_format = {_quote(ovr['dayFormat'])},")
            else:
                lines.append("        day_format = nil,")
            if "dayFormatExceptions" in ovr:
                exc = ovr["dayFormatExceptions"]
                parts = []
                for k, v in exc.items():
                    parts.append(f"Day_Format_Exception{{day = {k}, format = {_quote(v)}}}")
                lines.append(f"        day_format_exceptions = {{{', '.join(parts)}}},")
            else:
                lines.append("        day_format_exceptions = nil,")
            if "datePattern" in ovr:
                lines.append(f"        date_pattern = {_quote(ovr['datePattern'])},")
            else:
                lines.append("        date_pattern = nil,")
            if "datePatternWithYear" in ovr:
                lines.append(f"        date_pattern_with_year = {_quote(ovr['datePatternWithYear'])},")
            else:
                lines.append("        date_pattern_with_year = nil,")
            if "today" in ovr:
                lines.append(f"        today = {_quote(ovr['today'])},")
            else:
                lines.append("        today = nil,")
            if "tomorrow" in ovr:
                lines.append(f"        tomorrow = {_quote(ovr['tomorrow'])},")
            else:
                lines.append("        tomorrow = nil,")
            if "yesterday" in ovr:
                lines.append(f"        yesterday = {_quote(ovr['yesterday'])},")
            else:
                lines.append("        yesterday = nil,")
            lines.append("    },")
        else:
            lines.append("    short_override = nil,")

        # compact override
        if "compact" in data:
            ovr = data["compact"]
            lines.append("    compact_override = Date_Compactness_Override{")
            lines.append("        months = nil,")
            lines.append("        months_in_date = nil,")
            lines.append("        weekdays = nil,")
            lines.append("        day_format = nil,")
            lines.append("        day_format_exceptions = nil,")
            if "datePattern" in ovr:
                lines.append(f"        date_pattern = {_quote(ovr['datePattern'])},")
            else:
                lines.append("        date_pattern = nil,")
            if "datePatternWithYear" in ovr:
                lines.append(f"        date_pattern_with_year = {_quote(ovr['datePatternWithYear'])},")
            else:
                lines.append("        date_pattern_with_year = nil,")
            lines.append("        today = nil,")
            lines.append("        tomorrow = nil,")
            lines.append("        yesterday = nil,")
            lines.append("    },")
        else:
            lines.append("    compact_override = nil,")

        lines.append("}")
        lines.append("")

    # get_locale function
    lines.append("get_locale :: proc(code: string) -> ^Date_Locale {")
    lines.append("    switch code {")
    for data in sorted_locs:
        c = data["code"]
        var_name = "locale_" + c.replace("-", "_")
        lines.append(f'    case {_quote(c)}: return &{_ident(var_name)}')
    lines.append("    case: return nil")
    lines.append("    }")
    lines.append("}")
    lines.append("")

    return "\n".join(lines)


def output_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "odin", "locales.odin")
