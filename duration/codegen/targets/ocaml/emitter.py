"""OCaml locale emitter for sayable-duration."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header
from codegen.targets.ocaml.plural_rules import get_ml_plural

HEADER = make_header("codegen/targets/ocaml/emitter.py", line_prefix="(* ", line_suffix=" *)")

_CAT_MAP = {
    "zero": "Zero", "one": "One", "two": "Two",
    "few": "Few", "many": "Many", "other": "Other",
}

_UNIT_NAMES = ("second", "minute", "hour", "day", "week", "month", "year")


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


def _compactness_override(ovr: dict, indent: int = 4) -> str:
    pad = " " * indent
    lines = []

    # Units
    for unit_name in _UNIT_NAMES:
        field = f"ovr_{unit_name}"
        if "units" in ovr and unit_name in ovr["units"]:
            val = ovr["units"][unit_name]
            lines.append(f"{pad}{'{ ' if unit_name == 'second' else '; '}{field} = Some ({_unit_forms(val, indent + 2)})")
        else:
            lines.append(f"{pad}{'{ ' if unit_name == 'second' else '; '}{field} = None")

    # Simple override fields
    for key, field in [("half", "ovr_half"), ("delimiter", "ovr_delimiter"),
                        ("ago", "ovr_ago"), ("inFuture", "ovr_in_future")]:
        if key in ovr:
            lines.append(f"{pad}; {field} = Some {_quote(ovr[key])}")
        else:
            lines.append(f"{pad}; {field} = None")

    lines.append(f"{pad}}}")
    return "\n".join(lines)


def emit_locale(data: dict) -> str:
    code = data["code"]
    rule = data["pluralRule"]

    lines = [HEADER + locale_source_comment(code, line_prefix="(* ", line_suffix=" *)")]
    lines.append("open Types")
    lines.append("")
    lines.append("let locale : duration_locale =")

    # Plural
    plural = get_ml_plural(rule)
    lines.append(f"  {{ code = {_quote(code)}")
    lines.append(f"  ; plural = ({plural})")

    # Units
    for unit_name in _UNIT_NAMES:
        val = _unit_forms(data["units"][unit_name], indent=6)
        lines.append(f"  ; {unit_name} = {val}")

    # Simple fields
    lines.append(f"  ; half = {_quote(data['half'])}")
    lines.append(f"  ; delimiter = {_quote(data['delimiter'])}")
    lines.append(f"  ; just_now = {_quote(data['justNow'])}")
    lines.append(f"  ; ago = {_quote(data['ago'])}")
    lines.append(f"  ; in_future = {_quote(data['inFuture'])}")

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
    lines.append("let get_locale (code : string) : Types.duration_locale option =")
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
