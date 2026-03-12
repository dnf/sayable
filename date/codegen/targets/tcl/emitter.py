"""Tcl locale emitter for sayable-date."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header

HEADER = make_header("codegen/targets/tcl/emitter.py", line_prefix="# ")


def _quote(s: str) -> str:
    """Quote a string for Tcl — use braces for literal strings."""
    if "{" in s or "}" in s or "\\" in s:
        escaped = s.replace("\\", "\\\\").replace('"', '\\"').replace("[", "\\[").replace("$", "\\$")
        return f'"{escaped}"'
    return "{" + s + "}"


def _str_list(items: list[str]) -> str:
    """Emit a Tcl list of strings."""
    return "[list " + " ".join(_quote(s) for s in items) + "]"


def _dict_str(d: dict[str, str]) -> str:
    """Emit a Tcl dict of str->str."""
    if not d:
        return "[dict create]"
    pairs = []
    for k, v in d.items():
        pairs.append(f"{_quote(k)} {_quote(v)}")
    return "[dict create " + " ".join(pairs) + "]"


def emit_locale(data: dict) -> str:
    """Generate a Tcl locale file from canonical JSON."""
    code = data["code"]

    lines = [HEADER + locale_source_comment(code, line_prefix="# ")]

    # Locale proc that returns a dict
    lines.append(f"proc locale_date_{code} {{}} {{")
    lines.append(f"    set code {_quote(code)}")

    # Months
    lines.append(f"    set months {_str_list(data['months'])}")

    # Weekdays
    lines.append(f"    set weekdays {_str_list(data['weekdays'])}")

    # Day format
    lines.append(f"    set day_format {_quote(data['dayFormat'])}")

    # Day format exceptions
    if "dayFormatExceptions" in data and data["dayFormatExceptions"]:
        lines.append(f"    set day_format_exceptions {_dict_str(data['dayFormatExceptions'])}")
    else:
        lines.append("    set day_format_exceptions [dict create]")

    # Patterns
    lines.append(f"    set date_pattern {_quote(data['datePattern'])}")
    lines.append(f"    set date_pattern_with_year {_quote(data['datePatternWithYear'])}")

    # Proximity words
    lines.append(f"    set today {_quote(data['today'])}")
    lines.append(f"    set tomorrow {_quote(data['tomorrow'])}")
    lines.append(f"    set yesterday {_quote(data['yesterday'])}")

    # Optional proximity fields
    for json_key, tcl_key in [
        ("dayAfterTomorrow", "day_after_tomorrow"),
        ("dayBeforeYesterday", "day_before_yesterday"),
        ("thisWeekday", "this_weekday"),
        ("nextWeekday", "next_weekday"),
        ("lastWeekday", "last_weekday"),
    ]:
        if json_key in data:
            lines.append(f"    set {tcl_key} {_quote(data[json_key])}")
        else:
            lines.append(f'    set {tcl_key} ""')

    # Optional months_in_date (genitive forms)
    if "monthsInDate" in data:
        lines.append(f"    set months_in_date {_str_list(data['monthsInDate'])}")
    else:
        lines.append('    set months_in_date ""')

    # Short/compact overrides
    for mode in ("short", "compact"):
        if mode in data:
            ovr = data[mode]
            lines.append(f"    set {mode} [dict create \\")
            if "months" in ovr:
                lines.append(f"        months {_str_list(ovr['months'])} \\")
            if "weekdays" in ovr:
                lines.append(f"        weekdays {_str_list(ovr['weekdays'])} \\")
            if "dayFormat" in ovr:
                lines.append(f"        day_format {_quote(ovr['dayFormat'])} \\")
            if "dayFormatExceptions" in ovr:
                lines.append(f"        day_format_exceptions {_dict_str(ovr['dayFormatExceptions'])} \\")
            if "datePattern" in ovr:
                lines.append(f"        date_pattern {_quote(ovr['datePattern'])} \\")
            if "datePatternWithYear" in ovr:
                lines.append(f"        date_pattern_with_year {_quote(ovr['datePatternWithYear'])} \\")
            lines.append("    ]")
        else:
            lines.append(f"    set {mode} [dict create]")

    # Build the locale dict
    lines.append("    return [dict create \\")
    lines.append("        code $code \\")
    lines.append("        months $months \\")
    lines.append("        weekdays $weekdays \\")
    lines.append("        day_format $day_format \\")
    lines.append("        day_format_exceptions $day_format_exceptions \\")
    lines.append("        date_pattern $date_pattern \\")
    lines.append("        date_pattern_with_year $date_pattern_with_year \\")
    lines.append("        today $today \\")
    lines.append("        tomorrow $tomorrow \\")
    lines.append("        yesterday $yesterday \\")
    lines.append("        day_after_tomorrow $day_after_tomorrow \\")
    lines.append("        day_before_yesterday $day_before_yesterday \\")
    lines.append("        this_weekday $this_weekday \\")
    lines.append("        next_weekday $next_weekday \\")
    lines.append("        last_weekday $last_weekday \\")
    lines.append("        months_in_date $months_in_date \\")
    lines.append("        short $short \\")
    lines.append("        compact $compact \\")
    lines.append("    ]")
    lines.append("}")
    lines.append("")

    return "\n".join(lines)


def emit_registry(all_locales: list[dict]) -> str:
    """Generate registry.tcl with get_locale proc."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER]

    # Source all locale files
    lines.append("# Source all locale files relative to this script's directory")
    lines.append("set _sayabledate_locales_dir [file dirname [info script]]")
    lines.append("")
    for loc in sorted_locs:
        code = loc["code"]
        lines.append(f'source [file join $_sayabledate_locales_dir "{code}.tcl"]')
    lines.append("")

    # Registry dict
    lines.append("# Build locale registry")
    lines.append("proc _sayabledate_build_registry {} {")
    lines.append("    set registry [dict create]")
    for loc in sorted_locs:
        code = loc["code"]
        lines.append(f"    dict set registry {_quote(code)} [locale_date_{code}]")
    lines.append("    return $registry")
    lines.append("}")
    lines.append("")
    lines.append("set ::_sayabledate_registry [_sayabledate_build_registry]")
    lines.append("")

    # get_locale
    lines.append("proc sayabledate_get_locale {code} {")
    lines.append("    if {[dict exists $::_sayabledate_registry $code]} {")
    lines.append("        return [dict get $::_sayabledate_registry $code]")
    lines.append("    }")
    lines.append('    return ""')
    lines.append("}")
    lines.append("")

    return "\n".join(lines)


def output_path(code: str, root: str) -> str:
    import os
    return os.path.join(root, "impl", "tcl", "locales", f"{code}.tcl")


def registry_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "tcl", "locales", "registry.tcl")
