#!/usr/bin/env python3
"""Generate per-locale documentation showing actual time formatter output.

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
sys.path.insert(0, os.path.join(ROOT, "src", "python", "src"))

from codegen.generate import _write_or_check, load_locales
from sayable_time.format_time import SayableTime
import sayable_time.locales as locale_mod

OUTPUT_DIR = os.path.join(ROOT, "locales", "examples")

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


def generate_locale_doc(locale_json: dict) -> str:
    code = locale_json["code"]
    name = locale_json["name"]
    loc = _get_locale_object(code)

    lines: list[str] = []
    lines.append(f"# {name} ({code})")
    lines.append("")
    lines.append(f"[Edit source](../src/{code}.json)")
    lines.append("")

    # Time formatting across compactness levels
    lines.append("## Clock time formatting")
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
            print("\nRun 'cd time && python -m codegen.docgen' to update.")
            sys.exit(1)
        else:
            print("All files up to date.")
    else:
        print(f"Generated {len(all_locales)} file(s) in locales/examples/")


if __name__ == "__main__":
    main()
