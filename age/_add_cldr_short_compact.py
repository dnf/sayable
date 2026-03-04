#!/usr/bin/env python3
"""Add CLDR-sourced short/compact unit overrides to age locale JSON files.

Reads CLDR short and narrow unit patterns from duration/_cldr_duration_units.py
and adds short.units and compact.units to each age locale JSON file.

For compact mode, also adds:
- compact.delimiter: "" (when normal delimiter is non-empty)
- compact.half: "{n}½" (when the normal half marker is verbose)

English-shell locales (gv, kw, shi, tzm) get English abbreviations since
CLDR has no native data for them.

Skips en (already has hand-written overrides).

Run from the repo root:
    python3 age/_add_cldr_short_compact.py
"""

from __future__ import annotations

import json
import os
import re
import sys

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
from duration._cldr_duration_units import CLDR_NARROW, CLDR_SHORT, ENGLISH_SHELLS

AGE_LOCALES = os.path.join(os.path.dirname(__file__), "locales", "src")

# Age only uses day, week, month, year (not second, minute, hour)
AGE_UNITS = ("day", "week", "month", "year")

# English abbreviations for the 4 shell locales
EN_SHORT_UNITS = {
    "day": "{n} d",
    "week": "{n} wk",
    "month": "{n} mo",
    "year": "{n} yr",
}
EN_COMPACT_UNITS = {
    "day": "{n}d",
    "week": "{n}w",
    "month": "{n}m",
    "year": "{n}y",
}


def extract_age_units(cldr_data: dict[str, object]) -> dict[str, object]:
    """Extract only age-relevant units (day, week, month, year) from CLDR data."""
    result = {}
    for unit in AGE_UNITS:
        if unit in cldr_data:
            result[unit] = cldr_data[unit]
    return result


def is_verbose_half(half: str) -> bool:
    """Check if a half marker is verbose (>2 non-placeholder chars)."""
    # Remove {0} or {n} placeholder
    stripped = re.sub(r"\{[0n]\}", "", half)
    # Count non-whitespace characters
    non_ws = stripped.replace(" ", "")
    return len(non_ws) > 2


def process_locale(filepath: str) -> bool:
    """Add short/compact overrides to a single locale JSON file.

    Returns True if the file was modified.
    """
    with open(filepath, "r", encoding="utf-8") as f:
        data = json.load(f)

    code = data["code"]

    # Skip English — already has hand-written overrides
    if code == "en":
        return False

    # Skip if already has short/compact overrides
    if "short" in data or "compact" in data:
        print(f"  {code}: already has short/compact, skipping")
        return False

    modified = False
    is_shell = code in (ENGLISH_SHELLS - {"en"})

    if is_shell:
        # English-shell locales get English abbreviations
        short_units = dict(EN_SHORT_UNITS)
        compact_units = dict(EN_COMPACT_UNITS)
    elif code in CLDR_SHORT:
        short_units = extract_age_units(CLDR_SHORT[code])
        compact_units = extract_age_units(CLDR_NARROW[code])
    else:
        print(f"  {code}: no CLDR data, skipping")
        return False

    if not short_units:
        return False

    # Build short section
    data["short"] = {"units": short_units}

    # Build compact section
    compact: dict[str, object] = {"units": compact_units}

    # Add compact.delimiter: "" when normal delimiter is non-empty
    delimiter = data.get("delimiter", "")
    if delimiter:
        compact["delimiter"] = ""

    # Add compact.half: "{n}½" when normal half is verbose
    half = data.get("half", "")
    if half and is_verbose_half(half):
        compact["half"] = "{n}½"

    data["compact"] = compact
    modified = True

    # Write back with consistent formatting
    with open(filepath, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
        f.write("\n")

    tag = "English shell" if is_shell else "CLDR"
    print(f"  {code}: added short/compact ({tag})")
    return modified


def main() -> None:
    count = 0
    for filename in sorted(os.listdir(AGE_LOCALES)):
        if not filename.endswith(".json"):
            continue
        filepath = os.path.join(AGE_LOCALES, filename)
        if process_locale(filepath):
            count += 1
    print(f"\nUpdated {count} locale files.")


if __name__ == "__main__":
    main()
