"""Python locale emitter."""

from __future__ import annotations

import keyword

from codegen.banner import locale_source_comment, make_header
from codegen.targets.python.layout import Group, Value, call, dict_of, layout, list_of
from codegen.targets.python.plural_rules import get_py_named_function, get_py_plural, is_simple_plural

HEADER = make_header("codegen/targets/python/emitter.py", line_prefix="# ")


def _quote(s: str) -> str:
    """Quote a string for Python."""
    # Use repr-style quoting but force double quotes for consistency
    escaped = s.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


_PLURAL_CATEGORIES = ("zero", "one", "two", "few", "many", "other")
_UNIT_NAMES = ("day", "week", "month", "year")
_STAGES = ("newborn", "infant", "toddler", "child", "teenager", "adult")


def _unit_forms(unit: object) -> Value:
    """Emit a UnitForms value."""
    if isinstance(unit, str):
        return _quote(unit)
    return dict_of([(_quote(cat), _quote(unit[cat])) for cat in _PLURAL_CATEGORIES if cat in unit])


def _units(units: dict, names: list[str] | tuple[str, ...]) -> Group:
    return dict_of([(_quote(name), _unit_forms(units[name])) for name in names], magic_trailing_comma=True)


def _stage_label(stage: object) -> Value:
    if isinstance(stage, str):
        return _quote(stage)
    return dict_of([('"m"', _quote(stage["m"])), ('"f"', _quote(stage["f"]))])


def _stages(stages: dict) -> Group:
    return dict_of([(_quote(stage), _stage_label(stages[stage])) for stage in _STAGES], magic_trailing_comma=True)


def _compactness_override(ovr: dict) -> Group:
    fields: list[tuple[str, Value]] = []
    if "units" in ovr:
        fields.append(("units=", _units(ovr["units"], [name for name in _UNIT_NAMES if name in ovr["units"]])))
    if "half" in ovr:
        fields.append(("half=", _quote(ovr["half"])))
    if "delimiter" in ovr:
        fields.append(("delimiter=", _quote(ovr["delimiter"])))
    if "justBorn" in ovr:
        fields.append(("just_born=", _quote(ovr["justBorn"])))
    return call("CompactnessOverride", fields, magic_trailing_comma=True)


def emit_locale(data: dict) -> str:
    code = data["code"]
    rule = data["pluralRule"]
    name = data["name"]
    lines = [HEADER + locale_source_comment(code, line_prefix="# "), f'"""{name} locale."""\n']

    # Imports
    needs_compactness = "short" in data or "compact" in data
    needs_named_plural = get_py_named_function(rule) is not None
    imports = ["AgeLocale"]
    if needs_compactness:
        imports.append("CompactnessOverride")
    if needs_named_plural:
        imports.append("PluralCategory")
    lines.append(f"from sayable_age.locale import {', '.join(imports)}")

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
    fields: list[tuple[str, Value]] = [
        ("code=", _quote(code)),
        ("plural=", get_py_plural(rule)),
        ("units=", _units(data["units"], _UNIT_NAMES)),
        ("half=", _quote(data["half"])),
        ("delimiter=", _quote(data["delimiter"])),
        ("just_born=", _quote(data["justBorn"])),
        ("stages=", _stages(data["stages"])),
    ]
    for mode in ("short", "compact"):
        if mode in data:
            fields.append((f"{mode}=", _compactness_override(data[mode])))
    lines.extend(layout(call("AgeLocale", fields, magic_trailing_comma=True), head=f"{code.upper()} = "))
    lines.append("")

    return "\n".join(lines)


def emit_barrel(all_locales: list[dict]) -> str:
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER, '"""Locale definitions for all supported languages."""\n']

    lines.append("import importlib")
    lines.append("")
    lines.append("from sayable_age.locale import AgeLocale")

    keyword_codes = []
    for loc in sorted_locs:
        code = loc["code"]
        if keyword.iskeyword(code):
            keyword_codes.append(code)
        else:
            lines.append(f"from sayable_age.locales.{code} import {code.upper()}")

    if keyword_codes:
        lines.append("")
        for code in keyword_codes:
            lines.append(
                f'{code.upper()} = importlib.import_module("sayable_age.locales.{code}").{code.upper()}'
            )

    lines.append("")

    # Lookup dict + function
    by_code = dict_of([(_quote(loc["code"]), loc["code"].upper()) for loc in sorted_locs], magic_trailing_comma=True)
    lines.extend(layout(by_code, head="_ALL: dict[str, AgeLocale] = "))
    lines.append("")
    lines.append("")
    lines.append("def get_locale(code: str) -> AgeLocale | None:")
    lines.append('    """Look up a locale by its code string."""')
    lines.append("    return _ALL.get(code)")
    lines.append("")
    lines.append("")

    exported = [_quote(loc["code"].upper()) for loc in sorted_locs] + ['"get_locale"']
    lines.extend(layout(list_of(exported, magic_trailing_comma=True), head="__all__ = "))
    lines.append("")

    return "\n".join(lines)


def output_path(code: str, root: str) -> str:
    import os
    return os.path.join(root, "impl", "python", "src", "sayable_age", "locales", f"{code}.py")


def barrel_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "python", "src", "sayable_age", "locales", "__init__.py")
