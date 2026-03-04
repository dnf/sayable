"""Python locale emitter for sayable-duration."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header
from codegen.targets.python.plural_rules import get_py_named_function, get_py_plural, is_simple_plural

HEADER = make_header("codegen/targets/python/emitter.py", line_prefix="# ")


def _quote(s: str) -> str:
    """Quote a string for Python."""
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
            pairs.append(f'"{cat}": {_quote(unit[cat])}')
    return "{" + ", ".join(pairs) + "}"


def emit_locale(data: dict) -> str:
    code = data["code"]
    rule = data["pluralRule"]
    name = data["name"]
    lines = [HEADER + locale_source_comment(code, line_prefix="# "), f'"""{name} locale."""\n']

    # Imports
    needs_named_plural = get_py_named_function(rule) is not None
    imports = ["DurationLocale"]
    has_compactness = "short" in data or "compact" in data
    if has_compactness:
        imports.append("CompactnessOverride")
    if needs_named_plural:
        imports.append("PluralCategory")
    lines.append(f"from sayable_duration.locale import {', '.join(sorted(imports))}")

    # Named plural function
    named_fn = get_py_named_function(rule)
    if named_fn:
        lines.append("")
        lines.append("")
        lines.append(named_fn)

    # Locale constant
    lines.append("")
    if named_fn:
        lines.append("")
    lines.append(f"{code.upper()} = DurationLocale(")
    lines.append(f"    code={_quote(code)},")

    # Plural
    plural_expr = get_py_plural(rule)
    lines.append(f"    plural={plural_expr},")

    # Units
    lines.append("    units={")
    for unit_name in ("second", "minute", "hour", "day", "week", "month", "year"):
        val = _unit_forms(data["units"][unit_name])
        lines.append(f"        {_quote(unit_name)}: {val},")
    lines.append("    },")

    # Simple fields
    lines.append(f"    half={_quote(data['half'])},")
    lines.append(f"    delimiter={_quote(data['delimiter'])},")
    lines.append(f"    just_now={_quote(data['justNow'])},")
    lines.append(f"    ago={_quote(data['ago'])},")
    lines.append(f"    in_future={_quote(data['inFuture'])},")

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
                        unit_lines.append(f"            {_quote(unit_name)}: {val},")
                parts.append("        units={\n" + "\n".join(unit_lines) + "\n        },")
            if "half" in ovr:
                parts.append(f"        half={_quote(ovr['half'])},")
            if "delimiter" in ovr:
                parts.append(f"        delimiter={_quote(ovr['delimiter'])},")
            if "ago" in ovr:
                parts.append(f"        ago={_quote(ovr['ago'])},")
            if "inFuture" in ovr:
                parts.append(f"        in_future={_quote(ovr['inFuture'])},")
            lines.append(f"    {mode}=CompactnessOverride(")
            lines.extend(parts)
            lines.append("    ),")

    lines.append(")")
    lines.append("")

    return "\n".join(lines)


def emit_barrel(all_locales: list[dict]) -> str:
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER, '"""Locale definitions for all supported languages."""\n']

    lines.append("from sayable_duration.locale import DurationLocale")

    for loc in sorted_locs:
        code = loc["code"]
        lines.append(f"from sayable_duration.locales.{code} import {code.upper()}")

    lines.append("")

    # Lookup dict + function
    lines.append("_ALL: dict[str, DurationLocale] = {")
    entries = [f'"{loc["code"]}": {loc["code"].upper()}' for loc in sorted_locs]
    for i in range(0, len(entries), 4):
        chunk = ", ".join(entries[i : i + 4])
        lines.append(f"    {chunk},")
    lines.append("}")
    lines.append("")
    lines.append("")
    lines.append("def get_locale(code: str) -> DurationLocale | None:")
    lines.append('    """Look up a locale by its code string."""')
    lines.append("    return _ALL.get(code)")
    lines.append("")

    lines.append("__all__ = [")
    codes = [f'"{loc["code"].upper()}"' for loc in sorted_locs]
    for i in range(0, len(codes), 8):
        chunk = ", ".join(codes[i : i + 8])
        lines.append(f"    {chunk},")
    lines.append('    "get_locale",')
    lines.append("]")
    lines.append("")

    return "\n".join(lines)


def output_path(code: str, root: str) -> str:
    import os
    return os.path.join(root, "src", "python", "src", "sayable_duration", "locales", f"{code}.py")


def barrel_path(root: str) -> str:
    import os
    return os.path.join(root, "src", "python", "src", "sayable_duration", "locales", "__init__.py")
