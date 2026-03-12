"""Octave locale emitter for sayable-age."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header
from codegen.targets.octave.plural_rules import (
    get_octave_named_function,
    get_octave_plural,
    is_simple_plural,
)

HEADER = make_header("codegen/targets/octave/emitter.py", line_prefix="% ")


def _quote(s: str) -> str:
    """Quote a string for Octave."""
    escaped = s.replace("'", "''")
    return f"'{escaped}'"


def _func_name(code: str) -> str:
    """Locale code to valid Octave function name."""
    return "locale_" + code.replace("-", "_")


def _unit_forms(unit: object) -> str:
    """Emit a struct for unit forms."""
    if isinstance(unit, str):
        return _quote(unit)
    cats = ["zero", "one", "two", "few", "many", "other"]
    pairs = []
    for cat in cats:
        if cat in unit:
            pairs.append(f'"{cat}", {_quote(unit[cat])}')
    return "struct(" + ", ".join(pairs) + ")"


def _stage_label(stage: object) -> str:
    if isinstance(stage, str):
        return _quote(stage)
    return 'struct("m", ' + _quote(stage["m"]) + ', "f", ' + _quote(stage["f"]) + ")"


def emit_locale(data: dict) -> str:
    code = data["code"]
    rule = data["pluralRule"]
    fn_name = _func_name(code)

    lines = [HEADER + locale_source_comment(code, line_prefix="% ")]

    # Named plural function (embedded as subfunction in per-file approach)
    named_fn = get_octave_named_function(rule)

    # Function definition
    lines.append(f"function loc = {fn_name}()")

    # Plural function
    plural_expr = get_octave_plural(rule)
    lines.append(f"  loc.code = {_quote(code)};")
    lines.append(f"  loc.plural = {plural_expr};")

    # Units
    for unit_name in ("day", "week", "month", "year"):
        val = _unit_forms(data["units"][unit_name])
        lines.append(f"  loc.units.{unit_name} = {val};")

    # Simple fields
    lines.append(f"  loc.half = {_quote(data['half'])};")
    lines.append(f"  loc.delimiter = {_quote(data['delimiter'])};")
    lines.append(f"  loc.just_born = {_quote(data['justBorn'])};")

    # Stages
    for stage in ("newborn", "infant", "toddler", "child", "teenager", "adult"):
        val = _stage_label(data["stages"][stage])
        lines.append(f"  loc.stages.{stage} = {val};")

    # Short/compact
    for mode in ("short", "compact"):
        if mode in data:
            ovr = data[mode]
            if "units" in ovr:
                for unit_name in ("day", "week", "month", "year"):
                    if unit_name in ovr["units"]:
                        val = _unit_forms(ovr["units"][unit_name])
                        lines.append(f"  loc.{mode}.units.{unit_name} = {val};")
            if "half" in ovr:
                lines.append(f"  loc.{mode}.half = {_quote(ovr['half'])};")
            if "delimiter" in ovr:
                lines.append(f"  loc.{mode}.delimiter = {_quote(ovr['delimiter'])};")
            if "justBorn" in ovr:
                lines.append(f"  loc.{mode}.just_born = {_quote(ovr['justBorn'])};")

    lines.append("endfunction")

    # Append named plural function as subfunction
    if named_fn:
        lines.append("")
        lines.append(named_fn)

    lines.append("")

    return "\n".join(lines)


def emit_barrel(all_locales: list[dict]) -> str:
    """Generate the registry function that maps locale codes to locale data."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER]

    lines.append("function loc = get_age_locale(code)")
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
    return os.path.join(root, "impl", "octave", "locales", "get_age_locale.m")
