"""Rust locale emitter for sayable-time."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header

HEADER = make_header("codegen/targets/rust/emitter.py")


def _quote(s: str) -> str:
    """Quote a string for Rust."""
    escaped = s.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def _str_array_12(items: list[str]) -> str:
    """Emit a Rust [String; 12] literal."""
    return "[" + ", ".join(f"{_quote(s)}.to_string()" for s in items) + "]"


def _patterns_map(patterns: dict[str, str]) -> str:
    """Emit a Rust HashMap::from([...]) for minute patterns."""
    keys = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55]
    pairs = []
    for key in keys:
        skey = str(key)
        if skey in patterns:
            pairs.append(f"({key}, {_quote(patterns[skey])}.to_string())")
    return "HashMap::from([\n" + "".join(f"            {p},\n" for p in pairs) + "        ])"


def _clock_override(clock: dict, indent: str) -> list[str]:
    """Emit a ShortClockConfig struct for short/compact overrides."""
    lines = []
    use24h = "true" if clock.get("use24h", True) else "false"
    am_pm = clock.get("amPm")
    fmt = clock.get("format", "{h}:{mm}")

    if am_pm:
        lines.append(f"{indent}clock: Some(ShortClockConfig {{")
        lines.append(f"{indent}    use24h: {use24h},")
        lines.append(f"{indent}    am_pm: Some(({_quote(am_pm[0])}.to_string(), {_quote(am_pm[1])}.to_string())),")
        lines.append(f"{indent}    format: {_quote(fmt)}.to_string(),")
        lines.append(f"{indent}}}),")
    else:
        lines.append(f"{indent}clock: Some(ShortClockConfig {{")
        lines.append(f"{indent}    use24h: {use24h},")
        lines.append(f"{indent}    am_pm: None,")
        lines.append(f"{indent}    format: {_quote(fmt)}.to_string(),")
        lines.append(f"{indent}}}),")

    return lines


def emit_locale(data: dict) -> str:
    """Generate a Rust locale file from canonical JSON."""
    code = data["code"]
    name = data["name"]
    clock = data["clock"]

    lines = [HEADER + locale_source_comment(code)]

    # Imports
    imports = ["TimeLocale", "ClockConfig"]
    has_overrides = "short" in data or "compact" in data
    if has_overrides:
        imports.extend(["CompactnessOverride", "ShortClockConfig"])
    lines.append(f"use crate::types::{{{', '.join(imports)}}};")
    lines.append("use std::collections::HashMap;")
    lines.append("")

    lines.append(f"/// {name} locale.")
    lines.append("pub fn locale() -> TimeLocale {")
    lines.append("    TimeLocale {")
    lines.append(f"        code: {_quote(code)}.to_string(),")

    # Clock config
    lines.append("        clock: ClockConfig {")
    lines.append(f"            hours: {_str_array_12(clock['hours'])},")
    lines.append(f"            midnight: {_quote(clock['midnight'])}.to_string(),")
    lines.append(f"            noon: {_quote(clock['noon'])}.to_string(),")
    lines.append(f"            patterns: {_patterns_map(clock['patterns'])},")
    lines.append("        },")

    # Short override
    if "short" in data:
        lines.append("        short: Some(CompactnessOverride {")
        lines.extend(_clock_override(data["short"]["clock"], "            "))
        lines.append("        }),")
    else:
        lines.append("        short: None,")

    # Compact override
    if "compact" in data:
        lines.append("        compact: Some(CompactnessOverride {")
        lines.extend(_clock_override(data["compact"]["clock"], "            "))
        lines.append("        }),")
    else:
        lines.append("        compact: None,")

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
