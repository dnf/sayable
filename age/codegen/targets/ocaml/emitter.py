"""OCaml locale emitter."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header
from codegen.targets.ocaml.plural_rules import get_ml_plural

HEADER = make_header("codegen/targets/ocaml/emitter.py", line_prefix="(* ", line_suffix=" *)")

_CAT_MAP = {
    "zero": "Zero", "one": "One", "two": "Two",
    "few": "Few", "many": "Many", "other": "Other",
}


def _module_name(code: str) -> str:
    """Convert locale code to OCaml module name (capitalize first letter)."""
    return code[0].upper() + code[1:]


def _quote(s: str) -> str:
    escaped = s.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def _unit_forms(unit: object, indent: int = 4) -> str:
    pad = " " * indent
    if isinstance(unit, str):
        return f"Simple {_quote(unit)}"
    cats = ["zero", "one", "two", "few", "many", "other"]
    pairs = []
    for cat in cats:
        if cat in unit:
            pairs.append(f"({_CAT_MAP[cat]}, {_quote(unit[cat])})")
    return "Pluralized\n" + pad + "[ " + ("\n" + pad + "; ").join(pairs) + "\n" + pad + "]"


def _stage_label(stage: object) -> str:
    if isinstance(stage, str):
        return f"Neutral {_quote(stage)}"
    return f"Gendered ({_quote(stage['m'])}, {_quote(stage['f'])})"


def _compactness_override(ovr: dict, indent: int = 4) -> str:
    pad = " " * indent
    lines = [f"{pad}{{ ovr_day = {_ovr_unit(ovr, 'day', indent + 2)}"]
    lines.append(f"{pad}; ovr_week = {_ovr_unit(ovr, 'week', indent + 2)}")
    lines.append(f"{pad}; ovr_month = {_ovr_unit(ovr, 'month', indent + 2)}")
    lines.append(f"{pad}; ovr_year = {_ovr_unit(ovr, 'year', indent + 2)}")
    if "half" in ovr:
        lines.append(f"{pad}; ovr_half = Some {_quote(ovr['half'])}")
    else:
        lines.append(f"{pad}; ovr_half = None")
    if "delimiter" in ovr:
        lines.append(f"{pad}; ovr_delimiter = Some {_quote(ovr['delimiter'])}")
    else:
        lines.append(f"{pad}; ovr_delimiter = None")
    if "justBorn" in ovr:
        lines.append(f"{pad}; ovr_just_born = Some {_quote(ovr['justBorn'])}")
    else:
        lines.append(f"{pad}; ovr_just_born = None")
    lines.append(f"{pad}}}")
    return "\n".join(lines)


def _ovr_unit(ovr: dict, unit_name: str, indent: int) -> str:
    if "units" in ovr and unit_name in ovr["units"]:
        val = ovr["units"][unit_name]
        return f"Some ({_unit_forms(val, indent + 2)})"
    return "None"


def emit_locale(data: dict) -> str:
    code = data["code"]
    rule = data["pluralRule"]

    lines = [HEADER + locale_source_comment(code, line_prefix="(* ", line_suffix=" *)")]
    lines.append("open Types")
    lines.append("")
    lines.append("let locale : locale =")

    # Plural
    plural = get_ml_plural(rule)
    lines.append(f"  {{ code = {_quote(code)}")
    lines.append(f"  ; plural = ({plural})")

    # Units
    for unit_name in ("day", "week", "month", "year"):
        val = _unit_forms(data["units"][unit_name], indent=6)
        lines.append(f"  ; {unit_name} = {val}")

    # Simple fields
    lines.append(f"  ; half = {_quote(data['half'])}")
    lines.append(f"  ; delimiter = {_quote(data['delimiter'])}")
    lines.append(f"  ; just_born = {_quote(data['justBorn'])}")

    # Stages
    lines.append("  ; stages =")
    stages = data["stages"]
    stage_names = ["newborn", "infant", "toddler", "child", "teenager", "adult"]
    for i, stage in enumerate(stage_names):
        prefix = "    { " if i == 0 else "    ; "
        val = _stage_label(stages[stage])
        lines.append(f"{prefix}{stage} = {val}")
    lines.append("    }")

    # Short/compact
    for mode in ("short", "compact"):
        if mode in data:
            lines.append(f"  ; {mode} = Some")
            lines.append(_compactness_override(data[mode], indent=6))
        else:
            lines.append(f"  ; {mode} = None")

    lines.append("  }")
    lines.append("")

    return "\n".join(lines)


def emit_barrel(all_locales: list[dict]) -> str:
    """Generate the locales.ml barrel module."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER]
    lines.append("let get_locale (code : string) : Types.locale option =")
    lines.append("  match code with")

    for loc in sorted_locs:
        code = loc["code"]
        mod = _module_name(code)
        lines.append(f'  | "{code}" -> Some {mod}.locale')

    lines.append("  | _ -> None")
    lines.append("")

    return "\n".join(lines)


def output_path(code: str, root: str) -> str:
    import os
    return os.path.join(root, "impl", "ocaml", "lib", "locales", f"{code}.ml")


def barrel_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "ocaml", "lib", "locales", "locales.ml")
