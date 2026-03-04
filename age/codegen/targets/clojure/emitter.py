"""Clojure locale emitter."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header
from codegen.targets.clojure.plural_rules import get_clj_plural

HEADER = make_header("codegen/targets/clojure/emitter.py", line_prefix=";; ")

_CAT_MAP = {
    "zero": ":zero", "one": ":one", "two": ":two",
    "few": ":few", "many": ":many", "other": ":other",
}


def _ns_name(code: str) -> str:
    """Convert locale code to Clojure namespace suffix (lowercase, underscores for hyphens)."""
    return code.replace("-", "_")


def _quote(s: str) -> str:
    escaped = s.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def _unit_forms(unit: object) -> str:
    if isinstance(unit, str):
        return f"{{:type :simple :form {_quote(unit)}}}"
    cats = ["zero", "one", "two", "few", "many", "other"]
    pairs = []
    for cat in cats:
        if cat in unit:
            pairs.append(f"{_CAT_MAP[cat]} {_quote(unit[cat])}")
    return "{:type :pluralized :forms {" + " ".join(pairs) + "}}"


def _stage_label(stage: object) -> str:
    if isinstance(stage, str):
        return f"{{:type :neutral :label {_quote(stage)}}}"
    return f"{{:type :gendered :m {_quote(stage['m'])} :f {_quote(stage['f'])}}}"


def _compactness_override(ovr: dict) -> str:
    parts = []
    for unit_name in ("day", "week", "month", "year"):
        if "units" in ovr and unit_name in ovr["units"]:
            val = ovr["units"][unit_name]
            parts.append(f":{unit_name} {_unit_forms(val)}")
        else:
            parts.append(f":{unit_name} nil")
    if "half" in ovr:
        parts.append(f":half {_quote(ovr['half'])}")
    else:
        parts.append(":half nil")
    if "delimiter" in ovr:
        parts.append(f":delimiter {_quote(ovr['delimiter'])}")
    else:
        parts.append(":delimiter nil")
    if "justBorn" in ovr:
        parts.append(f":just-born {_quote(ovr['justBorn'])}")
    else:
        parts.append(":just-born nil")
    return "{" + " ".join(parts) + "}"


def emit_locale(data: dict) -> str:
    code = data["code"]
    rule = data["pluralRule"]
    ns = _ns_name(code)

    lines = [HEADER + locale_source_comment(code, line_prefix=";; ")]
    lines.append(f"(ns sayableage.locales.{ns})")
    lines.append("")
    lines.append("(def locale")

    parts = []
    parts.append(f"  {{:code {_quote(code)}")
    parts.append(f"   :plural {get_clj_plural(rule)}")

    for unit_name in ("day", "week", "month", "year"):
        val = _unit_forms(data["units"][unit_name])
        parts.append(f"   :{unit_name} {val}")

    parts.append(f"   :half {_quote(data['half'])}")
    parts.append(f"   :delimiter {_quote(data['delimiter'])}")
    parts.append(f"   :just-born {_quote(data['justBorn'])}")

    stages = data["stages"]
    stage_names = ["newborn", "infant", "toddler", "child", "teenager", "adult"]
    stage_parts = []
    for stage in stage_names:
        stage_parts.append(f":{stage} {_stage_label(stages[stage])}")
    parts.append("   :stages {" + " ".join(stage_parts) + "}")

    for mode in ("short", "compact"):
        if mode in data:
            parts.append(f"   :{mode} {_compactness_override(data[mode])}")
        else:
            parts.append(f"   :{mode} nil")

    lines.append("\n".join(parts) + "})")
    lines.append("")

    return "\n".join(lines)


def emit_barrel(all_locales: list[dict]) -> str:
    """Generate the sayableage.locales barrel namespace."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER]
    lines.append("(ns sayableage.locales")
    lines.append("  (:require")
    for loc in sorted_locs:
        ns = _ns_name(loc["code"])
        lines.append(f"    [sayableage.locales.{ns} :as {ns}]")
    lines.append("    ))")
    lines.append("")
    lines.append("(defn get-locale [code]")
    lines.append("  (case code")
    for loc in sorted_locs:
        code = loc["code"]
        ns = _ns_name(code)
        lines.append(f'    "{code}" {ns}/locale')
    lines.append("    nil))")
    lines.append("")

    return "\n".join(lines)


def output_path(code: str, root: str) -> str:
    import os
    ns = _ns_name(code)
    return os.path.join(root, "impl", "clojure", "src", "sayableage", "locales", f"{ns}.clj")


def barrel_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "clojure", "src", "sayableage", "locales.clj")
