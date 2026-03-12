"""Octave locale emitter for sayable-date."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header

HEADER = make_header("codegen/targets/octave/emitter.py", line_prefix="% ")


def _quote(s: str) -> str:
    """Quote a string for Octave."""
    escaped = s.replace("'", "''")
    return f"'{escaped}'"


def _func_name(code: str) -> str:
    """Locale code to valid Octave function name."""
    return "locale_" + code.replace("-", "_")


def _str_list(items: list[str]) -> str:
    """Emit an Octave cell array of strings."""
    return "{" + ", ".join(_quote(s) for s in items) + "}"


def _dict_struct(d: dict[str, str]) -> str:
    """Emit a struct from a dict of str->str."""
    if not d:
        return "struct()"
    pairs = []
    for k, v in d.items():
        pairs.append(f'"{k}", {_quote(v)}')
    return "struct(" + ", ".join(pairs) + ")"


def emit_locale(data: dict) -> str:
    """Generate an Octave locale file from canonical JSON."""
    code = data["code"]
    fn_name = _func_name(code)

    lines = [HEADER + locale_source_comment(code, line_prefix="% ")]

    lines.append(f"function loc = {fn_name}()")
    lines.append(f"  loc.code = {_quote(code)};")

    # Months
    lines.append(f"  loc.months = {_str_list(data['months'])};")

    # Weekdays
    lines.append(f"  loc.weekdays = {_str_list(data['weekdays'])};")

    # Day format
    lines.append(f"  loc.day_format = {_quote(data['dayFormat'])};")

    # Day format exceptions
    if "dayFormatExceptions" in data and data["dayFormatExceptions"]:
        lines.append(f"  loc.day_format_exceptions = {_dict_struct(data['dayFormatExceptions'])};")
    else:
        lines.append("  loc.day_format_exceptions = struct();")

    # Date patterns
    lines.append(f"  loc.date_pattern = {_quote(data['datePattern'])};")
    lines.append(f"  loc.date_pattern_with_year = {_quote(data['datePatternWithYear'])};")

    # Proximity words
    lines.append(f"  loc.today = {_quote(data['today'])};")
    lines.append(f"  loc.tomorrow = {_quote(data['tomorrow'])};")
    lines.append(f"  loc.yesterday = {_quote(data['yesterday'])};")

    # Optional proximity fields
    if "dayAfterTomorrow" in data:
        lines.append(f"  loc.day_after_tomorrow = {_quote(data['dayAfterTomorrow'])};")
    else:
        lines.append("  loc.day_after_tomorrow = '';")

    if "dayBeforeYesterday" in data:
        lines.append(f"  loc.day_before_yesterday = {_quote(data['dayBeforeYesterday'])};")
    else:
        lines.append("  loc.day_before_yesterday = '';")

    if "thisWeekday" in data:
        lines.append(f"  loc.this_weekday = {_quote(data['thisWeekday'])};")
    else:
        lines.append("  loc.this_weekday = '';")

    if "nextWeekday" in data:
        lines.append(f"  loc.next_weekday = {_quote(data['nextWeekday'])};")
    else:
        lines.append("  loc.next_weekday = '';")

    if "lastWeekday" in data:
        lines.append(f"  loc.last_weekday = {_quote(data['lastWeekday'])};")
    else:
        lines.append("  loc.last_weekday = '';")

    # Months in date (genitive forms)
    if "monthsInDate" in data:
        lines.append(f"  loc.months_in_date = {_str_list(data['monthsInDate'])};")
    else:
        lines.append("  loc.months_in_date = {};")

    # Short override
    if "short" in data:
        ovr = data["short"]
        if "months" in ovr:
            lines.append(f"  loc.short.months = {_str_list(ovr['months'])};")
        if "weekdays" in ovr:
            lines.append(f"  loc.short.weekdays = {_str_list(ovr['weekdays'])};")
        if "dayFormat" in ovr:
            lines.append(f"  loc.short.day_format = {_quote(ovr['dayFormat'])};")
        if "dayFormatExceptions" in ovr:
            lines.append(f"  loc.short.day_format_exceptions = {_dict_struct(ovr['dayFormatExceptions'])};")
        if "datePattern" in ovr:
            lines.append(f"  loc.short.date_pattern = {_quote(ovr['datePattern'])};")
        if "datePatternWithYear" in ovr:
            lines.append(f"  loc.short.date_pattern_with_year = {_quote(ovr['datePatternWithYear'])};")

    # Compact override
    if "compact" in data:
        ovr = data["compact"]
        if "datePattern" in ovr:
            lines.append(f"  loc.compact.date_pattern = {_quote(ovr['datePattern'])};")
        if "datePatternWithYear" in ovr:
            lines.append(f"  loc.compact.date_pattern_with_year = {_quote(ovr['datePatternWithYear'])};")

    lines.append("endfunction")
    lines.append("")

    return "\n".join(lines)


def emit_barrel(all_locales: list[dict]) -> str:
    """Generate the registry function that maps locale codes to locale data."""
    lines = [HEADER]

    lines.append("function loc = get_date_locale(code)")
    lines.append("  persistent cache;")
    lines.append("  if (isempty(cache))")
    lines.append("    cache = struct();")
    lines.append("  endif")
    lines.append("  safe_key = strrep(code, '-', '_');")
    lines.append("  if (isfield(cache, safe_key))")
    lines.append("    loc = cache.(safe_key);")
    lines.append("    return;")
    lines.append("  endif")
    lines.append("  loc_dir = fileparts(mfilename('fullpath'));")
    lines.append("  if (isempty(loc_dir))")
    lines.append("    loc_dir = '.';")
    lines.append("  endif")
    lines.append("  loc_file = fullfile(loc_dir, ['locale_' safe_key '.m']);")
    lines.append("  if (!exist(loc_file, 'file'))")
    lines.append("    loc = [];")
    lines.append("    return;")
    lines.append("  endif")
    lines.append("  old_path = path();")
    lines.append("  addpath(loc_dir);")
    lines.append("  try")
    lines.append("    loc = feval(['locale_' safe_key]);")
    lines.append("  catch")
    lines.append("    loc = [];")
    lines.append("  end")
    lines.append("  path(old_path);")
    lines.append("  if (!isempty(loc))")
    lines.append("    cache.(safe_key) = loc;")
    lines.append("  endif")
    lines.append("endfunction")
    lines.append("")

    return "\n".join(lines)


def output_path(code: str, root: str) -> str:
    import os
    var_name = code.replace("-", "_")
    return os.path.join(root, "impl", "octave", "locales", f"locale_{var_name}.m")


def barrel_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "octave", "locales", "get_date_locale.m")
