"""Janet locale emitter."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header
from codegen.targets.janet.plural_rules import get_janet_named_function, get_janet_plural, is_simple_plural

HEADER = make_header("codegen/targets/janet/emitter.py", line_prefix="# ")


def _quote(s: str) -> str:
    """Quote a string for Janet."""
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
            pairs.append(f":{cat} {_quote(unit[cat])}")
    return "{" + " ".join(pairs) + "}"


def _stage_label(stage: object) -> str:
    if isinstance(stage, str):
        return _quote(stage)
    return '{:m ' + _quote(stage["m"]) + ' :f ' + _quote(stage["f"]) + '}'


def emit_locale(data: dict) -> str:
    code = data["code"]
    rule = data["pluralRule"]

    lines = [HEADER + locale_source_comment(code, line_prefix="# ")]

    # Named plural function
    named_fn = get_janet_named_function(rule)
    if named_fn:
        lines.append(named_fn)
        lines.append("")

    # Plural expression
    plural_expr = get_janet_plural(rule)

    # Build locale struct
    lines.append("(def locale")
    lines.append(f"  {{:code {_quote(code)}")
    lines.append(f"   :plural {plural_expr}")
    lines.append("   :units {:day " + _unit_forms(data["units"]["day"]))
    lines.append("          :week " + _unit_forms(data["units"]["week"]))
    lines.append("          :month " + _unit_forms(data["units"]["month"]))
    lines.append("          :year " + _unit_forms(data["units"]["year"]) + "}")
    lines.append(f"   :half {_quote(data['half'])}")
    lines.append(f"   :delimiter {_quote(data['delimiter'])}")
    lines.append(f"   :just-born {_quote(data['justBorn'])}")

    # Stages
    lines.append("   :stages {:newborn " + _stage_label(data["stages"]["newborn"]))
    for stage in ("infant", "toddler", "child", "teenager", "adult"):
        val = _stage_label(data["stages"][stage])
        lines.append(f"            :{stage} {val}")
    lines.append("}")

    # Short/compact
    for mode in ("short", "compact"):
        if mode in data:
            ovr = data[mode]
            parts = []
            if "units" in ovr:
                unit_entries = []
                for unit_name in ("day", "week", "month", "year"):
                    if unit_name in ovr["units"]:
                        val = _unit_forms(ovr["units"][unit_name])
                        unit_entries.append(f":{unit_name} {val}")
                parts.append(":units {" + " ".join(unit_entries) + "}")
            if "half" in ovr:
                parts.append(f":half {_quote(ovr['half'])}")
            if "delimiter" in ovr:
                parts.append(f":delimiter {_quote(ovr['delimiter'])}")
            if "justBorn" in ovr:
                parts.append(f":just-born {_quote(ovr['justBorn'])}")
            janet_key = mode
            lines.append(f"   :{janet_key} {{{' '.join(parts)}}}")

    lines.append("})")
    lines.append("")

    return "\n".join(lines)


def emit_registry(all_locales: list[dict]) -> str:
    """Generate the registry module that maps locale codes to locale tables."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER]

    lines.append("(def- locale-cache @{})")
    lines.append("")
    lines.append("(defn get-locale [code]")
    lines.append("  (if-let [cached (in locale-cache code)]")
    lines.append("    cached")
    lines.append("    (if-let [env")
    lines.append("             (case code")

    for loc in sorted_locs:
        code = loc["code"]
        lines.append(f'               "{code}" (require "./locales/{code}")')

    lines.append("               nil)]")
    lines.append("      (let [loc ((in env 'locale) :value)]")
    lines.append("        (put locale-cache code loc)")
    lines.append("        loc)")
    lines.append("      nil)))")
    lines.append("")

    return "\n".join(lines)


def output_path(code: str, root: str) -> str:
    import os
    return os.path.join(root, "impl", "janet", "locales", f"{code}.janet")


def registry_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "janet", "locales", "registry.janet")
