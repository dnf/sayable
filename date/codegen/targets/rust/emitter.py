"""Rust locale emitter for sayable-date."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header

HEADER = make_header("codegen/targets/rust/emitter.py")


def _quote(s: str) -> str:
    escaped = s.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def _str_array_12(items: list[str]) -> str:
    """Emit a Rust [String; 12] array literal."""
    return "[" + ", ".join(f"{_quote(s)}.to_string()" for s in items) + "]"


def _str_array_7(items: list[str]) -> str:
    """Emit a Rust [String; 7] array literal."""
    return "[" + ", ".join(f"{_quote(s)}.to_string()" for s in items) + "]"


def _str_map(d: dict[str, str]) -> str:
    """Emit a Rust HashMap::from([...]) literal."""
    if not d:
        return "HashMap::new()"
    pairs = [f"({_quote(k)}.to_string(), {_quote(v)}.to_string())" for k, v in d.items()]
    return "HashMap::from([\n" + "".join(f"            {p},\n" for p in pairs) + "        ])"


def _opt_str(data: dict, key: str) -> str:
    """Return Some("...".to_string()) if key present, else None."""
    if key in data:
        return f"Some({_quote(data[key])}.to_string())"
    return "None"


def emit_locale(data: dict) -> str:
    """Generate a Rust locale file from canonical JSON."""
    code = data["code"]
    name = data["name"]

    lines = [HEADER + locale_source_comment(code)]

    # Imports
    imports = ["DateLocale"]
    has_overrides = "short" in data or "compact" in data
    if has_overrides:
        imports.append("CompactnessOverride")
    lines.append("use std::collections::HashMap;\n")
    lines.append(f"use crate::types::{{{', '.join(sorted(imports))}}};\n")

    lines.append(f"/// {name} locale.")
    lines.append("pub fn locale() -> DateLocale {")
    lines.append("    DateLocale {")
    lines.append(f"        code: {_quote(code)}.to_string(),")

    # Months & Weekdays
    lines.append(f"        months: {_str_array_12(data['months'])},")
    lines.append(f"        weekdays: {_str_array_7(data['weekdays'])},")

    # DayFormat
    lines.append(f"        day_format: {_quote(data['dayFormat'])}.to_string(),")

    # DayFormatExceptions
    exceptions = data.get("dayFormatExceptions", {})
    lines.append(f"        day_format_exceptions: {_str_map(exceptions)},")

    # Date patterns
    lines.append(f"        date_pattern: {_quote(data['datePattern'])}.to_string(),")
    lines.append(f"        date_pattern_with_year: {_quote(data['datePatternWithYear'])}.to_string(),")

    # Required strings
    lines.append(f"        today: {_quote(data['today'])}.to_string(),")
    lines.append(f"        tomorrow: {_quote(data['tomorrow'])}.to_string(),")
    lines.append(f"        yesterday: {_quote(data['yesterday'])}.to_string(),")

    # Optional strings
    lines.append(f"        day_after_tomorrow: {_opt_str(data, 'dayAfterTomorrow')},")
    lines.append(f"        day_before_yesterday: {_opt_str(data, 'dayBeforeYesterday')},")
    lines.append(f"        this_weekday: {_opt_str(data, 'thisWeekday')},")
    lines.append(f"        next_weekday: {_opt_str(data, 'nextWeekday')},")
    lines.append(f"        last_weekday: {_opt_str(data, 'lastWeekday')},")

    # MonthsInDate (optional)
    if "monthsInDate" in data:
        lines.append(f"        months_in_date: Some({_str_array_12(data['monthsInDate'])}),")
    else:
        lines.append("        months_in_date: None,")

    # Short override
    if "short" in data:
        ovr = data["short"]
        lines.append("        short: Some(CompactnessOverride {")
        if "months" in ovr:
            lines.append(f"            months: Some({_str_array_12(ovr['months'])}),")
        else:
            lines.append("            months: None,")
        if "monthsInDate" in ovr:
            lines.append(f"            months_in_date: Some({_str_array_12(ovr['monthsInDate'])}),")
        else:
            lines.append("            months_in_date: None,")
        if "weekdays" in ovr:
            lines.append(f"            weekdays: Some({_str_array_7(ovr['weekdays'])}),")
        else:
            lines.append("            weekdays: None,")
        if "dayFormat" in ovr:
            lines.append(f"            day_format: Some({_quote(ovr['dayFormat'])}.to_string()),")
        else:
            lines.append("            day_format: None,")
        if "dayFormatExceptions" in ovr:
            lines.append(f"            day_format_exceptions: Some({_str_map(ovr['dayFormatExceptions'])}),")
        else:
            lines.append("            day_format_exceptions: None,")
        if "datePattern" in ovr:
            lines.append(f"            date_pattern: Some({_quote(ovr['datePattern'])}.to_string()),")
        else:
            lines.append("            date_pattern: None,")
        if "datePatternWithYear" in ovr:
            lines.append(f"            date_pattern_with_year: Some({_quote(ovr['datePatternWithYear'])}.to_string()),")
        else:
            lines.append("            date_pattern_with_year: None,")
        if "today" in ovr:
            lines.append(f"            today: Some({_quote(ovr['today'])}.to_string()),")
        else:
            lines.append("            today: None,")
        if "tomorrow" in ovr:
            lines.append(f"            tomorrow: Some({_quote(ovr['tomorrow'])}.to_string()),")
        else:
            lines.append("            tomorrow: None,")
        if "yesterday" in ovr:
            lines.append(f"            yesterday: Some({_quote(ovr['yesterday'])}.to_string()),")
        else:
            lines.append("            yesterday: None,")
        lines.append("        }),")
    else:
        lines.append("        short: None,")

    # Compact override
    if "compact" in data:
        ovr = data["compact"]
        lines.append("        compact: Some(CompactnessOverride {")
        if "months" in ovr:
            lines.append(f"            months: Some({_str_array_12(ovr['months'])}),")
        else:
            lines.append("            months: None,")
        if "monthsInDate" in ovr:
            lines.append(f"            months_in_date: Some({_str_array_12(ovr['monthsInDate'])}),")
        else:
            lines.append("            months_in_date: None,")
        if "weekdays" in ovr:
            lines.append(f"            weekdays: Some({_str_array_7(ovr['weekdays'])}),")
        else:
            lines.append("            weekdays: None,")
        if "dayFormat" in ovr:
            lines.append(f"            day_format: Some({_quote(ovr['dayFormat'])}.to_string()),")
        else:
            lines.append("            day_format: None,")
        if "dayFormatExceptions" in ovr:
            lines.append(f"            day_format_exceptions: Some({_str_map(ovr['dayFormatExceptions'])}),")
        else:
            lines.append("            day_format_exceptions: None,")
        if "datePattern" in ovr:
            lines.append(f"            date_pattern: Some({_quote(ovr['datePattern'])}.to_string()),")
        else:
            lines.append("            date_pattern: None,")
        if "datePatternWithYear" in ovr:
            lines.append(f"            date_pattern_with_year: Some({_quote(ovr['datePatternWithYear'])}.to_string()),")
        else:
            lines.append("            date_pattern_with_year: None,")
        if "today" in ovr:
            lines.append(f"            today: Some({_quote(ovr['today'])}.to_string()),")
        else:
            lines.append("            today: None,")
        if "tomorrow" in ovr:
            lines.append(f"            tomorrow: Some({_quote(ovr['tomorrow'])}.to_string()),")
        else:
            lines.append("            tomorrow: None,")
        if "yesterday" in ovr:
            lines.append(f"            yesterday: Some({_quote(ovr['yesterday'])}.to_string()),")
        else:
            lines.append("            yesterday: None,")
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
