"""Wren locale emitter."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header
from codegen.targets.wren.plural_rules import get_wren_named_class, get_wren_plural, is_simple_plural

HEADER = make_header("codegen/targets/wren/emitter.py", line_prefix="// ")


def _quote(s: str) -> str:
    """Quote a string for Wren."""
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
            pairs.append(f'{_quote(cat)}: {_quote(unit[cat])}')
    return "{" + ", ".join(pairs) + "}"


def _stage_label(stage: object) -> str:
    if isinstance(stage, str):
        return _quote(stage)
    return '{"m": ' + _quote(stage["m"]) + ', "f": ' + _quote(stage["f"]) + "}"


def emit_locale(data: dict) -> str:
    code = data["code"]
    rule = data["pluralRule"]

    lines = [HEADER + locale_source_comment(code, line_prefix="// ")]

    # Named plural class
    named_cls = get_wren_named_class(rule)
    if named_cls:
        lines.append(named_cls)
        lines.append("")

    # Locale class
    class_name = code.upper().replace("-", "_") + "Locale"
    lines.append(f"class {class_name} {{")
    lines.append(f"  static code {{ {_quote(code)} }}")

    # Plural
    plural_expr = get_wren_plural(rule)
    lines.append(f"  static plural {{ {plural_expr} }}")

    # Units — map literal needs return inside body block
    lines.append("  static units {")
    lines.append("    return {")
    for unit_name in ("day", "week", "month", "year"):
        val = _unit_forms(data["units"][unit_name])
        lines.append(f'      {_quote(unit_name)}: {val},')
    lines.append("    }")
    lines.append("  }")

    # Simple fields
    lines.append(f"  static half {{ {_quote(data['half'])} }}")
    lines.append(f"  static delimiter {{ {_quote(data['delimiter'])} }}")
    lines.append(f"  static justBorn {{ {_quote(data['justBorn'])} }}")

    # Stages — map literal needs return inside body block
    lines.append("  static stages {")
    lines.append("    return {")
    for stage in ("newborn", "infant", "toddler", "child", "teenager", "adult"):
        val = _stage_label(data["stages"][stage])
        lines.append(f'      {_quote(stage)}: {val},')
    lines.append("    }")
    lines.append("  }")

    # Short/compact
    for mode in ("short", "compact"):
        if mode in data:
            ovr = data[mode]
            lines.append(f"  static {mode} {{")
            lines.append("    return {")
            if "units" in ovr:
                lines.append('      "units": {')
                for unit_name in ("day", "week", "month", "year"):
                    if unit_name in ovr["units"]:
                        val = _unit_forms(ovr["units"][unit_name])
                        lines.append(f'        {_quote(unit_name)}: {val},')
                lines.append("      },")
            if "half" in ovr:
                lines.append(f'      "half": {_quote(ovr["half"])},')
            if "delimiter" in ovr:
                lines.append(f'      "delimiter": {_quote(ovr["delimiter"])},')
            if "justBorn" in ovr:
                lines.append(f'      "justBorn": {_quote(ovr["justBorn"])},')
            lines.append("    }")
            lines.append("  }")

    lines.append("}")
    lines.append("")

    return "\n".join(lines)


def emit_barrel(all_locales: list[dict]) -> str:
    """Generate the registry module that maps locale codes to locale classes."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER]

    # Import all locale modules (relative to locales/ directory where registry lives)
    for loc in sorted_locs:
        code = loc["code"]
        class_name = code.upper().replace("-", "_") + "Locale"
        lines.append(f'import "./{code}" for {class_name}')

    lines.append("")
    lines.append("class LocaleRegistry {")
    lines.append("  static getLocale(code) {")

    for loc in sorted_locs:
        code = loc["code"]
        class_name = code.upper().replace("-", "_") + "Locale"
        lines.append(f'    if (code == {_quote(code)}) return {class_name}')

    lines.append("    return null")
    lines.append("  }")
    lines.append("}")
    lines.append("")

    return "\n".join(lines)


def output_path(code: str, root: str) -> str:
    import os
    return os.path.join(root, "impl", "wren", "locales", f"{code}.wren")


def barrel_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "wren", "locales", "registry.wren")
