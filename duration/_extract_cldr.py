#!/usr/bin/env python3
"""One-time CLDR extraction: pull short + narrow duration unit patterns for 71 locales.

Installs `cldr-units-full` to a temp directory, reads JSON for each locale,
extracts short and narrow patterns for 7 duration units, converts {0} → {n},
and writes the result as a Python module (_cldr_duration_units.py).

Usage:
    python duration/_extract_cldr.py
"""

from __future__ import annotations

import json
import os
import subprocess
import sys
import tempfile

# Our 71 locale codes
LOCALE_CODES = [
    "am", "ar", "az", "bg", "bn", "br", "bs", "ca", "cs", "cy",
    "da", "de", "el", "en", "es", "et", "eu", "fa", "fi", "fil",
    "fr", "ga", "gd", "gu", "gv", "he", "hi", "hr", "hu", "id",
    "it", "ja", "jv", "ka", "kk", "km", "ko", "kw", "lt", "lv",
    "mk", "mr", "ms", "mt", "my", "nb", "ne", "nl", "pa", "pl",
    "pt", "ro", "ru", "shi", "si", "sk", "sl", "sq", "sr", "sv",
    "sw", "ta", "te", "th", "tr", "tzm", "uk", "ur", "uz", "vi",
    "zh",
]

# CLDR unit keys for our 7 duration units
CLDR_UNIT_MAP = {
    "second": "duration-second",
    "minute": "duration-minute",
    "hour": "duration-hour",
    "day": "duration-day",
    "week": "duration-week",
    "month": "duration-month",
    "year": "duration-year",
}

# Plural categories in CLDR
PLURAL_CATS = ["zero", "one", "two", "few", "many", "other"]

# Locales where CLDR has English placeholder data (not real translations)
ENGLISH_SHELL_LOCALES = {"gv", "kw", "shi", "tzm"}


def install_cldr(tmpdir: str) -> str:
    """Install cldr-units-full and return the path to the main/ directory."""
    print("Installing cldr-units-full...")
    subprocess.run(
        ["npm", "install", "--prefix", tmpdir, "cldr-units-full"],
        check=True,
        capture_output=True,
    )
    return os.path.join(tmpdir, "node_modules", "cldr-units-full", "main")


def extract_units(cldr_main: str, code: str, width: str) -> dict[str, object] | None:
    """Extract duration unit patterns for a locale at a given width (short/narrow).

    Returns dict mapping unit name to pattern (str or dict of plural forms).
    Returns None if locale not found in CLDR.
    """
    # Try exact code, then base language
    candidates = [code]
    if "-" in code or "_" in code:
        candidates.append(code.split("-")[0].split("_")[0])

    units_json = None
    for candidate in candidates:
        path = os.path.join(cldr_main, candidate, "units.json")
        if os.path.exists(path):
            with open(path, encoding="utf-8") as f:
                data = json.load(f)
            # Navigate: main -> {locale} -> units -> {width}
            locale_key = list(data["main"].keys())[0]
            units_json = data["main"][locale_key]["units"].get(width)
            break

    if units_json is None:
        return None

    result = {}
    for our_name, cldr_key in CLDR_UNIT_MAP.items():
        unit_data = units_json.get(cldr_key, {})

        # Extract plural-variant patterns
        forms = {}
        for cat in PLURAL_CATS:
            key = f"unitPattern-count-{cat}"
            if key in unit_data:
                pattern = unit_data[key].replace("{0}", "{n}")
                forms[cat] = pattern

        if not forms:
            return None  # Missing unit data

        # Simplify: if all forms are identical, use a plain string
        unique_values = set(forms.values())
        if len(unique_values) == 1:
            result[our_name] = next(iter(unique_values))
        else:
            result[our_name] = forms

    return result


def is_english_shell(units: dict[str, object]) -> bool:
    """Check if extracted units are just English placeholders."""
    # If the "hour" pattern contains "hr" or "hour", it's English
    hour = units.get("hour", "")
    if isinstance(hour, dict):
        hour = hour.get("other", hour.get("one", ""))
    return "hr" in hour or "hour" in hour


def format_unit_value(val: object) -> str:
    """Format a unit value as a Python literal."""
    if isinstance(val, str):
        return repr(val)
    # Dict of plural forms
    parts = []
    for cat in PLURAL_CATS:
        if cat in val:
            parts.append(f'"{cat}": {repr(val[cat])}')
    return "{" + ", ".join(parts) + "}"


def main() -> None:
    with tempfile.TemporaryDirectory() as tmpdir:
        cldr_main = install_cldr(tmpdir)

        # Check what locales are available
        available = set(os.listdir(cldr_main))
        print(f"CLDR has {len(available)} locales")

        short_data: dict[str, dict] = {}
        narrow_data: dict[str, dict] = {}
        missing: list[str] = []
        english_shells: list[str] = []

        for code in LOCALE_CODES:
            short = extract_units(cldr_main, code, "short")
            narrow = extract_units(cldr_main, code, "narrow")

            if short is None or narrow is None:
                missing.append(code)
                continue

            if code in ENGLISH_SHELL_LOCALES or is_english_shell(short):
                english_shells.append(code)
                continue

            short_data[code] = short
            narrow_data[code] = narrow

        print(f"\nExtracted: {len(short_data)} locales")
        if missing:
            print(f"Missing from CLDR: {', '.join(missing)}")
        if english_shells:
            print(f"English shells (keeping English abbrevs): {', '.join(english_shells)}")

    # Write output
    out_path = os.path.join(os.path.dirname(__file__), "_cldr_duration_units.py")
    with open(out_path, "w", encoding="utf-8") as f:
        f.write('"""CLDR-sourced duration unit abbreviations.\n')
        f.write("\n")
        f.write("Auto-generated by _extract_cldr.py from cldr-units-full.\n")
        f.write("Do not edit by hand.\n")
        f.write("\n")
        f.write("CLDR_SHORT maps locale -> unit -> pattern (CLDR 'short' width).\n")
        f.write("CLDR_NARROW maps locale -> unit -> pattern (CLDR 'narrow' width).\n")
        f.write('"""\n\n')
        f.write("from __future__ import annotations\n\n")

        # Write short data
        f.write("CLDR_SHORT: dict[str, dict[str, object]] = {\n")
        for code in sorted(short_data.keys()):
            f.write(f'    "{code}": {{\n')
            for unit_name in ("second", "minute", "hour", "day", "week", "month", "year"):
                val = short_data[code][unit_name]
                f.write(f"        \"{unit_name}\": {format_unit_value(val)},\n")
            f.write("    },\n")
        f.write("}\n\n")

        # Write narrow data
        f.write("CLDR_NARROW: dict[str, dict[str, object]] = {\n")
        for code in sorted(narrow_data.keys()):
            f.write(f'    "{code}": {{\n')
            for unit_name in ("second", "minute", "hour", "day", "week", "month", "year"):
                val = narrow_data[code][unit_name]
                f.write(f"        \"{unit_name}\": {format_unit_value(val)},\n")
            f.write("    },\n")
        f.write("}\n\n")

        # Write the English shell list
        f.write("# Locales where CLDR has English placeholder data\n")
        f.write(f"ENGLISH_SHELLS: set[str] = {{{', '.join(repr(c) for c in sorted(english_shells))}}}\n")

    print(f"\nWrote {out_path}")


if __name__ == "__main__":
    main()
