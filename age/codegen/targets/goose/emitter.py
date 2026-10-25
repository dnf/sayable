"""Goose locale emitter — single file with all locales.

Goose cannot store function values, so each locale carries a PluralRule
enum and plural_category() dispatches on it. Each locale is a function
returning its Locale: a single top-level table of struct literals makes
native builds superlinearly slow.
"""

from __future__ import annotations

import os

from codegen.banner import locale_source_comment, make_header
from codegen.targets.goose.plural_rules import get_goose_plural

HEADER = make_header("codegen/targets/goose/emitter.py")

_UNITS = ("day", "week", "month", "year")
_STAGES = ("newborn", "infant", "toddler", "child", "teenager", "adult")
_CATEGORIES = ("zero", "one", "two", "few", "many", "other")


def _quote(s: str) -> str:
    escaped = s.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def _rule_variant(rule: str) -> str:
    return "".join(part.capitalize() for part in rule.split("_"))


def _unit_forms(unit: object) -> str:
    if isinstance(unit, str):
        return f"UnitForms {{ simple: true, other: {_quote(unit)} }}"
    fields = [f"{cat}: {_quote(unit[cat])}" for cat in _CATEGORIES if cat in unit]
    return "UnitForms { " + ", ".join(fields) + " }"


def _stage_label(stage: object) -> str:
    if isinstance(stage, str):
        return f"StageLabel {{ label: {_quote(stage)} }}"
    return f"StageLabel {{ label: {_quote(stage['m'])}, f: {_quote(stage['f'])} }}"


def _compactness_override(ovr: dict) -> str:
    fields = []
    for unit_name in _UNITS:
        if unit_name in ovr.get("units", {}):
            fields.append(f"has_{unit_name}: true")
            fields.append(f"{unit_name}: {_unit_forms(ovr['units'][unit_name])}")
    for key, name in (("half", "half"), ("delimiter", "delimiter"), ("justBorn", "just_born")):
        if key in ovr:
            fields.append(f"has_{name}: true")
            fields.append(f"{name}: {_quote(ovr[key])}")
    return "CompactnessOverride { " + ", ".join(fields + [".."]) + " }"


def _emit_plural_rules(rules: list[str]) -> list[str]:
    lines = ["enum PluralRule { " + ", ".join(_rule_variant(r) for r in rules) + " }", ""]
    for rule in rules:
        lines.append(f"fn plural_{rule}(n: i64) -> PluralCategory {{")
        for body_line in get_goose_plural(rule).split("\n"):
            lines.append(f"    {body_line.strip()}")
        lines.append("}")
        lines.append("")
    lines.append("fn plural_category(rule: PluralRule, n: i64) -> PluralCategory {")
    lines.append("    match rule {")
    for rule in rules:
        lines.append(f"        {_rule_variant(rule)} => plural_{rule}(n),")
    lines.append("    }")
    lines.append("}")
    lines.append("")
    return lines


def _emit_locale(data: dict) -> list[str]:
    code = data["code"]
    lines = [locale_source_comment(code).rstrip()]
    lines.append(f"fn locale_{code}() -> Locale {{")
    lines.append("    Locale {")
    lines.append(f"        code: {_quote(code)},")
    lines.append(f"        plural: PluralRule.{_rule_variant(data['pluralRule'])},")
    lines.append("        units: UnitSet {")
    for unit_name in _UNITS:
        lines.append(f"            {unit_name}: {_unit_forms(data['units'][unit_name])},")
    lines.append("        },")
    lines.append(f"        half: {_quote(data['half'])},")
    lines.append(f"        delimiter: {_quote(data['delimiter'])},")
    lines.append(f"        just_born: {_quote(data['justBorn'])},")
    lines.append("        stages: Stages {")
    for stage in _STAGES:
        lines.append(f"            {stage}: {_stage_label(data['stages'][stage])},")
    lines.append("        },")
    for key, field in (("short", "short_override"), ("compact", "compact_override")):
        if key in data:
            lines.append(f"        {field}: {_compactness_override(data[key])},")
    lines.append("    }")
    lines.append("}")
    lines.append("")
    return lines


def emit_all(all_locales: list[dict]) -> str:
    """Generate the single locales.goose file with all locales."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER]
    lines.append("namespace sayableage;")
    lines.append("")

    rules = sorted({data["pluralRule"] for data in sorted_locs})
    lines.extend(_emit_plural_rules(rules))

    for data in sorted_locs:
        lines.extend(_emit_locale(data))

    lines.append("// Look up a locale by exact, case-sensitive code.")
    lines.append("fn get_locale(code: u8[:]) -> Locale, bool {")
    for data in sorted_locs:
        c = data["code"]
        lines.append(f"    if code == {_quote(c)} {{ return locale_{c}(), true; }}")
    lines.append("    return Locale { .. }, false;")
    lines.append("}")
    lines.append("")

    lines.append("let LOCALE_CODES = [")
    for data in sorted_locs:
        lines.append(f"    {_quote(data['code'])},")
    lines.append("];")
    lines.append("")

    return "\n".join(lines)


def output_path(root: str) -> str:
    return os.path.join(root, "impl", "goose", "sayableage", "locales", "locales.goose")
