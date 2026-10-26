#!/usr/bin/env python3
"""Generate per-locale documentation showing actual formatter output.

Usage (run by tools/generate_locale_docs.py, which writes docs/locales/<code>.md):
    python -m codegen.docgen --sections     # print {code: markdown} for every locale as JSON
"""

from __future__ import annotations

import argparse
import json
import os
import sys

# Add python/src to path so we can import sayable_age
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(ROOT, "impl", "python", "src"))

from codegen.generate import load_locales
from sayable_age.format_age import SayableAge
import sayable_age.locales as locale_mod


# Age formatting date pairs: (label, dob, asOf)
_AGE_PAIRS: list[tuple[str, str, str]] = [
    ("Born today", "2025-03-15", "2025-03-15"),
    ("1 day", "2025-03-14", "2025-03-15"),
    ("3 days", "2025-03-12", "2025-03-15"),
    ("6 days", "2025-03-09", "2025-03-15"),
    ("1 week", "2025-03-08", "2025-03-15"),
    ("1 week, 1 day", "2025-03-07", "2025-03-15"),
    ("2 weeks", "2025-03-01", "2025-03-15"),
    ("2 weeks, 3 days", "2025-02-26", "2025-03-15"),
    ("3 months", "2024-12-15", "2025-03-15"),
    ("6 months", "2024-09-15", "2025-03-15"),
    ("11 months", "2024-04-15", "2025-03-15"),
    ("12 months", "2024-03-15", "2025-03-15"),
    ("23 months", "2023-04-15", "2025-03-15"),
    ("2 years", "2023-03-15", "2025-03-15"),
    ("2 years, 1 month", "2023-03-15", "2025-04-15"),
    ("2 years, 6 months", "2023-03-15", "2025-09-15"),
    ("3 years", "2022-03-15", "2025-03-15"),
    ("3½ years", "2022-03-15", "2025-09-15"),
    ("5 years", "2020-03-15", "2025-03-15"),
    ("5½ years", "2020-03-15", "2025-09-15"),
    ("7 years", "2018-03-15", "2025-03-15"),
    ("10 years", "2015-03-15", "2025-03-15"),
    ("18 years", "2007-03-15", "2025-03-15"),
    ("45 years", "1980-03-15", "2025-03-15"),
]

# Stage date pairs: (stage_name, dob, asOf)
_STAGE_PAIRS: list[tuple[str, str, str]] = [
    ("Newborn", "2025-03-15", "2025-03-15"),
    ("Infant", "2024-09-15", "2025-03-15"),
    ("Toddler", "2023-09-15", "2025-03-15"),
    ("Child", "2019-03-15", "2025-03-15"),
    ("Teenager", "2011-03-15", "2025-03-15"),
    ("Adult", "2000-03-15", "2025-03-15"),
]

_STAGE_KEYS = ["newborn", "infant", "toddler", "child", "teenager", "adult"]


def _get_locale_object(code: str):
    """Get the Python locale object by code (e.g. 'fr' -> FR)."""
    attr = code.upper()
    return getattr(locale_mod, attr)


def _is_gendered(stages: dict) -> bool:
    """Check if any stage label in the JSON is gendered (dict with m/f)."""
    return any(isinstance(v, dict) for v in stages.values())


def _aligned_table(headers: list[str], rows: list[list[str]]) -> list[str]:
    """Build an aligned markdown table from headers and rows."""
    num_cols = len(headers)
    col_widths = [len(h) for h in headers]
    for row in rows:
        for j in range(num_cols):
            col_widths[j] = max(col_widths[j], len(row[j]))
    # Minimum width of 3 for separator dashes
    col_widths = [max(w, 3) for w in col_widths]

    lines: list[str] = []
    lines.append("| " + " | ".join(h.ljust(col_widths[j]) for j, h in enumerate(headers)) + " |")
    lines.append("| " + " | ".join("-" * w for w in col_widths) + " |")
    for row in rows:
        lines.append("| " + " | ".join(row[j].ljust(col_widths[j]) for j in range(num_cols)) + " |")
    return lines


def generate_locale_section(locale_json: dict) -> str:
    """Markdown for one locale's age examples, a section of docs/locales/<code>.md."""
    code = locale_json["code"]
    stages_json = locale_json["stages"]
    gendered = _is_gendered(stages_json)

    loc = _get_locale_object(code)
    pt_normal = SayableAge(loc, "normal")
    pt_short = SayableAge(loc, "short")
    pt_compact = SayableAge(loc, "compact")

    lines: list[str] = []

    # Age formatting table
    lines.append("### Age formatting")
    lines.append("")
    age_rows: list[list[str]] = []
    for label, dob, as_of in _AGE_PAIRS:
        age_rows.append([
            label,
            pt_normal.format_age(dob, as_of),
            pt_short.format_age(dob, as_of),
            pt_compact.format_age(dob, as_of),
        ])
    lines.extend(_aligned_table(["Age", "Normal", "Short", "Compact"], age_rows))
    lines.append("")

    # Stages table
    lines.append("### Stages")
    lines.append("")
    stage_rows: list[list[str]] = []
    if gendered:
        for stage_name, dob, as_of in _STAGE_PAIRS:
            stage_m = pt_normal.format_stage(dob, as_of, "m")
            stage_f = pt_normal.format_stage(dob, as_of, "f")
            if stage_m == stage_f:
                stage_rows.append([stage_name, stage_m])
            else:
                stage_rows.append([stage_name, f"{stage_m} / {stage_f}"])
    else:
        for stage_name, dob, as_of in _STAGE_PAIRS:
            stage_label = pt_normal.format_stage(dob, as_of)
            stage_rows.append([stage_name, stage_label])
    lines.extend(_aligned_table(["Stage", "Label"], stage_rows))

    lines.append("")
    return "\n".join(lines)


def main() -> None:
    """Print every locale's section as JSON, for tools/generate_locale_docs.py."""
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--sections", action="store_true", required=True,
                        help="print {code: markdown} for every locale as JSON")
    parser.parse_args()
    sections = {loc["code"]: generate_locale_section(loc) for loc in load_locales()}
    json.dump(sections, sys.stdout, ensure_ascii=False)


if __name__ == "__main__":
    main()
