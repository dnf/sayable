"""V locale emitter for sayable-age.

V requires module names to match directory names and doesn't support
importing parent modules from subdirectories. Generated locale files
live in a `locales/` subdirectory with `module locales`. Type definitions
are duplicated in `locales/types.v` to avoid circular imports.

The main `sayableage.v` in the parent directory provides the public API
and formatter logic.
"""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header
from codegen.targets.v.plural_rules import get_v_plural

HEADER = make_header("codegen/targets/v/emitter.py", line_prefix="// ")


def _quote(s: str) -> str:
    """Quote a string for V."""
    escaped = s.replace("\\", "\\\\").replace("'", "\\'")
    return f"'{escaped}'"


def _unit_forms(unit: object) -> str:
    """Emit a UnitForms value."""
    if isinstance(unit, str):
        return f"simple_unit({_quote(unit)})"
    cats = ["zero", "one", "two", "few", "many", "other"]
    pairs = []
    for cat in cats:
        if cat in unit:
            pairs.append(f"PluralCategory.{cat}: {_quote(unit[cat])}")
    return "plural_unit({" + ", ".join(pairs) + "})"


def _stage_label(stage: object) -> str:
    """Emit a StageLabel value."""
    if isinstance(stage, str):
        return f"stage_neutral({_quote(stage)})"
    return f"stage_gendered({_quote(stage['m'])}, {_quote(stage['f'])})"


def emit_locale(data: dict) -> str:
    code = data["code"]
    rule = data["pluralRule"]
    name = data["name"]
    safe_code = code.replace("-", "_")

    lines = [HEADER + locale_source_comment(code, line_prefix="// ")]
    lines.append(f"// {name} locale.")
    lines.append("module locales\n")

    # Plural function
    plural_body = get_v_plural(rule)
    lines.append(f"fn plural_{safe_code}(n int) PluralCategory {{")
    for pline in plural_body.split("\n"):
        if pline.startswith("fn "):
            continue
        if pline == "}":
            continue
        lines.append(pline)
    lines.append("}\n")

    # Locale constant
    lines.append(f"pub const locale_{safe_code} = AgeLocale{{")
    lines.append(f"\tcode: {_quote(code)}")
    lines.append(f"\tplural: plural_{safe_code}")

    # Units
    lines.append(f"\tday: {_unit_forms(data['units']['day'])}")
    lines.append(f"\tweek: {_unit_forms(data['units']['week'])}")
    lines.append(f"\tmonth: {_unit_forms(data['units']['month'])}")
    lines.append(f"\tyear: {_unit_forms(data['units']['year'])}")

    # Simple fields
    lines.append(f"\thalf: {_quote(data['half'])}")
    lines.append(f"\tdelimiter: {_quote(data['delimiter'])}")
    lines.append(f"\tjust_born: {_quote(data['justBorn'])}")

    # Stages
    for stage in ("newborn", "infant", "toddler", "child", "teenager", "adult"):
        val = _stage_label(data["stages"][stage])
        lines.append(f"\t{stage}: {val}")

    # Short/compact
    for mode in ("short", "compact"):
        if mode in data:
            ovr = data[mode]
            field = "short_override" if mode == "short" else "compact_override"
            has_field = "has_short" if mode == "short" else "has_compact"
            lines.append(f"\t{has_field}: true")
            parts = []
            if "units" in ovr:
                for unit_name in ("day", "week", "month", "year"):
                    if unit_name in ovr["units"]:
                        val = _unit_forms(ovr["units"][unit_name])
                        parts.append(f"\t\t{unit_name}: {val}")
                        parts.append(f"\t\thas_{unit_name}: true")
            if "half" in ovr:
                parts.append(f"\t\thalf: {_quote(ovr['half'])}")
                parts.append(f"\t\thas_half: true")
            if "delimiter" in ovr:
                parts.append(f"\t\tdelimiter: {_quote(ovr['delimiter'])}")
                parts.append(f"\t\thas_delimiter: true")
            if "justBorn" in ovr:
                parts.append(f"\t\tjust_born: {_quote(ovr['justBorn'])}")
                parts.append(f"\t\thas_just_born: true")
            lines.append(f"\t{field}: CompactnessOverride{{")
            lines.extend(parts)
            lines.append("\t}")

    lines.append("}")
    lines.append("")

    return "\n".join(lines)


def emit_barrel(all_locales: list[dict]) -> str:
    """Generate registry.v with get_locale function."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER]
    lines.append("// Locale registry for all supported languages.")
    lines.append("module locales\n")

    # get_locale function
    lines.append("pub fn get_locale(code string) ?AgeLocale {")
    lines.append("\treturn match code {")
    for loc in sorted_locs:
        code = loc["code"]
        safe_code = code.replace("-", "_")
        lines.append(f"\t\t{_quote(code)} {{ locale_{safe_code} }}")
    lines.append("\t\telse { none }")
    lines.append("\t}")
    lines.append("}")
    lines.append("")

    return "\n".join(lines)


def output_path(code: str, root: str) -> str:
    import os
    return os.path.join(root, "impl", "v", "locales", f"locale_{code.replace('-', '_')}.v")


def barrel_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "v", "locales", "registry.v")
