"""R locale emitter for sayable-time."""

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


def emit_locale(data: dict) -> str:
    """Generate an R locale file from canonical JSON."""
    code = data["code"]
    var_name = code.replace("-", "_")
    clock = data["clock"]
    lines = [HEADER + locale_source_comment(code, line_prefix="# ")]

    elements = []
    elements.append(f"  code = {_quote(code)}")

    # Clock config
    clock_parts = []
    clock_parts.append(f"    hours = {_str_list(clock['hours'])}")
    clock_parts.append(f"    midnight = {_quote(clock['midnight'])}")
    clock_parts.append(f"    noon = {_quote(clock['noon'])}")

    # Patterns as a named list with integer-like keys
    pattern_parts = []
    for key in ("0", "5", "10", "15", "20", "25", "30", "35", "40", "45", "50", "55"):
        if key in clock["patterns"]:
            pattern_parts.append(f'      "{key}" = {_quote(clock["patterns"][key])}')
    clock_parts.append("    patterns = list(\n" + ",\n".join(pattern_parts) + "\n    )")

    elements.append("  clock = list(\n" + ",\n".join(clock_parts) + "\n  )")

    # Short/compact overrides
    for mode in ("short", "compact"):
        if mode in data:
            ovr = data[mode]
            sc = ovr.get("clock", {})
            use24h = sc.get("use24h", True)
            fmt = sc.get("format", "{h}:{mm}")
            am_pm = sc.get("amPm")
            sc_parts = []
            clock_sc_parts = []
            clock_sc_parts.append(f"      use24h = {'TRUE' if use24h else 'FALSE'}")
            clock_sc_parts.append(f"      format = {_quote(fmt)}")
            if am_pm:
                clock_sc_parts.append(f"      am_pm = c({_quote(am_pm[0])}, {_quote(am_pm[1])})")
            sc_parts.append("    clock = list(\n" + ",\n".join(clock_sc_parts) + "\n    )")
            elements.append(f"  {mode} = list(\n" + ",\n".join(sc_parts) + "\n  )")

    lines.append(f"locale_{var_name} <- list(")
    lines.append(",\n".join(elements))
    lines.append(")")
    lines.append("")

    return "\n".join(lines)


def emit_barrel(all_locales: list[dict]) -> str:
    """Generate the registry module."""
    lines = [HEADER]

    lines.append("# Registry of all time locales.")
    lines.append("# Source a locale file on demand and cache the result.")
    lines.append("")
    lines.append(".time_locale_cache <- new.env(parent = emptyenv())")
    lines.append("")
    lines.append("get_time_locale <- function(code) {")
    lines.append("  if (exists(code, envir = .time_locale_cache)) {")
    lines.append("    return(get(code, envir = .time_locale_cache))")
    lines.append("  }")
    lines.append("  locale_dir <- file.path(dirname(sys.frame(sys.nframe())$ofile), \".\")")
    lines.append("  path <- file.path(locale_dir, paste0(code, \".R\"))")
    lines.append("  if (!file.exists(path)) return(NULL)")
    lines.append("  env <- new.env(parent = baseenv())")
    lines.append("  source(path, local = env)")
    lines.append("  var_name <- paste0(\"locale_\", gsub(\"-\", \"_\", code))")
    lines.append("  if (!exists(var_name, envir = env)) return(NULL)")
    lines.append("  locale <- get(var_name, envir = env)")
    lines.append("  assign(code, locale, envir = .time_locale_cache)")
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
