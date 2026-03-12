"""PowerShell locale emitter for sayable-date."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header

HEADER = make_header("codegen/targets/powershell/emitter.py", line_prefix="# ")


def _quote(s: str) -> str:
    """Quote a string for PowerShell using single quotes."""
    escaped = s.replace("'", "''")
    return f"'{escaped}'"


def _str_list(items: list[str]) -> str:
    """Emit a PowerShell array of strings."""
    return "@(" + ", ".join(_quote(s) for s in items) + ")"


def _dict_str(d: dict[str, str]) -> str:
    """Emit a PowerShell hashtable of str->str."""
    pairs = [f"{k} = {_quote(v)}" for k, v in d.items()]
    return "@{ " + "; ".join(pairs) + " }"


def emit_locale(data: dict) -> str:
    """Generate a PowerShell locale file from canonical JSON."""
    code = data["code"]

    lines = [HEADER + locale_source_comment(code, line_prefix="# ")]

    # Locale function that returns a hashtable
    lines.append(f"function locale_{code} {{")

    # Months
    lines.append(f"    $months = {_str_list(data['months'])}")

    # Weekdays
    lines.append(f"    $weekdays = {_str_list(data['weekdays'])}")

    # Day format
    lines.append(f"    $dayFormat = {_quote(data['dayFormat'])}")

    # Day format exceptions
    if "dayFormatExceptions" in data and data["dayFormatExceptions"]:
        lines.append(f"    $dayFormatExceptions = {_dict_str(data['dayFormatExceptions'])}")
    else:
        lines.append("    $dayFormatExceptions = @{}")

    # Patterns
    lines.append(f"    $datePattern = {_quote(data['datePattern'])}")
    lines.append(f"    $datePatternWithYear = {_quote(data['datePatternWithYear'])}")

    # Proximity strings
    lines.append(f"    $today = {_quote(data['today'])}")
    lines.append(f"    $tomorrow = {_quote(data['tomorrow'])}")
    lines.append(f"    $yesterday = {_quote(data['yesterday'])}")

    # Optional proximity strings
    day_after = _quote(data["dayAfterTomorrow"]) if "dayAfterTomorrow" in data else "$null"
    day_before = _quote(data["dayBeforeYesterday"]) if "dayBeforeYesterday" in data else "$null"
    this_wd = _quote(data["thisWeekday"]) if "thisWeekday" in data else "$null"
    next_wd = _quote(data["nextWeekday"]) if "nextWeekday" in data else "$null"
    last_wd = _quote(data["lastWeekday"]) if "lastWeekday" in data else "$null"

    lines.append(f"    $dayAfterTomorrow = {day_after}")
    lines.append(f"    $dayBeforeYesterday = {day_before}")
    lines.append(f"    $thisWeekday = {this_wd}")
    lines.append(f"    $nextWeekday = {next_wd}")
    lines.append(f"    $lastWeekday = {last_wd}")

    # Optional monthsInDate
    if "monthsInDate" in data:
        lines.append(f"    $monthsInDate = {_str_list(data['monthsInDate'])}")
    else:
        lines.append("    $monthsInDate = $null")

    # Short/compact overrides
    for mode in ("short", "compact"):
        if mode in data:
            ovr = data[mode]
            lines.append(f"    ${mode} = @{{")
            if "months" in ovr:
                lines.append(f"        months = {_str_list(ovr['months'])}")
            if "weekdays" in ovr:
                lines.append(f"        weekdays = {_str_list(ovr['weekdays'])}")
            if "dayFormat" in ovr:
                lines.append(f"        dayFormat = {_quote(ovr['dayFormat'])}")
            if "dayFormatExceptions" in ovr:
                lines.append(f"        dayFormatExceptions = {_dict_str(ovr['dayFormatExceptions'])}")
            if "datePattern" in ovr:
                lines.append(f"        datePattern = {_quote(ovr['datePattern'])}")
            if "datePatternWithYear" in ovr:
                lines.append(f"        datePatternWithYear = {_quote(ovr['datePatternWithYear'])}")
            if "today" in ovr:
                lines.append(f"        today = {_quote(ovr['today'])}")
            if "tomorrow" in ovr:
                lines.append(f"        tomorrow = {_quote(ovr['tomorrow'])}")
            if "yesterday" in ovr:
                lines.append(f"        yesterday = {_quote(ovr['yesterday'])}")
            lines.append("    }")
        else:
            lines.append(f"    ${mode} = $null")

    # Return the locale hashtable
    lines.append("    return @{")
    lines.append(f"        code = {_quote(code)}")
    lines.append("        months = $months")
    lines.append("        weekdays = $weekdays")
    lines.append("        dayFormat = $dayFormat")
    lines.append("        dayFormatExceptions = $dayFormatExceptions")
    lines.append("        datePattern = $datePattern")
    lines.append("        datePatternWithYear = $datePatternWithYear")
    lines.append("        today = $today")
    lines.append("        tomorrow = $tomorrow")
    lines.append("        yesterday = $yesterday")
    lines.append("        dayAfterTomorrow = $dayAfterTomorrow")
    lines.append("        dayBeforeYesterday = $dayBeforeYesterday")
    lines.append("        thisWeekday = $thisWeekday")
    lines.append("        nextWeekday = $nextWeekday")
    lines.append("        lastWeekday = $lastWeekday")
    lines.append("        monthsInDate = $monthsInDate")
    lines.append("        short = $short")
    lines.append("        compact = $compact")
    lines.append("    }")
    lines.append("}")
    lines.append("")

    return "\n".join(lines)


def emit_registry(all_locales: list[dict]) -> str:
    """Generate registry.ps1 with Get-SayableDateLocale function."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER]

    # Source all locale files
    lines.append("# Source all locale files relative to this script's directory")
    lines.append("$PSScriptRoot_ = $PSScriptRoot")
    lines.append("")
    for loc in sorted_locs:
        code = loc["code"]
        lines.append(f'. "$PSScriptRoot_/{code}.ps1"')
    lines.append("")

    # Build registry
    lines.append("$script:_sayabledateRegistry = [hashtable]::new([System.StringComparer]::Ordinal)")
    lines.append("")
    for loc in sorted_locs:
        code = loc["code"]
        lines.append(f"$script:_sayabledateRegistry[{_quote(code)}] = locale_{code}")
    lines.append("")

    # Get-locale function
    lines.append("function Get-SayableDateLocale {")
    lines.append("    param([string]$Code)")
    lines.append("    if ($script:_sayabledateRegistry.ContainsKey($Code)) {")
    lines.append("        return $script:_sayabledateRegistry[$Code]")
    lines.append("    }")
    lines.append("    return $null")
    lines.append("}")
    lines.append("")

    return "\n".join(lines)


def output_path(code: str, root: str) -> str:
    import os
    return os.path.join(root, "impl", "powershell", "locales", f"{code}.ps1")


def registry_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "powershell", "locales", "registry.ps1")
