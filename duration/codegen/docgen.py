#!/usr/bin/env python3
"""Generate per-locale documentation showing actual duration formatter output.

Usage (run by tools/generate_locale_docs.py, which writes docs/locales/<code>.md):
    python -m codegen.docgen --sections     # print {code: markdown} for every locale as JSON
"""

from __future__ import annotations

import argparse
import json
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(ROOT, "impl", "python", "src"))

from codegen.generate import load_locales
from sayable_duration.format_duration import SayableDuration
import sayable_duration.locales as locale_mod


# Duration examples: (label, seconds)
_DURATION_EXAMPLES: list[tuple[str, int]] = [
    ("0 seconds", 0),
    ("1 second", 1),
    ("30 seconds", 30),
    ("1 minute", 60),
    ("2 minutes, 15 seconds", 135),
    ("5 minutes", 300),
    ("45 minutes", 2700),
    ("1 hour", 3600),
    ("1½ hours", 5400),
    ("3 hours", 10800),
    ("6 hours", 21600),
    ("1 day", 86400),
    ("1½ days", 129600),
    ("3 days", 259200),
    ("1 week", 604800),
    ("2 weeks, 3 days", 1468800),
    ("1 month", 2629800),
    ("6 months", 15778800),
    ("1 year", 31557600),
    ("2 years, 3 months", 71020800),
]

# Relative time examples: (label, start_iso, as_of_iso, is_since)
_RELATIVE_EXAMPLES: list[tuple[str, str, str, bool]] = [
    ("5 minutes ago", "2025-03-15T10:00:00", "2025-03-15T10:05:00", True),
    ("2 hours ago", "2025-03-15T08:00:00", "2025-03-15T10:00:00", True),
    ("in 30 minutes", "2025-03-15T10:30:00", "2025-03-15T10:00:00", False),
    ("in 3 hours", "2025-03-15T13:00:00", "2025-03-15T10:00:00", False),
]


def _get_locale_object(code: str):
    attr = code.upper()
    return getattr(locale_mod, attr)


def _aligned_table(headers: list[str], rows: list[list[str]]) -> list[str]:
    num_cols = len(headers)
    col_widths = [len(h) for h in headers]
    for row in rows:
        for j in range(num_cols):
            col_widths[j] = max(col_widths[j], len(row[j]))
    col_widths = [max(w, 3) for w in col_widths]
    lines: list[str] = []
    lines.append("| " + " | ".join(h.ljust(col_widths[j]) for j, h in enumerate(headers)) + " |")
    lines.append("| " + " | ".join("-" * w for w in col_widths) + " |")
    for row in rows:
        lines.append("| " + " | ".join(row[j].ljust(col_widths[j]) for j in range(num_cols)) + " |")
    return lines


def generate_locale_section(locale_json: dict) -> str:
    """Markdown for one locale's duration examples, a section of docs/locales/<code>.md."""
    code = locale_json["code"]
    loc = _get_locale_object(code)

    lines: list[str] = []

    # Duration formatting across compactness levels
    lines.append("### Duration formatting")
    lines.append("")
    sd_normal = SayableDuration(loc, "normal")
    sd_short = SayableDuration(loc, "short")
    sd_compact = SayableDuration(loc, "compact")

    rows: list[list[str]] = []
    for label, seconds in _DURATION_EXAMPLES:
        rows.append([
            label,
            sd_normal.format_duration(seconds) or "",
            sd_short.format_duration(seconds) or "",
            sd_compact.format_duration(seconds) or "",
        ])
    lines.extend(_aligned_table(["Duration", "Normal", "Short", "Compact"], rows))
    lines.append("")

    # Relative time (since / until)
    lines.append("### Relative time")
    lines.append("")
    rows = []
    for label, target, as_of, is_since in _RELATIVE_EXAMPLES:
        if is_since:
            normal = sd_normal.format_since(target, as_of) or ""
            compact = sd_compact.format_since(target, as_of) or ""
        else:
            normal = sd_normal.format_until(target, as_of) or ""
            compact = sd_compact.format_until(target, as_of) or ""
        rows.append([label, normal, compact])
    lines.extend(_aligned_table(["Offset", "Normal", "Compact"], rows))

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
