"""Mojo locale emitter for sayable-age."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header
from codegen.targets.mojo.plural_rules import get_mojo_named_function, get_mojo_plural, is_simple_plural

HEADER = make_header("codegen/targets/mojo/emitter.py", line_prefix="# ")

_MOJO_RESERVED = {
    "alias", "and", "as", "async", "await", "break", "class", "continue",
    "def", "del", "elif", "else", "except", "finally", "fn", "for", "from",
    "global", "if", "import", "in", "is", "lambda", "let", "mut", "nonlocal",
    "not", "or", "pass", "raise", "return", "self", "struct", "trait", "try",
    "var", "while", "with", "yield",
}


def _safe_id(code: str) -> str:
    """Escape locale codes that are Mojo reserved keywords."""
    safe = code.replace("-", "_")
    if safe in _MOJO_RESERVED:
        return f"{safe}_locale"
    return safe


def _const_name(code: str) -> str:
    """Generate constant name for a locale."""
    return _safe_id(code).upper()


def _quote(s: str) -> str:
    escaped = s.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def _unit_forms(unit: object) -> str:
    if isinstance(unit, str):
        return f"simple_unit({_quote(unit)})"
    cats = ["zero", "one", "two", "few", "many", "other"]
    pairs = []
    for cat in cats:
        if cat in unit:
            pairs.append(f'Tuple[String, String]({_quote(cat)}, {_quote(unit[cat])})')
    return "plural_unit(List[Tuple[String, String]](" + ", ".join(pairs) + "))"


def _stage_label(stage: object) -> str:
    if isinstance(stage, str):
        return f"stage_neutral({_quote(stage)})"
    return f"stage_gendered({_quote(stage['m'])}, {_quote(stage['f'])})"


def emit_locale(data: dict) -> str:
    code = data["code"]
    rule = data["pluralRule"]
    name = data["name"]

    lines = [HEADER + locale_source_comment(code, line_prefix="# ")]
    lines.append(f'"""{name} locale."""')
    lines.append("")
    lines.append("from ..locale import (")
    lines.append("    AgeLocale,")
    lines.append("    CompactnessOverride,")
    lines.append("    StageLabel,")
    lines.append("    UnitForms,")
    lines.append("    simple_unit,")
    lines.append("    plural_unit,")
    lines.append("    stage_neutral,")
    lines.append("    stage_gendered,")
    lines.append(")")
    lines.append("")

    # Named plural function
    named_fn = get_mojo_named_function(rule)
    if named_fn:
        lines.append("")
        lines.append(named_fn)
        lines.append("")

    # Build function that returns the locale
    lines.append("")
    lines.append(f"fn build_{_safe_id(code)}() -> AgeLocale:")
    lines.append(f'    """Build the {name} locale."""')

    # Plural
    plural_expr = get_mojo_plural(rule)
    if is_simple_plural(rule):
        # For simple rules, emit inline
        if rule == "other_only":
            lines.append("    fn plural(n: Int) -> String:")
            lines.append('        return "other"')
        elif rule == "one_other":
            lines.append("    fn plural(n: Int) -> String:")
            lines.append("        if n == 1:")
            lines.append('            return "one"')
            lines.append('        return "other"')
        elif rule == "one_other_zero_one":
            lines.append("    fn plural(n: Int) -> String:")
            lines.append("        if n == 0 or n == 1:")
            lines.append('            return "one"')
            lines.append('        return "other"')
    else:
        # Use the named function defined above
        pass

    lines.append("")
    lines.append("    var units = Dict[String, UnitForms]()")
    for unit_name in ("day", "week", "month", "year"):
        val = _unit_forms(data["units"][unit_name])
        lines.append(f"    units[{_quote(unit_name)}] = {val}")

    lines.append("")
    lines.append("    var stages = Dict[String, StageLabel]()")
    for stage in ("newborn", "infant", "toddler", "child", "teenager", "adult"):
        val = _stage_label(data["stages"][stage])
        lines.append(f"    stages[{_quote(stage)}] = {val}")

    # Short/compact overrides
    for mode in ("short", "compact"):
        if mode in data:
            ovr = data[mode]
            lines.append("")
            lines.append(f"    var {mode}_ovr = CompactnessOverride()")
            if "units" in ovr:
                lines.append(f"    var {mode}_units = Dict[String, UnitForms]()")
                for unit_name in ("day", "week", "month", "year"):
                    if unit_name in ovr["units"]:
                        val = _unit_forms(ovr["units"][unit_name])
                        lines.append(f"    {mode}_units[{_quote(unit_name)}] = {val}")
                lines.append(f"    {mode}_ovr.units = {mode}_units^")
            if "half" in ovr:
                lines.append(f"    {mode}_ovr.half = {_quote(ovr['half'])}")
                lines.append(f"    {mode}_ovr.has_half = True")
            if "delimiter" in ovr:
                lines.append(f"    {mode}_ovr.delimiter = {_quote(ovr['delimiter'])}")
                lines.append(f"    {mode}_ovr.has_delimiter = True")
            if "justBorn" in ovr:
                lines.append(f"    {mode}_ovr.just_born = {_quote(ovr['justBorn'])}")
                lines.append(f"    {mode}_ovr.has_just_born = True")

    lines.append("")

    # Determine plural function reference
    if is_simple_plural(rule):
        plural_ref = "plural"
    else:
        plural_ref = "_plural"

    lines.append("    return AgeLocale(")
    lines.append(f"        code={_quote(code)},")
    lines.append(f"        plural_fn={plural_ref},")
    lines.append("        units=units^,")
    lines.append(f"        half={_quote(data['half'])},")
    lines.append(f"        delimiter={_quote(data['delimiter'])},")
    lines.append(f"        just_born={_quote(data['justBorn'])},")
    lines.append("        stages=stages^,")

    for mode in ("short", "compact"):
        if mode in data:
            lines.append(f"        {mode}_override={mode}_ovr^,")
            lines.append(f"        has_{mode}=True,")

    lines.append("    )")
    lines.append("")

    return "\n".join(lines)


def emit_registry(all_locales: list[dict]) -> str:
    """Generate the registry.mojo file."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER]
    lines.append('"""Locale registry for all supported languages."""')
    lines.append("")
    lines.append("from ..locale import AgeLocale")

    # Import each locale builder
    for loc in sorted_locs:
        code = loc["code"]
        lines.append(f"from .{_safe_id(code)} import build_{_safe_id(code)}")
    lines.append("")
    lines.append("")

    lines.append("fn get_locale(code: String) -> AgeLocale:")
    lines.append('    """Look up a locale by its code string.')
    lines.append("")
    lines.append("    Returns the locale if found, or the English locale as fallback.")
    lines.append('    """')
    for loc in sorted_locs:
        code = loc["code"]
        lines.append(f'    if code == {_quote(code)}:')
        lines.append(f"        return build_{_safe_id(code)}()")
    lines.append(f"    return build_en()")
    lines.append("")
    lines.append("")
    lines.append("fn has_locale(code: String) -> Bool:")
    lines.append('    """Check if a locale code is known."""')
    for loc in sorted_locs:
        code = loc["code"]
        lines.append(f'    if code == {_quote(code)}:')
        lines.append("        return True")
    lines.append("    return False")
    lines.append("")

    return "\n".join(lines)


def output_path(code: str, root: str) -> str:
    import os
    return os.path.join(root, "impl", "mojo", "src", "sayable_age", "locales", f"{_safe_id(code)}.mojo")


def registry_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "mojo", "src", "sayable_age", "locales", "registry.mojo")
