#!/usr/bin/env python3
"""Generate per-locale documentation showing actual date formatter output.

Usage:
    python -m codegen.docgen                       # generate all
    python -m codegen.docgen --check               # dry-run, exit 1 if files would change
    python -m codegen.docgen --locale fr           # generate one locale only
"""

from __future__ import annotations

import argparse
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(ROOT, "impl", "python", "src"))

from codegen.generate import _write_or_check, load_locales
from sayable_date.format_date import SayableDate
import sayable_date.locales as locale_mod

OUTPUT_DIR = os.path.join(ROOT, "locales", "examples")

# format_date examples: (label, date)
_DATE_EXAMPLES: list[tuple[str, str]] = [
    ("January 1", "2025-01-01"),
    ("February 14", "2025-02-14"),
    ("March 15", "2025-03-15"),
    ("July 4", "2025-07-04"),
    ("October 31", "2025-10-31"),
    ("December 25", "2025-12-25"),
]

# format_relative examples: (label, date, as_of)
_RELATIVE_EXAMPLES: list[tuple[str, str, str]] = [
    ("Today", "2025-03-15", "2025-03-15"),
    ("Tomorrow", "2025-03-16", "2025-03-15"),
    ("Yesterday", "2025-03-14", "2025-03-15"),
    ("Day after tomorrow", "2025-03-17", "2025-03-15"),
    ("Day before yesterday", "2025-03-13", "2025-03-15"),
    ("This Thursday (+5)", "2025-03-20", "2025-03-15"),
    ("Last Monday (-4)", "2025-03-11", "2025-03-15"),
    ("Next Wednesday (+12)", "2025-03-27", "2025-03-15"),
    ("Same month (+20)", "2025-04-04", "2025-03-15"),
    ("Different year", "2026-01-10", "2025-03-15"),
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


def generate_locale_doc(locale_json: dict) -> str:
    code = locale_json["code"]
    name = locale_json["name"]
    loc = _get_locale_object(code)

    lines: list[str] = []
    lines.append(f"# {name} ({code})")
    lines.append("")
    lines.append(f"[Edit source](../src/{code}.json)")
    lines.append("")

    # format_date across compactness levels
    lines.append("## Date formatting")
    lines.append("")
    sd_normal = SayableDate(loc, "normal")
    sd_short = SayableDate(loc, "short")
    sd_compact = SayableDate(loc, "compact")

    rows: list[list[str]] = []
    for label, date in _DATE_EXAMPLES:
        rows.append([
            label,
            sd_normal.format_date(date) or "",
            sd_short.format_date(date) or "",
            sd_compact.format_date(date) or "",
        ])
    lines.extend(_aligned_table(["Date", "Normal", "Short", "Compact"], rows))
    lines.append("")

    # format_relative
    lines.append("## Relative dates")
    lines.append("")
    lines.append("Relative to Saturday, March 15, 2025.")
    lines.append("")
    rows = []
    for label, date, as_of in _RELATIVE_EXAMPLES:
        normal = sd_normal.format_relative(date, as_of=as_of) or ""
        compact = sd_compact.format_relative(date, as_of=as_of) or ""
        rows.append([label, normal, compact])
    lines.extend(_aligned_table(["Offset", "Normal", "Compact"], rows))

    lines.append("")
    return "\n".join(lines)


def main() -> None:
    parser = argparse.ArgumentParser(description="Generate locale documentation")
    parser.add_argument("--check", action="store_true",
                        help="Check files are up-to-date (exit 1 if not)")
    parser.add_argument("--locale",
                        help="Generate only this locale (e.g. 'fr')")
    args = parser.parse_args()

    all_locales = load_locales()

    if args.locale:
        all_locales = [loc for loc in all_locales if loc["code"] == args.locale]
        if not all_locales:
            print(f"Unknown locale: {args.locale}")
            sys.exit(1)

    print(f"{'Checking' if args.check else 'Generating'} docs for {len(all_locales)} locale(s)...")

    diffs: list[str] = []
    for locale_json in all_locales:
        code = locale_json["code"]
        content = generate_locale_doc(locale_json)
        path = os.path.join(OUTPUT_DIR, f"{code}.md")
        _write_or_check(path, content, args.check, diffs)

    if args.check:
        if diffs:
            print(f"\n{len(diffs)} file(s) out of date:")
            for d in diffs:
                print(f"  {os.path.relpath(d, ROOT)}")
            print("\nRun 'cd date && python -m codegen.docgen' to update.")
            sys.exit(1)
        else:
            print("All files up to date.")
    else:
        print(f"Generated {len(all_locales)} file(s) in locales/examples/")


if __name__ == "__main__":
    main()
