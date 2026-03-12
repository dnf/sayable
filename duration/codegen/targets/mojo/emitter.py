"""Mojo locale emitter for sayable-duration."""

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


def _quote(s: str) -> str:
    escaped = s.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def _unit_forms(unit: object) -> str:
    if isinstance(unit, str):
        return f"simple_unit({_quote(unit)})"
    cats = ["zero", "one", "two", "few", "many", "other"]
    args = []
    for cat in cats:
        if cat in unit:
            args.append(f'{cat}={_quote(unit[cat])}')
    return "plural_unit(" + ", ".join(args) + ")"


def emit_locale(data: dict) -> str:
    code = data["code"]
    rule = data["pluralRule"]
    name = data["name"]

    lines = [HEADER + locale_source_comment(code, line_prefix="# ")]
    lines.append(f'"""{name} locale."""')
    lines.append("")
    lines.append("from ..locale import (")
    lines.append("    DurationLocale,")
    lines.append("    CompactnessOverride,")
    lines.append("    UnitForms,")
    lines.append("    simple_unit,")
    lines.append("    plural_unit,")
    lines.append(")")
    lines.append("")

    # Named plural function
    named_fn = get_mojo_named_function(rule)
    if named_fn:
        lines.append("")
        lines.append(named_fn)
        lines.append("")

    # Build function
    lines.append("")
    lines.append(f"fn build_{_safe_id(code)}() -> DurationLocale:")
    lines.append(f'    """Build the {name} locale."""')

    # Plural
    if is_simple_plural(rule):
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

    # Units
    lines.append("")
    for unit_name in ("second", "minute", "hour", "day", "week", "month", "year"):
        val = _unit_forms(data["units"][unit_name])
        lines.append(f"    var {unit_name} = {val}")

    # Short/compact overrides
    for mode in ("short", "compact"):
        if mode in data:
            ovr = data[mode]
            lines.append("")
            lines.append(f"    var {mode}_ovr = CompactnessOverride()")
            if "units" in ovr:
                for unit_name in ("second", "minute", "hour", "day", "week", "month", "year"):
                    if unit_name in ovr["units"]:
                        val = _unit_forms(ovr["units"][unit_name])
                        lines.append(f"    {mode}_ovr.{unit_name} = {val}")
                        lines.append(f"    {mode}_ovr.has_{unit_name} = True")
            if "half" in ovr:
                lines.append(f"    {mode}_ovr.half = {_quote(ovr['half'])}")
                lines.append(f"    {mode}_ovr.has_half = True")
            if "delimiter" in ovr:
                lines.append(f"    {mode}_ovr.delimiter = {_quote(ovr['delimiter'])}")
                lines.append(f"    {mode}_ovr.has_delimiter = True")
            if "ago" in ovr:
                lines.append(f"    {mode}_ovr.ago = {_quote(ovr['ago'])}")
                lines.append(f"    {mode}_ovr.has_ago = True")
            if "inFuture" in ovr:
                lines.append(f"    {mode}_ovr.in_future = {_quote(ovr['inFuture'])}")
                lines.append(f"    {mode}_ovr.has_in_future = True")

    lines.append("")

    # Determine plural function reference
    if is_simple_plural(rule):
        plural_ref = "plural"
    else:
        plural_ref = "_plural"

    lines.append("    return DurationLocale(")
    lines.append(f"        code={_quote(code)},")
    lines.append(f"        plural_fn={plural_ref},")
    lines.append("        second=second,")
    lines.append("        minute=minute,")
    lines.append("        hour=hour,")
    lines.append("        day=day,")
    lines.append("        week=week,")
    lines.append("        month=month,")
    lines.append("        year=year,")
    lines.append(f"        half={_quote(data['half'])},")
    lines.append(f"        delimiter={_quote(data['delimiter'])},")
    lines.append(f"        just_now={_quote(data['justNow'])},")
    lines.append(f"        ago={_quote(data['ago'])},")
    lines.append(f"        in_future={_quote(data['inFuture'])},")

    for mode in ("short", "compact"):
        if mode in data:
            lines.append(f"        {mode}_override={mode}_ovr,")
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
    lines.append("from ..locale import DurationLocale")

    for loc in sorted_locs:
        code = loc["code"]
        lines.append(f"from .{_safe_id(code)} import build_{_safe_id(code)}")
    lines.append("")
    lines.append("")

    lines.append("fn get_locale(code: String) -> DurationLocale:")
    lines.append('    """Look up a locale by its code string.')
    lines.append("")
    lines.append("    Returns the locale if found, or the English locale as fallback.")
    lines.append('    """')
    for loc in sorted_locs:
        code = loc["code"]
        lines.append(f'    if code == {_quote(code)}:')
        lines.append(f"        return build_{_safe_id(code)}()")
    lines.append("    return build_en()")
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
    return os.path.join(root, "impl", "mojo", "src", "sayable_duration", "locales", f"{_safe_id(code)}.mojo")


def registry_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "mojo", "src", "sayable_duration", "locales", "registry.mojo")
