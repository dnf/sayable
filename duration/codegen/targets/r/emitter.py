"""R locale emitter for sayable-duration."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header
from codegen.targets.r.plural_rules import get_r_named_function, get_r_plural, is_simple_plural

HEADER = make_header("codegen/targets/r/emitter.py", line_prefix="# ")


def _quote(s: str) -> str:
    """Quote a string for R."""
    escaped = s.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def _unit_forms(unit: object) -> str:
    """Emit a UnitForms value."""
    if isinstance(unit, str):
        return _quote(unit)
    cats = ["zero", "one", "two", "few", "many", "other"]
    pairs = []
    for cat in cats:
        if cat in unit:
            pairs.append(f'{cat} = {_quote(unit[cat])}')
    return "list(" + ", ".join(pairs) + ")"


def emit_locale(data: dict) -> str:
    code = data["code"]
    rule = data["pluralRule"]
    var_name = code.replace("-", "_")

    lines = [HEADER + locale_source_comment(code, line_prefix="# ")]

    # Named plural function
    named_fn = get_r_named_function(rule)
    if named_fn:
        lines.append(named_fn)
        lines.append("")

    # Locale list
    plural_expr = get_r_plural(rule)

    elements = []
    elements.append(f"  code = {_quote(code)}")
    elements.append(f"  plural = {plural_expr}")

    # Units (7 units for duration)
    unit_parts = []
    for unit_name in ("second", "minute", "hour", "day", "week", "month", "year"):
        val = _unit_forms(data["units"][unit_name])
        unit_parts.append(f"    {unit_name} = {val}")
    elements.append("  units = list(\n" + ",\n".join(unit_parts) + "\n  )")

    # Simple fields
    elements.append(f"  half = {_quote(data['half'])}")
    elements.append(f"  delimiter = {_quote(data['delimiter'])}")
    elements.append(f"  just_now = {_quote(data['justNow'])}")
    elements.append(f"  ago = {_quote(data['ago'])}")
    elements.append(f"  in_future = {_quote(data['inFuture'])}")

    # Short/compact
    for mode in ("short", "compact"):
        if mode in data:
            ovr = data[mode]
            sc_parts = []
            if "units" in ovr:
                ovr_unit_parts = []
                for unit_name in ("second", "minute", "hour", "day", "week", "month", "year"):
                    if unit_name in ovr["units"]:
                        val = _unit_forms(ovr["units"][unit_name])
                        ovr_unit_parts.append(f"      {unit_name} = {val}")
                sc_parts.append("    units = list(\n" + ",\n".join(ovr_unit_parts) + "\n    )")
            if "half" in ovr:
                sc_parts.append(f"    half = {_quote(ovr['half'])}")
            if "delimiter" in ovr:
                sc_parts.append(f"    delimiter = {_quote(ovr['delimiter'])}")
            if "ago" in ovr:
                sc_parts.append(f"    ago = {_quote(ovr['ago'])}")
            if "inFuture" in ovr:
                sc_parts.append(f"    in_future = {_quote(ovr['inFuture'])}")
            elements.append(f"  {mode} = list(\n" + ",\n".join(sc_parts) + "\n  )")

    lines.append(f"locale_{var_name} <- list(")
    lines.append(",\n".join(elements))
    lines.append(")")
    lines.append("")

    return "\n".join(lines)


def emit_barrel(all_locales: list[dict]) -> str:
    """Generate the registry module."""
    lines = [HEADER]

    lines.append("# Registry of all duration locales.")
    lines.append("# Source a locale file on demand and cache the result.")
    lines.append("")
    lines.append(".duration_locale_cache <- new.env(parent = emptyenv())")
    lines.append("")
    lines.append("get_duration_locale <- function(code) {")
    lines.append("  if (exists(code, envir = .duration_locale_cache)) {")
    lines.append("    return(get(code, envir = .duration_locale_cache))")
    lines.append("  }")
    lines.append("  locale_dir <- file.path(dirname(sys.frame(sys.nframe())$ofile), \".\")")
    lines.append("  path <- file.path(locale_dir, paste0(code, \".R\"))")
    lines.append("  if (!file.exists(path)) return(NULL)")
    lines.append("  env <- new.env(parent = baseenv())")
    lines.append("  source(path, local = env)")
    lines.append("  var_name <- paste0(\"locale_\", gsub(\"-\", \"_\", code))")
    lines.append("  if (!exists(var_name, envir = env)) return(NULL)")
    lines.append("  locale <- get(var_name, envir = env)")
    lines.append("  assign(code, locale, envir = .duration_locale_cache)")
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
