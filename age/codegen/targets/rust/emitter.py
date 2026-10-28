"""Rust locale emitter."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header
from codegen.targets.rust.layout import arr, call, lit, quote, raw, ref, render_expr, struct, to_string, tup, use_line
from codegen.targets.rust.plural_rules import get_rs_plural

HEADER = make_header("codegen/targets/rust/emitter.py")

_CAT_MAP = {
    "zero": "PluralCategory::Zero", "one": "PluralCategory::One",
    "two": "PluralCategory::Two", "few": "PluralCategory::Few",
    "many": "PluralCategory::Many", "other": "PluralCategory::Other",
}

_UNIT_NAMES = ("day", "week", "month", "year")


def _unit_forms(unit: object) -> object:
    if isinstance(unit, str):
        return call("UnitForms::simple", lit(quote(unit)))
    cats = ["zero", "one", "two", "few", "many", "other"]
    pairs = [tup(lit(_CAT_MAP[cat]), lit(quote(unit[cat]))) for cat in cats if cat in unit]
    return call("UnitForms::plural", ref(arr(pairs)))


def _stage_label(stage: object) -> object:
    if isinstance(stage, str):
        return call("StageLabel::Neutral", to_string(stage))
    return struct("StageLabel::Gendered", [("m", to_string(stage["m"])), ("f", to_string(stage["f"]))])


def _some_string(value: str) -> object:
    return call("Some", lit("String::new()") if value == "" else to_string(value))


def _override(ovr: dict) -> object:
    units = ovr.get("units", {})
    fields: list[tuple[str, object]] = [
        (unit_name, call("Some", _unit_forms(units[unit_name])) if unit_name in units else lit("None"))
        for unit_name in _UNIT_NAMES
    ]
    fields.append(("half", call("Some", to_string(ovr["half"])) if "half" in ovr else lit("None")))
    fields.append(("delimiter", _some_string(ovr["delimiter"]) if "delimiter" in ovr else lit("None")))
    fields.append(("just_born", call("Some", to_string(ovr["justBorn"])) if "justBorn" in ovr else lit("None")))
    return call("Some", struct("CompactnessOverride", fields))


def emit_locale(data: dict) -> str:
    code = data["code"]
    rule = data["pluralRule"]
    name = data["name"]

    lines = [HEADER + locale_source_comment(code)]

    imports = ["AgeLocale", "PluralCategory", "Units", "UnitForms", "Stages", "StageLabel"]
    has_overrides = "short" in data or "compact" in data
    if has_overrides:
        imports.append("CompactnessOverride")
    lines.append(use_line("crate::types", imports) + "\n")

    fields: list[tuple[str, object]] = [
        ("code", to_string(code)),
        ("plural", raw(get_rs_plural(rule))),
        ("units", struct("Units", [(u, _unit_forms(data["units"][u])) for u in _UNIT_NAMES])),
        ("half", to_string(data["half"])),
        ("delimiter", to_string(data["delimiter"])),
        ("just_born", to_string(data["justBorn"])),
        ("stages", struct("Stages", [
            (stage, _stage_label(data["stages"][stage]))
            for stage in ("newborn", "infant", "toddler", "child", "teenager", "adult")
        ])),
    ]
    for mode in ("short", "compact"):
        fields.append((mode, _override(data[mode]) if mode in data else lit("None")))
    fields.append(("format_number", lit("None")))
    fields.append(("format_unit", lit("None")))

    lines.append(f"/// {name} locale.")
    lines.append("pub fn locale() -> AgeLocale {")
    lines.append("    " + render_expr(struct("AgeLocale", fields), 4, 4))
    lines.append("}")
    lines.append("")

    return "\n".join(lines)


def emit_barrel(all_locales: list[dict]) -> str:
    """Generate the locales/mod.rs barrel file."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER]
    lines.append(f"//! Built-in locale definitions for {len(all_locales)} languages.")
    lines.append("//!")
    lines.append("//! Each submodule exports a `locale()` function returning an [`AgeLocale`].")
    lines.append("//! Prefer using the static constants (e.g., [`EN`], [`JA`]) for lazy-initialized access.")
    lines.append("")
    lines.append("#![allow(missing_docs)]")

    # Module declarations
    lines.append("")
    for loc in sorted_locs:
        lines.append(f"pub mod {loc['code']};")

    lines.append("")
    lines.append("use crate::types::AgeLocale;")
    lines.append("")

    # Static constants
    for loc in sorted_locs:
        code = loc["code"]
        name = loc["name"]
        lines.append(f"/// {name} locale constant.")
        lines.append(f"pub static {code.upper()}: std::sync::LazyLock<AgeLocale> = std::sync::LazyLock::new({code}::locale);")

    lines.append("")

    # Lookup function
    lines.append("/// Look up a locale by its code string.")
    lines.append("pub fn get(code: &str) -> Option<&'static AgeLocale> {")
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
