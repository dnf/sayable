"""Rust locale emitter for sayable-time."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header
from codegen.targets.rust.layout import arr, call, lit, render_expr, struct, to_string, tup, use_line

HEADER = make_header("codegen/targets/rust/emitter.py")


def _str_array_12(items: list[str]) -> object:
    """A Rust [String; 12] literal."""
    return arr([to_string(s) for s in items])


def _patterns_map(patterns: dict[str, str]) -> object:
    """A Rust HashMap::from([...]) for minute patterns."""
    keys = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55]
    pairs = [tup(lit(str(key)), to_string(patterns[str(key)])) for key in keys if str(key) in patterns]
    return call("HashMap::from", arr(pairs))


def _clock_override(clock: dict) -> object:
    """A ShortClockConfig struct for short/compact overrides."""
    use24h = "true" if clock.get("use24h", True) else "false"
    am_pm = clock.get("amPm")
    fmt = clock.get("format", "{h}:{mm}")
    am_pm_value = call("Some", tup(to_string(am_pm[0]), to_string(am_pm[1]))) if am_pm else lit("None")
    return call("Some", struct("ShortClockConfig", [
        ("use24h", lit(use24h)),
        ("am_pm", am_pm_value),
        ("format", to_string(fmt)),
    ]))


def _override(ovr: dict) -> object:
    return call("Some", struct("CompactnessOverride", [("clock", _clock_override(ovr["clock"]))]))


def emit_locale(data: dict) -> str:
    """Generate a Rust locale file from canonical JSON."""
    code = data["code"]
    name = data["name"]
    clock = data["clock"]

    lines = [HEADER + locale_source_comment(code)]

    imports = ["TimeLocale", "ClockConfig"]
    has_overrides = "short" in data or "compact" in data
    if has_overrides:
        imports.extend(["CompactnessOverride", "ShortClockConfig"])
    lines.append(use_line("crate::types", imports))
    lines.append("use std::collections::HashMap;")
    lines.append("")

    fields: list[tuple[str, object]] = [
        ("code", to_string(code)),
        ("clock", struct("ClockConfig", [
            ("hours", _str_array_12(clock["hours"])),
            ("midnight", to_string(clock["midnight"])),
            ("noon", to_string(clock["noon"])),
            ("patterns", _patterns_map(clock["patterns"])),
        ])),
    ]
    for mode in ("short", "compact"):
        fields.append((mode, _override(data[mode]) if mode in data else lit("None")))

    lines.append(f"/// {name} locale.")
    lines.append("pub fn locale() -> TimeLocale {")
    lines.append("    " + render_expr(struct("TimeLocale", fields), 4, 4))
    lines.append("}")
    lines.append("")

    return "\n".join(lines)


def emit_barrel(all_locales: list[dict]) -> str:
    """Generate the locales/mod.rs barrel file."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER]
    lines.append(f"//! Built-in locale definitions for {len(all_locales)} languages.")
    lines.append("//!")
    lines.append("//! Each submodule exports a `locale()` function returning a [`TimeLocale`].")
    lines.append("//! Prefer using the static constants (e.g., [`EN`], [`JA`]) for lazy-initialized access.")
    lines.append("")
    lines.append("#![allow(missing_docs)]")

    # Module declarations
    lines.append("")
    for loc in sorted_locs:
        lines.append(f"pub mod {loc['code']};")

    lines.append("")
    lines.append("use crate::types::TimeLocale;")
    lines.append("")

    # Static constants
    for loc in sorted_locs:
        code = loc["code"]
        name = loc["name"]
        lines.append(f"/// {name} locale constant.")
        lines.append(f"pub static {code.upper()}: std::sync::LazyLock<TimeLocale> = std::sync::LazyLock::new({code}::locale);")

    lines.append("")

    # Lookup function
    lines.append("/// Look up a locale by its code string.")
    lines.append("pub fn get(code: &str) -> Option<&'static TimeLocale> {")
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
