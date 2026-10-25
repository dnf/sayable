"""Goose locale emitter for sayable-duration — single file with all locales.

Goose cannot store function values, so each locale carries a PluralRule
enum and plural_category() dispatches on it. Each locale is a function
that fills in a Locale: a single top-level table of struct literals makes
native builds superlinearly slow, and returning the (~2 KB) Locale by
value from 168 call sites in get_locale doubles the native build time,
because the C compiler then optimizes one function holding 336 Locale
temporaries.

Struct field defaults keep the output compact: a simple unit is just its
`other` template, absent plural forms and override fields are omitted,
and `..` fills in the rest.
"""

from __future__ import annotations

import os
import re

from codegen.banner import locale_source_comment, make_header
from codegen.targets.goose.plural_rules import get_goose_plural

HEADER = make_header("codegen/targets/goose/emitter.py")

_UNITS = ("second", "minute", "hour", "day", "week", "month", "year")
_CATEGORIES = ("zero", "one", "two", "few", "many", "other")
_OVERRIDE_STRINGS = (
    ("half", "half"),
    ("delimiter", "delimiter"),
    ("ago", "ago"),
    ("inFuture", "in_future"),
)


def _quote(s: str) -> str:
    escaped = s.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def _ident(code: str) -> str:
    """Locale function name; the prefix keeps every code clear of keywords."""
    return "locale_" + re.sub(r"[^A-Za-z0-9_]", "_", code)


def _rule_variant(rule: str) -> str:
    return "".join(part.capitalize() for part in rule.split("_"))


def _unit_forms(unit: object) -> str:
    if isinstance(unit, str):
        return f"UnitForms {{ other: {_quote(unit)} }}"
    fields = [f"{cat}: {_quote(unit[cat])}" for cat in _CATEGORIES if cat in unit]
    return "UnitForms { " + ", ".join(fields) + " }"


def _unit_set(units: dict, indent: str) -> list[str]:
    lines = ["UnitSet {"]
    for unit_name in _UNITS:
        if unit_name in units:
            lines.append(f"{indent}    {unit_name}: {_unit_forms(units[unit_name])},")
    if any(unit_name not in units for unit_name in _UNITS):
        lines.append(f"{indent}    ..")
    lines.append(f"{indent}}}")
    return lines


def _compactness_override(field: str, ovr: dict) -> list[str]:
    indent = "        "
    lines = [f"{indent}{field}: CompactnessOverride {{"]
    if "units" in ovr:
        unit_lines = _unit_set(ovr["units"], indent + "    ")
        lines.append(f"{indent}    units: {unit_lines[0]}")
        lines.extend(unit_lines[1:-1])
        lines.append(f"{unit_lines[-1]},")
    for key, name in _OVERRIDE_STRINGS:
        if key in ovr:
            lines.append(f"{indent}    has_{name}: true, {name}: {_quote(ovr[key])},")
    lines.append(f"{indent}    ..")
    lines.append(f"{indent}}},")
    return lines


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
    lines.append(f"fn {_ident(code)}(l: Locale&) {{")
    lines.append("    l = Locale {")
    lines.append(f"        code: {_quote(code)},")
    lines.append(f"        plural: PluralRule.{_rule_variant(data['pluralRule'])},")
    unit_lines = _unit_set(data["units"], "        ")
    lines.append(f"        units: {unit_lines[0]}")
    lines.extend(unit_lines[1:-1])
    lines.append(f"{unit_lines[-1]},")
    lines.append(f"        half: {_quote(data['half'])},")
    lines.append(f"        delimiter: {_quote(data['delimiter'])},")
    lines.append(f"        just_now: {_quote(data['justNow'])},")
    lines.append(f"        ago: {_quote(data['ago'])},")
    lines.append(f"        in_future: {_quote(data['inFuture'])},")
    for key, field in (("short", "short_override"), ("compact", "compact_override")):
        if key in data:
            lines.extend(_compactness_override(field, data[key]))
    lines.append("    };")
    lines.append("}")
    lines.append("")
    return lines


def emit_all(all_locales: list[dict]) -> str:
    """Generate the single locales.goose file with all locales."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER]
    lines.append("namespace sayableduration;")
    lines.append("")

    rules = sorted({data["pluralRule"] for data in sorted_locs})
    lines.extend(_emit_plural_rules(rules))

    for data in sorted_locs:
        lines.extend(_emit_locale(data))

    lines.append("// Look up a locale by exact, case-sensitive code.")
    lines.append("fn get_locale(code: u8[:]) -> Locale, bool {")
    lines.append("    var l = Locale { .. };")
    for data in sorted_locs:
        c = data["code"]
        lines.append(f"    if code == {_quote(c)} {{ {_ident(c)}(l); return l, true; }}")
    lines.append("    return l, false;")
    lines.append("}")
    lines.append("")

    lines.append("let LOCALE_CODES = [")
    for data in sorted_locs:
        lines.append(f"    {_quote(data['code'])},")
    lines.append("];")
    lines.append("")

    return "\n".join(lines)


def output_path(root: str) -> str:
    return os.path.join(root, "impl", "goose", "sayableduration", "locales", "locales.goose")
