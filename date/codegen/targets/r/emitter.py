"""R locale emitter for sayable-date."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header

HEADER = make_header("codegen/targets/r/emitter.py", line_prefix="# ")


def _quote(s: str) -> str:
    """Quote a string for R."""
    escaped = s.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def _str_list(items: list[str]) -> str:
    """Emit an R character vector."""
    return "c(" + ", ".join(_quote(s) for s in items) + ")"


def _str_named_list(d: dict[str, str]) -> str:
    """Emit an R named list from string keys to string values."""
    pairs = [f'{_quote(k)} = {_quote(v)}' for k, v in d.items()]
    return "list(" + ", ".join(pairs) + ")"


def emit_locale(data: dict) -> str:
    """Generate an R locale file from canonical JSON."""
    code = data["code"]
    var_name = code.replace("-", "_")
    lines = [HEADER + locale_source_comment(code, line_prefix="# ")]

    elements = []
    elements.append(f"  code = {_quote(code)}")

    # Months (character vector)
    elements.append(f"  months = {_str_list(data['months'])}")

    # Weekdays (character vector, 1=Sunday)
    elements.append(f"  weekdays = {_str_list(data['weekdays'])}")

    # Day format
    elements.append(f"  day_format = {_quote(data['dayFormat'])}")

    # Day format exceptions
    if "dayFormatExceptions" in data and data["dayFormatExceptions"]:
        elements.append(f"  day_format_exceptions = {_str_named_list(data['dayFormatExceptions'])}")
    else:
        elements.append("  day_format_exceptions = list()")

    # Date patterns
    elements.append(f"  date_pattern = {_quote(data['datePattern'])}")
    elements.append(f"  date_pattern_with_year = {_quote(data['datePatternWithYear'])}")

    # Proximity strings
    elements.append(f"  today = {_quote(data['today'])}")
    elements.append(f"  tomorrow = {_quote(data['tomorrow'])}")
    elements.append(f"  yesterday = {_quote(data['yesterday'])}")

    # Optional proximity fields
    if "dayAfterTomorrow" in data:
        elements.append(f"  day_after_tomorrow = {_quote(data['dayAfterTomorrow'])}")
    if "dayBeforeYesterday" in data:
        elements.append(f"  day_before_yesterday = {_quote(data['dayBeforeYesterday'])}")
    if "thisWeekday" in data:
        elements.append(f"  this_weekday = {_quote(data['thisWeekday'])}")
    if "nextWeekday" in data:
        elements.append(f"  next_weekday = {_quote(data['nextWeekday'])}")
    if "lastWeekday" in data:
        elements.append(f"  last_weekday = {_quote(data['lastWeekday'])}")
    if "monthsInDate" in data:
        elements.append(f"  months_in_date = {_str_list(data['monthsInDate'])}")

    # Short/compact overrides
    for mode in ("short", "compact"):
        if mode in data:
            ovr = data[mode]
            sc_parts = []
            if "months" in ovr:
                sc_parts.append(f"    months = {_str_list(ovr['months'])}")
            if "monthsInDate" in ovr:
                sc_parts.append(f"    months_in_date = {_str_list(ovr['monthsInDate'])}")
            if "weekdays" in ovr:
                sc_parts.append(f"    weekdays = {_str_list(ovr['weekdays'])}")
            if "dayFormat" in ovr:
                sc_parts.append(f"    day_format = {_quote(ovr['dayFormat'])}")
            if "dayFormatExceptions" in ovr:
                sc_parts.append(f"    day_format_exceptions = {_str_named_list(ovr['dayFormatExceptions'])}")
            if "datePattern" in ovr:
                sc_parts.append(f"    date_pattern = {_quote(ovr['datePattern'])}")
            if "datePatternWithYear" in ovr:
                sc_parts.append(f"    date_pattern_with_year = {_quote(ovr['datePatternWithYear'])}")
            if "today" in ovr:
                sc_parts.append(f"    today = {_quote(ovr['today'])}")
            if "tomorrow" in ovr:
                sc_parts.append(f"    tomorrow = {_quote(ovr['tomorrow'])}")
            if "yesterday" in ovr:
                sc_parts.append(f"    yesterday = {_quote(ovr['yesterday'])}")
            elements.append(f"  {mode} = list(\n" + ",\n".join(sc_parts) + "\n  )")

    lines.append(f"locale_{var_name} <- list(")
    lines.append(",\n".join(elements))
    lines.append(")")
    lines.append("")

    return "\n".join(lines)


def emit_barrel(all_locales: list[dict]) -> str:
    """Generate the registry module."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER]

    lines.append("# Registry of all date locales.")
    lines.append("# Source a locale file on demand and cache the result.")
    lines.append("")
    lines.append(".date_locale_cache <- new.env(parent = emptyenv())")
    lines.append("")
    lines.append("get_date_locale <- function(code) {")
    lines.append("  if (exists(code, envir = .date_locale_cache)) {")
    lines.append("    return(get(code, envir = .date_locale_cache))")
    lines.append("  }")
    lines.append("  locale_dir <- file.path(dirname(sys.frame(sys.nframe())$ofile), \".\")")
    lines.append("  path <- file.path(locale_dir, paste0(code, \".R\"))")
    lines.append("  if (!file.exists(path)) return(NULL)")
    lines.append("  env <- new.env(parent = baseenv())")
    lines.append("  source(path, local = env)")
    lines.append("  var_name <- paste0(\"locale_\", gsub(\"-\", \"_\", code))")
    lines.append("  if (!exists(var_name, envir = env)) return(NULL)")
    lines.append("  locale <- get(var_name, envir = env)")
    lines.append("  assign(code, locale, envir = .date_locale_cache)")
    lines.append("  locale")
    lines.append("}")
    lines.append("")

    return "\n".join(lines)


def output_path(code: str, root: str) -> str:
    import os
    return os.path.join(root, "impl", "r", "locales", f"{code}.R")


def barrel_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "r", "locales", "registry.R")
