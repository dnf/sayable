#!/usr/bin/env python3
"""Generate per-locale documentation showing actual time formatter output.

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
from sayable_time.format_time import SayableTime
import sayable_time.locales as locale_mod


# Time examples: (label, time)
_TIME_EXAMPLES: list[tuple[str, str]] = [
    ("Midnight", "00:00"),
    ("1:00 AM", "01:00"),
    ("5 past 9", "09:05"),
    ("Quarter past 10", "10:15"),
    ("Half past 11", "11:30"),
    ("Noon", "12:00"),
    ("Quarter to 3", "14:45"),
    ("5 to 6", "17:55"),
    ("8 o'clock PM", "20:00"),
    ("10:30 PM", "22:30"),
    ("11:58 PM", "23:58"),
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
    """Markdown for one locale's time examples, a section of docs/locales/<code>.md."""
    code = locale_json["code"]
    loc = _get_locale_object(code)

    lines: list[str] = []

    # Time formatting across compactness levels
    lines.append("### Clock time formatting")
    lines.append("")
    st_normal = SayableTime(loc, "normal")
    st_short = SayableTime(loc, "short")
    st_compact = SayableTime(loc, "compact")

    rows: list[list[str]] = []
    for label, time_str in _TIME_EXAMPLES:
        rows.append([
            label,
            st_normal.format_time(time_str) or "",
            st_short.format_time(time_str) or "",
            st_compact.format_time(time_str) or "",
        ])
    lines.extend(_aligned_table(["Time", "Normal", "Short", "Compact"], rows))

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
