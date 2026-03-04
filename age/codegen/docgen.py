#!/usr/bin/env python3
"""Generate per-locale documentation showing actual formatter output.

Usage:
    python -m codegen.docgen                       # generate all
    python -m codegen.docgen --check               # dry-run, exit 1 if files would change
    python -m codegen.docgen --locale fr           # generate one locale only
    python -m codegen.docgen --locales core        # generate for a group
    python -m codegen.docgen --list-groups         # print available groups
"""

from __future__ import annotations

import argparse
import os
import sys

# Add python/src to path so we can import sayable_age
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(ROOT, "impl", "python", "src"))

from codegen.generate import _write_or_check, load_locales
from sayable_age.format_age import SayableAge
from sayable_age.locale import resolve_stage
import sayable_age.locales as locale_mod

OUTPUT_DIR = os.path.join(ROOT, "locales", "examples")

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


def _plural_categories(plural_rule: str) -> str:
    """Describe the plural categories for a rule name."""
    # Map rule names to their categories
    cats = {
        "other_only": "other",
        "one_other": "one, other",
        "one_other_zero_one": "one, other",
        "one_two_other": "one, two, other",
        "one_few_other": "one, few, other",
        "one_two_few_other": "one, two, few, other",
        "one_few_many_other": "one, few, many, other",
        "one_two_few_many_other": "one, two, few, many, other",
        "zero_one_other": "zero, one, other",
        "ar": "zero, one, two, few, many, other",
        "br": "one, two, few, many, other",
        "bs": "one, few, other",
        "cs": "one, few, many, other",
        "cy": "zero, one, two, few, many, other",
        "gd": "one, two, few, other",
        "gv": "one, two, few, many, other",
        "he": "one, two, many, other",
        "kw": "zero, one, two, few, many, other",
        "lt": "one, few, many, other",
        "lv": "zero, one, other",
        "mk": "one, other",
        "mt": "one, two, few, many, other",
        "pl": "one, few, many, other",
        "ro": "one, few, other",
        "shi": "one, few, other",
        "sl": "one, two, few, other",
        "tzm": "one, other",
    }
    return cats.get(plural_rule, plural_rule)


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


def generate_locale_doc(locale_json: dict) -> str:
    """Generate markdown documentation for one locale."""
    code = locale_json["code"]
    name = locale_json["name"]
    plural_rule = locale_json["pluralRule"]
    stages_json = locale_json["stages"]
    gendered = _is_gendered(stages_json)

    loc = _get_locale_object(code)
    pt_normal = SayableAge(loc, "normal")
    pt_short = SayableAge(loc, "short")
    pt_compact = SayableAge(loc, "compact")

    lines: list[str] = []
    lines.append(f"# {name} ({code})")
    lines.append("")
    lines.append(f"[Edit source](../src/{code}.json)")
    lines.append("")
    lines.append(f"Plural rule: `{plural_rule}` — categories: {_plural_categories(plural_rule)}")
    lines.append("")

    # Age formatting table
    lines.append("## Age formatting")
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
    lines.append("## Stages")
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
    parser = argparse.ArgumentParser(description="Generate locale documentation")
    parser.add_argument("--check", action="store_true",
                        help="Check files are up-to-date (exit 1 if not)")
    parser.add_argument("--locale",
                        help="Generate only this locale (e.g. 'fr')")
    parser.add_argument("--locales",
                        help="Comma-separated locale codes and/or group names (default: all)")
    parser.add_argument("--list-groups", action="store_true",
                        help="Print available locale groups and exit")
    args = parser.parse_args()

    if args.list_groups:
        from codegen.locale_groups import list_groups
        print(list_groups())
        return

    if args.locale and args.locales:
        print("Error: --locale and --locales are mutually exclusive", file=sys.stderr)
        sys.exit(1)

    all_locales = load_locales()

    if args.locale:
        all_locales = [loc for loc in all_locales if loc["code"] == args.locale]
        if not all_locales:
            print(f"Unknown locale: {args.locale}")
            sys.exit(1)
    elif args.locales:
        from codegen.locale_groups import resolve_locales
        all_codes = {loc["code"] for loc in all_locales}
        try:
            selected = resolve_locales(args.locales, all_codes)
        except ValueError as e:
            print(f"Error: {e}", file=sys.stderr)
            sys.exit(1)
        selected_set = set(selected)
        all_locales = [loc for loc in all_locales if loc["code"] in selected_set]

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
                rel = os.path.relpath(d, ROOT)
                print(f"  {rel}")
            print("\nRun 'python -m codegen.docgen' to update.")
            sys.exit(1)
        else:
            print("All files up to date.")
    else:
        print(f"Generated {len(all_locales)} file(s) in locales/examples/")


if __name__ == "__main__":
    main()
