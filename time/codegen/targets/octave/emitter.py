"""Octave locale emitter for sayable-time."""

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


def emit_locale(data: dict) -> str:
    """Generate an Octave locale file from canonical JSON."""
    code = data["code"]
    clock = data["clock"]
    fn_name = _func_name(code)

    lines = [HEADER + locale_source_comment(code, line_prefix="% ")]

    lines.append(f"function loc = {fn_name}()")
    lines.append(f"  loc.code = {_quote(code)};")

    # Clock config
    lines.append(f"  loc.clock.hours = {_str_list(clock['hours'])};")
    lines.append(f"  loc.clock.midnight = {_quote(clock['midnight'])};")
    lines.append(f"  loc.clock.noon = {_quote(clock['noon'])};")

    # Patterns as struct
    pattern_keys = ["0", "5", "10", "15", "20", "25", "30", "35", "40", "45", "50", "55"]
    pairs = []
    for key in pattern_keys:
        if key in clock["patterns"]:
            pairs.append(f'"p{key}", {_quote(clock["patterns"][key])}')
    lines.append(f"  loc.clock.patterns = struct({', '.join(pairs)});")

    # Short override
    if "short" in data:
        sc = data["short"].get("clock", {})
        use24h = sc.get("use24h", True)
        fmt = sc.get("format", "{h}:{mm}")
        am_pm = sc.get("amPm")
        lines.append(f"  loc.short.clock.use24h = {'true' if use24h else 'false'};")
        lines.append(f"  loc.short.clock.format = {_quote(fmt)};")
        if am_pm:
            lines.append(f"  loc.short.clock.am_pm = {{{_quote(am_pm[0])}, {_quote(am_pm[1])}}};")
        else:
            lines.append("  loc.short.clock.am_pm = {};")

    # Compact override
    if "compact" in data:
        sc = data["compact"].get("clock", {})
        use24h = sc.get("use24h", True)
        fmt = sc.get("format", "{h}:{mm}")
        am_pm = sc.get("amPm")
        lines.append(f"  loc.compact.clock.use24h = {'true' if use24h else 'false'};")
        lines.append(f"  loc.compact.clock.format = {_quote(fmt)};")
        if am_pm:
            lines.append(f"  loc.compact.clock.am_pm = {{{_quote(am_pm[0])}, {_quote(am_pm[1])}}};")
        else:
            lines.append("  loc.compact.clock.am_pm = {};")

    lines.append("endfunction")
    lines.append("")

    return "\n".join(lines)


def emit_barrel(all_locales: list[dict]) -> str:
    """Generate the registry function that maps locale codes to locale data."""
    lines = [HEADER]

    lines.append("function loc = get_time_locale(code)")
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
    return os.path.join(root, "impl", "octave", "locales", "get_time_locale.m")
