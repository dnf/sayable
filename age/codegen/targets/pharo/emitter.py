"""Pharo Smalltalk locale emitter.

Generates Pharo chunk-format (.st) files loadable via FileStream fileIn:.
"""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header
from codegen.targets.pharo.plural_rules import get_st_plural

HEADER = make_header("codegen/targets/pharo/emitter.py", line_prefix='" ', line_suffix=' "')


def _quote(s: str) -> str:
    """Quote a string for Smalltalk — single quotes with doubling."""
    escaped = s.replace("'", "''")
    return f"'{escaped}'"


def _unit_forms(unit: object) -> str:
    """Emit unit forms as a Smalltalk Dictionary construction expression."""
    if isinstance(unit, str):
        return _quote(unit)
    cats = ["zero", "one", "two", "few", "many", "other"]
    pairs = ". ".join(f"#{cat}. {_quote(unit[cat])}" for cat in cats if cat in unit)
    return f"(Dictionary newFromPairs: {{ {pairs} }})"


def _stage_label(stage: object) -> str:
    if isinstance(stage, str):
        return _quote(stage)
    return "(Dictionary newFromPairs: { #m. " + _quote(stage["m"]) + ". #f. " + _quote(stage["f"]) + " })"


def emit_locale(data: dict) -> str:
    code = data["code"]
    rule = data["pluralRule"]

    lines = [HEADER + locale_source_comment(code, line_prefix='" ', line_suffix=' "')]
    lines.append(f'"Locale: {code}"!')
    lines.append("")

    # Plural rule as a block
    plural = get_st_plural(rule)

    # Class-side method on SayableAgeLocales using chunk format
    lines.append(f"!SayableAgeLocales class methodsFor: 'locales'!")
    lines.append(f"{code}")
    lines.append(f"\t| locale |")
    lines.append(f"\tlocale := SayableAgeLocale new.")
    lines.append(f"\tlocale code: {_quote(code)}.")
    lines.append(f"\tlocale plural: {plural}.")

    # Units
    lines.append(f"\tlocale units: (Dictionary newFromPairs: {{")
    for unit_name in ("day", "week", "month", "year"):
        val = _unit_forms(data["units"][unit_name])
        lines.append(f"\t\t{_quote(unit_name)}. {val}.")
    lines.append(f"\t}}).")

    # Simple fields
    lines.append(f"\tlocale half: {_quote(data['half'])}.")
    lines.append(f"\tlocale delimiter: {_quote(data['delimiter'])}.")
    lines.append(f"\tlocale justBorn: {_quote(data['justBorn'])}.")

    # Stages
    lines.append(f"\tlocale stages: (Dictionary newFromPairs: {{")
    for stage in ("newborn", "infant", "toddler", "child", "teenager", "adult"):
        val = _stage_label(data["stages"][stage])
        lines.append(f"\t\t#{stage}. {val}.")
    lines.append(f"\t}}).")

    # Short/compact overrides
    for mode in ("short", "compact"):
        if mode in data:
            ovr = data[mode]
            lines.append(f"\tlocale {mode}: (Dictionary newFromPairs: {{")
            if "units" in ovr:
                lines.append(f"\t\t#units. (Dictionary newFromPairs: {{")
                for unit_name in ("day", "week", "month", "year"):
                    if unit_name in ovr["units"]:
                        val = _unit_forms(ovr["units"][unit_name])
                        lines.append(f"\t\t\t{_quote(unit_name)}. {val}.")
                lines.append(f"\t\t}}).")
            if "half" in ovr:
                lines.append(f"\t\t#half. {_quote(ovr['half'])}.")
            if "delimiter" in ovr:
                lines.append(f"\t\t#delimiter. {_quote(ovr['delimiter'])}.")
            if "justBorn" in ovr:
                lines.append(f"\t\t#justBorn. {_quote(ovr['justBorn'])}.")
            lines.append(f"\t}}).")

    lines.append(f"\t^ locale")
    lines.append("! !")
    lines.append("")

    return "\n".join(lines)


def emit_registry(all_locales: list[dict]) -> str:
    """Generate registry.st with lookup methods in chunk format."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER]
    lines.append('"Locale registry — maps code strings to locale objects."!')
    lines.append("")

    # Class-side methods
    lines.append("!SayableAgeLocales class methodsFor: 'registry'!")
    lines.append("buildRegistry")
    lines.append("\t| registry |")
    lines.append("\tregistry := Dictionary new.")
    for loc in sorted_locs:
        code = loc["code"]
        lines.append(f"\tregistry at: {_quote(code)} put: self {code}.")
    lines.append("\t^ registry")
    lines.append("!")
    lines.append("")
    lines.append("get: aCode")
    lines.append("\t^ self registry at: aCode ifAbsent: [ nil ]")
    lines.append("!")
    lines.append("")
    lines.append("registry")
    lines.append("\tRegistry ifNil: [ Registry := self buildRegistry ].")
    lines.append("\t^ Registry")
    lines.append("! !")
    lines.append("")

    return "\n".join(lines)


def output_path(code: str, root: str) -> str:
    import os
    return os.path.join(root, "impl", "pharo", "locales", f"{code}.st")


def registry_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "pharo", "locales", "registry.st")
