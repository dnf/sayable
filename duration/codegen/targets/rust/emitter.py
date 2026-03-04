"""Rust locale emitter for sayable-duration."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header
from codegen.targets.rust.plural_rules import get_rs_plural

HEADER = make_header("codegen/targets/rust/emitter.py")

_CAT_MAP = {
    "zero": "PluralCategory::Zero", "one": "PluralCategory::One",
    "two": "PluralCategory::Two", "few": "PluralCategory::Few",
    "many": "PluralCategory::Many", "other": "PluralCategory::Other",
}

# Duration has 7 unit names
_UNIT_NAMES = ("second", "minute", "hour", "day", "week", "month", "year")


def _quote(s: str) -> str:
    escaped = s.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def _unit_forms(unit: object) -> str:
    if isinstance(unit, str):
        return f"UnitForms::simple({_quote(unit)})"
    cats = ["zero", "one", "two", "few", "many", "other"]
    pairs = []
    for cat in cats:
        if cat in unit:
            pairs.append(f"({_CAT_MAP[cat]}, {_quote(unit[cat])})")
    return "UnitForms::plural(&[\n" + "".join(f"                {p},\n" for p in pairs) + "            ])"


def emit_locale(data: dict) -> str:
    code = data["code"]
    rule = data["pluralRule"]
    name = data["name"]

    lines = [HEADER + locale_source_comment(code)]

    # Imports
    imports = ["DurationLocale", "PluralCategory", "Units", "UnitForms"]
    has_overrides = "short" in data or "compact" in data
    if has_overrides:
        imports.append("CompactnessOverride")
    lines.append(f"use crate::types::{{{', '.join(imports)}}};\n")

    lines.append(f"/// {name} locale.")
    lines.append("pub fn locale() -> DurationLocale {")
    lines.append("    DurationLocale {")
    lines.append(f"        code: {_quote(code)}.to_string(),")

    # Plural
    plural = get_rs_plural(rule)
    lines.append(f"        plural: {plural},")

    # Units (all 7)
    lines.append("        units: Units {")
    for unit_name in _UNIT_NAMES:
        val = _unit_forms(data["units"][unit_name])
        lines.append(f"            {unit_name}: {val},")
    lines.append("        },")

    # Simple fields
    lines.append(f"        half: {_quote(data['half'])}.to_string(),")
    lines.append(f"        delimiter: {_quote(data['delimiter'])}.to_string(),")
    lines.append(f"        just_now: {_quote(data['justNow'])}.to_string(),")
    lines.append(f"        ago: {_quote(data['ago'])}.to_string(),")
    lines.append(f"        in_future: {_quote(data['inFuture'])}.to_string(),")

    # Short/compact overrides
    for mode in ("short", "compact"):
        if mode in data:
            ovr = data[mode]
            lines.append(f"        {mode}: Some(CompactnessOverride {{")
            for unit_name in _UNIT_NAMES:
                if "units" in ovr and unit_name in ovr["units"]:
                    val = ovr["units"][unit_name]
                    if isinstance(val, str):
                        lines.append(f"            {unit_name}: Some(UnitForms::simple({_quote(val)})),")
                    else:
                        lines.append(f"            {unit_name}: Some({_unit_forms(val)}),")
                else:
                    lines.append(f"            {unit_name}: None,")
            if "half" in ovr:
                lines.append(f"            half: Some({_quote(ovr['half'])}.to_string()),")
            else:
                lines.append("            half: None,")
            if "delimiter" in ovr:
                if ovr["delimiter"] == "":
                    lines.append("            delimiter: Some(String::new()),")
                else:
                    lines.append(f"            delimiter: Some({_quote(ovr['delimiter'])}.to_string()),")
            else:
                lines.append("            delimiter: None,")
            if "ago" in ovr:
                lines.append(f"            ago: Some({_quote(ovr['ago'])}.to_string()),")
            else:
                lines.append("            ago: None,")
            if "inFuture" in ovr:
                lines.append(f"            in_future: Some({_quote(ovr['inFuture'])}.to_string()),")
            else:
                lines.append("            in_future: None,")
            lines.append("        }),")
        else:
            lines.append(f"        {mode}: None,")

    lines.append("        format_number: None,")
    lines.append("        format_unit: None,")
    lines.append("    }")
    lines.append("}")
    lines.append("")

    return "\n".join(lines)


def emit_barrel(all_locales: list[dict]) -> str:
    """Generate the locales/mod.rs barrel file."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER]
    lines.append(f"//! Built-in locale definitions for {len(all_locales)} languages.")
    lines.append("//!")
    lines.append("//! Each submodule exports a `locale()` function returning a [`DurationLocale`].")
    lines.append("//! Prefer using the static constants (e.g., [`EN`], [`JA`]) for lazy-initialized access.")
    lines.append("")
    lines.append("#![allow(missing_docs)]")

    # Module declarations
    lines.append("")
    for loc in sorted_locs:
        lines.append(f"pub mod {loc['code']};")

    lines.append("")
    lines.append("use crate::types::DurationLocale;")
    lines.append("")

    # Static constants
    for loc in sorted_locs:
        code = loc["code"]
        name = loc["name"]
        lines.append(f"/// {name} locale constant.")
        lines.append(f"pub static {code.upper()}: std::sync::LazyLock<DurationLocale> = std::sync::LazyLock::new({code}::locale);")

    lines.append("")

    # Lookup function
    lines.append("/// Look up a locale by its code string.")
    lines.append("pub fn get(code: &str) -> Option<&'static DurationLocale> {")
    lines.append("    match code {")
    for loc in sorted_locs:
        code = loc["code"]
        lines.append(f'        "{code}" => Some(&*{code.upper()}),')
    lines.append("        _ => None,")
    lines.append("    }")
    lines.append("}")
    lines.append("")

    return "\n".join(lines)


def output_path(code: str, root: str) -> str:
    import os
    return os.path.join(root, "impl", "rust", "src", "locales", f"{code}.rs")


def barrel_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "rust", "src", "locales", "mod.rs")
