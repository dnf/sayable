"""Rust locale emitter for sayable-date."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header
from codegen.targets.rust.layout import arr, call, lit, render_expr, struct, to_string, tup, use_line

HEADER = make_header("codegen/targets/rust/emitter.py")

# CompactnessOverride fields, in declaration order, with their JSON keys.
_OVERRIDE_FIELDS = (
    ("months", "months"),
    ("months_in_date", "monthsInDate"),
    ("weekdays", "weekdays"),
    ("day_format", "dayFormat"),
    ("day_format_exceptions", "dayFormatExceptions"),
    ("date_pattern", "datePattern"),
    ("date_pattern_with_year", "datePatternWithYear"),
    ("today", "today"),
    ("tomorrow", "tomorrow"),
    ("yesterday", "yesterday"),
)

_ARRAY_KEYS = ("months", "monthsInDate", "weekdays")


def _str_array(items: list[str]) -> object:
    """A Rust [String; N] array literal (12 months or 7 weekdays)."""
    return arr([to_string(s) for s in items])


def _str_map(d: dict[str, str]) -> object:
    """A Rust HashMap::from([...]) literal, or HashMap::new() when empty."""
    if not d:
        return lit("HashMap::new()")
    return call("HashMap::from", arr([tup(to_string(k), to_string(v)) for k, v in d.items()]))


def _opt_str(data: dict, key: str) -> object:
    """Some("...".to_string()) if key present, else None."""
    if key in data:
        return call("Some", to_string(data[key]))
    return lit("None")


def _override_value(ovr: dict, key: str) -> object:
    if key not in ovr:
        return lit("None")
    if key in _ARRAY_KEYS:
        return call("Some", _str_array(ovr[key]))
    if key == "dayFormatExceptions":
        return call("Some", _str_map(ovr[key]))
    return call("Some", to_string(ovr[key]))


def _override(ovr: dict) -> object:
    fields = [(field, _override_value(ovr, key)) for field, key in _OVERRIDE_FIELDS]
    return call("Some", struct("CompactnessOverride", fields))


def emit_locale(data: dict) -> str:
    """Generate a Rust locale file from canonical JSON."""
    code = data["code"]
    name = data["name"]

    lines = [HEADER + locale_source_comment(code)]

    imports = ["DateLocale"]
    has_overrides = "short" in data or "compact" in data
    if has_overrides:
        imports.append("CompactnessOverride")
    lines.append("use std::collections::HashMap;\n")
    lines.append(use_line("crate::types", imports) + "\n")

    fields: list[tuple[str, object]] = [
        ("code", to_string(code)),
        ("months", _str_array(data["months"])),
        ("weekdays", _str_array(data["weekdays"])),
        ("day_format", to_string(data["dayFormat"])),
        ("day_format_exceptions", _str_map(data.get("dayFormatExceptions", {}))),
        ("date_pattern", to_string(data["datePattern"])),
        ("date_pattern_with_year", to_string(data["datePatternWithYear"])),
        ("today", to_string(data["today"])),
        ("tomorrow", to_string(data["tomorrow"])),
        ("yesterday", to_string(data["yesterday"])),
        ("day_after_tomorrow", _opt_str(data, "dayAfterTomorrow")),
        ("day_before_yesterday", _opt_str(data, "dayBeforeYesterday")),
        ("this_weekday", _opt_str(data, "thisWeekday")),
        ("next_weekday", _opt_str(data, "nextWeekday")),
        ("last_weekday", _opt_str(data, "lastWeekday")),
        ("months_in_date", call("Some", _str_array(data["monthsInDate"])) if "monthsInDate" in data else lit("None")),
    ]
    for mode in ("short", "compact"):
        fields.append((mode, _override(data[mode]) if mode in data else lit("None")))

    lines.append(f"/// {name} locale.")
    lines.append("pub fn locale() -> DateLocale {")
    lines.append("    " + render_expr(struct("DateLocale", fields), 4, 4))
    lines.append("}")
    lines.append("")

    return "\n".join(lines)


def emit_barrel(all_locales: list[dict]) -> str:
    """Generate the locales/mod.rs barrel file."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER]
    lines.append(f"//! Built-in locale definitions for {len(all_locales)} languages.")
    lines.append("//!")
    lines.append("//! Each submodule exports a `locale()` function returning a [`DateLocale`].")
    lines.append("//! Prefer using the static constants (e.g., [`EN`], [`JA`]) for lazy-initialized access.")
    lines.append("")
    lines.append("#![allow(missing_docs)]")

    # Module declarations
    lines.append("")
    for loc in sorted_locs:
        lines.append(f"pub mod {loc['code']};")

    lines.append("")
    lines.append("use crate::types::DateLocale;")
    lines.append("")

    # Static constants
    for loc in sorted_locs:
        code = loc["code"]
        name = loc["name"]
        lines.append(f"/// {name} locale constant.")
        lines.append(f"pub static {code.upper()}: std::sync::LazyLock<DateLocale> = std::sync::LazyLock::new({code}::locale);")

    lines.append("")

    # Lookup function
    lines.append("/// Look up a locale by its code string.")
    lines.append("pub fn get(code: &str) -> Option<&'static DateLocale> {")
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
