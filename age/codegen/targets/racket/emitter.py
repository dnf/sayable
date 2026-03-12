"""Racket locale emitter."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header
from codegen.targets.racket.plural_rules import get_rkt_plural

HEADER = make_header("codegen/targets/racket/emitter.py", line_prefix="; ")


def _quote(s: str) -> str:
    """Quote a string for Racket."""
    escaped = s.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def _module_name(code: str) -> str:
    """Convert locale code to Racket module name."""
    return code.replace("-", "_")


def _unit_forms(unit: object) -> str:
    """Emit a unit forms value as a Racket hash."""
    if isinstance(unit, str):
        return f'(hash "type" "simple" "form" {_quote(unit)})'
    cats = ["zero", "one", "two", "few", "many", "other"]
    pairs = []
    for cat in cats:
        if cat in unit:
            pairs.append(f'"{cat}" {_quote(unit[cat])}')
    return '(hash "type" "pluralized" "forms" (hash ' + " ".join(pairs) + "))"


def _stage_label(stage: object) -> str:
    if isinstance(stage, str):
        return f"(stage-label {_quote(stage)} #f #f)"
    return f'(stage-label #f {_quote(stage["m"])} {_quote(stage["f"])})'


def _compactness_override(ovr: dict) -> str:
    parts = []
    # units
    for unit_name in ("day", "week", "month", "year"):
        if "units" in ovr and unit_name in ovr["units"]:
            val = _unit_forms(ovr["units"][unit_name])
            parts.append(val)
        else:
            parts.append("#f")
    # half
    if "half" in ovr:
        parts.append(_quote(ovr["half"]))
    else:
        parts.append("#f")
    # delimiter
    if "delimiter" in ovr:
        parts.append(_quote(ovr["delimiter"]))
    else:
        parts.append("#f")
    # justBorn
    if "justBorn" in ovr:
        parts.append(_quote(ovr["justBorn"]))
    else:
        parts.append("#f")
    return "(compactness-override " + " ".join(parts) + ")"


def emit_locale(data: dict) -> str:
    code = data["code"]
    rule = data["pluralRule"]
    name = data["name"]
    mod = _module_name(code)

    # #lang must be first line in Racket files
    lines = ["#lang racket\n"]
    lines.append(HEADER + locale_source_comment(code, line_prefix="; "))
    lines.append(f"; {name} locale.\n")
    lines.append("(require \"../locale.rkt\")\n")
    lines.append(f"(provide {mod})\n")

    # Build the locale definition
    lines.append(f"(define {mod}")
    lines.append("  (age-locale")
    lines.append(f"   {_quote(code)}")

    # Plural
    plural_expr = get_rkt_plural(rule)
    lines.append(f"   {plural_expr}")

    # Units
    lines.append(f"   (hash \"day\" {_unit_forms(data['units']['day'])}")
    lines.append(f"         \"week\" {_unit_forms(data['units']['week'])}")
    lines.append(f"         \"month\" {_unit_forms(data['units']['month'])}")
    lines.append(f"         \"year\" {_unit_forms(data['units']['year'])})")

    # Simple fields
    lines.append(f"   {_quote(data['half'])}")
    lines.append(f"   {_quote(data['delimiter'])}")
    lines.append(f"   {_quote(data['justBorn'])}")

    # Stages
    stages = data["stages"]
    lines.append(f"   (hash \"newborn\" {_stage_label(stages['newborn'])}")
    lines.append(f"         \"infant\" {_stage_label(stages['infant'])}")
    lines.append(f"         \"toddler\" {_stage_label(stages['toddler'])}")
    lines.append(f"         \"child\" {_stage_label(stages['child'])}")
    lines.append(f"         \"teenager\" {_stage_label(stages['teenager'])}")
    lines.append(f"         \"adult\" {_stage_label(stages['adult'])})")

    # Short/compact
    for mode in ("short", "compact"):
        if mode in data:
            lines.append(f"   {_compactness_override(data[mode])}")
        else:
            lines.append("   #f")

    lines.append("  ))")
    lines.append("")

    return "\n".join(lines)


def emit_barrel(all_locales: list[dict]) -> str:
    """Generate the registry.rkt barrel module."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    # #lang must be first line
    lines = ["#lang racket\n"]
    lines.append(HEADER)

    # Require all locale modules
    lines.append("(require")
    for loc in sorted_locs:
        mod = _module_name(loc["code"])
        lines.append(f'  "{mod}.rkt"')
    lines.append(")\n")

    lines.append("(provide get-locale)\n")

    # Build lookup hash
    lines.append("(define all-locales")
    lines.append("  (hash")
    for loc in sorted_locs:
        code = loc["code"]
        mod = _module_name(code)
        lines.append(f'   "{code}" {mod}')
    lines.append("  ))\n")

    lines.append("(define (get-locale code)")
    lines.append("  (hash-ref all-locales code #f))")
    lines.append("")

    return "\n".join(lines)


def output_path(code: str, root: str) -> str:
    import os
    mod = _module_name(code)
    return os.path.join(root, "impl", "racket", "locales", f"{mod}.rkt")


def barrel_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "racket", "locales", "registry.rkt")
