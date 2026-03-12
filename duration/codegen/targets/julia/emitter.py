"""Julia locale emitter for sayable-duration."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header
from codegen.targets.julia.plural_rules import get_jl_plural

HEADER = make_header("codegen/targets/julia/emitter.py", line_prefix="# ")


def _quote(s: str) -> str:
    """Quote a string for Julia."""
    escaped = s.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def _unit_forms(unit: object) -> str:
    """Emit a unit forms value."""
    if isinstance(unit, str):
        return _quote(unit)
    cats = ["zero", "one", "two", "few", "many", "other"]
    pairs = []
    for cat in cats:
        if cat in unit:
            pairs.append(f'{_quote(cat)} => {_quote(unit[cat])}')
    return "Dict(" + ", ".join(pairs) + ")"


def emit_locale(data: dict) -> str:
    """Generate a Julia locale file from canonical JSON."""
    code = data["code"]
    rule = data["pluralRule"]
    name = data["name"]
    lines = [HEADER + locale_source_comment(code, line_prefix="# "), f"# {name} locale.\n"]

    # Locale constant
    lines.append(f"const {code.upper()} = DurationLocale(")
    lines.append(f"    code = {_quote(code)},")

    # Plural (always inline anonymous function)
    plural_expr = get_jl_plural(rule)
    lines.append(f"    plural = {plural_expr},")

    # Units
    lines.append("    units = Dict(")
    for unit_name in ("second", "minute", "hour", "day", "week", "month", "year"):
        val = _unit_forms(data["units"][unit_name])
        lines.append(f"        {_quote(unit_name)} => {val},")
    lines.append("    ),")

    # Simple fields
    lines.append(f"    half = {_quote(data['half'])},")
    lines.append(f"    delimiter = {_quote(data['delimiter'])},")
    lines.append(f"    just_now = {_quote(data['justNow'])},")
    lines.append(f"    ago = {_quote(data['ago'])},")
    lines.append(f"    in_future = {_quote(data['inFuture'])},")

    # Short/compact
    for mode in ("short", "compact"):
        if mode in data:
            ovr = data[mode]
            parts = []
            if "units" in ovr:
                unit_lines = []
                for unit_name in ("second", "minute", "hour", "day", "week", "month", "year"):
                    if unit_name in ovr["units"]:
                        val = _unit_forms(ovr["units"][unit_name])
                        unit_lines.append(f"            {_quote(unit_name)} => {val},")
                parts.append("        units = Dict(\n" + "\n".join(unit_lines) + "\n        ),")
            if "half" in ovr:
                parts.append(f"        half = {_quote(ovr['half'])},")
            if "delimiter" in ovr:
                parts.append(f"        delimiter = {_quote(ovr['delimiter'])},")
            if "ago" in ovr:
                parts.append(f"        ago = {_quote(ovr['ago'])},")
            if "inFuture" in ovr:
                parts.append(f"        in_future = {_quote(ovr['inFuture'])},")
            field = "short_override" if mode == "short" else "compact_override"
            lines.append(f"    {field} = DurationCompactnessOverride(")
            lines.extend(parts)
            lines.append("    ),")

    lines.append(")")
    lines.append("")

    return "\n".join(lines)


def emit_barrel(all_locales: list[dict]) -> str:
    """Generate the locales/registry.jl barrel file."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER, "# Locale registry for all supported languages.\n"]

    # Include all locale files
    for loc in sorted_locs:
        code = loc["code"]
        lines.append(f'include("{code}.jl")')

    lines.append("")

    # Lookup dict + function
    lines.append("const _ALL = Dict{String, DurationLocale}(")
    for loc in sorted_locs:
        code = loc["code"]
        lines.append(f'    "{code}" => {code.upper()},')
    lines.append(")")
    lines.append("")
    lines.append("function get_locale(code::String)::Union{DurationLocale, Nothing}")
    lines.append("    get(_ALL, code, nothing)")
    lines.append("end")
    lines.append("")

    return "\n".join(lines)


def output_path(code: str, root: str) -> str:
    import os
    return os.path.join(root, "impl", "julia", "src", "locales", f"{code}.jl")


def barrel_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "julia", "src", "locales", "registry.jl")
