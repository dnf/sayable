#!/usr/bin/env python3
"""Align markdown tables so pipe delimiters line up vertically.

Usage:
    python -m codegen.align_tables FILE [FILE ...]   # align in place
    python -m codegen.align_tables --check FILE ...   # exit 1 if any file would change
"""

from __future__ import annotations

import argparse
import sys


def _is_table_line(line: str) -> bool:
    """Check if a line is part of a markdown table (starts with |)."""
    return line.startswith("|")


def _is_separator_line(line: str) -> bool:
    """Check if a line is a table separator (e.g. |---|---|)."""
    stripped = line.strip()
    if not stripped.startswith("|") or not stripped.endswith("|"):
        return False
    inner = stripped[1:-1]
    return all(c in "-| :" for c in inner)


def _split_cells(line: str) -> list[str]:
    """Split a table row into cell contents (stripping outer pipes).

    Handles escaped pipes (\\|) and pipes inside backtick spans.
    """
    stripped = line.strip()
    if stripped.startswith("|"):
        stripped = stripped[1:]
    if stripped.endswith("|"):
        stripped = stripped[:-1]

    cells: list[str] = []
    current: list[str] = []
    in_backtick = False
    i = 0
    while i < len(stripped):
        ch = stripped[i]
        if ch == "`":
            in_backtick = not in_backtick
            current.append(ch)
        elif ch == "\\" and i + 1 < len(stripped) and stripped[i + 1] == "|":
            # Escaped pipe — keep literally
            current.append("\\|")
            i += 1
        elif ch == "|" and not in_backtick:
            cells.append("".join(current).strip())
            current = []
        else:
            current.append(ch)
        i += 1
    cells.append("".join(current).strip())
    return cells


def _align_table(lines: list[str]) -> list[str]:
    """Align a block of table lines so columns have uniform width."""
    # Parse all rows into cells
    rows = [_split_cells(line) for line in lines]

    # Determine number of columns (max across all rows)
    num_cols = max(len(row) for row in rows)

    # Pad rows that have fewer columns
    for row in rows:
        while len(row) < num_cols:
            row.append("")

    # Compute max width per column (using len, sufficient for ASCII/Latin)
    col_widths = [0] * num_cols
    for i, line in enumerate(lines):
        if _is_separator_line(line):
            continue
        for j, cell in enumerate(rows[i]):
            col_widths[j] = max(col_widths[j], len(cell))

    # Ensure minimum width of 3 for separator dashes
    col_widths = [max(w, 3) for w in col_widths]

    # Rebuild each line
    result = []
    for i, line in enumerate(lines):
        cells = rows[i]
        if _is_separator_line(line):
            # Parse alignment from original separator
            orig_cells = _split_cells(line)
            parts = []
            for j in range(num_cols):
                orig = orig_cells[j].strip() if j < len(orig_cells) else "---"
                left_colon = orig.startswith(":")
                right_colon = orig.endswith(":")
                dash_width = col_widths[j]
                if left_colon and right_colon:
                    parts.append(":" + "-" * (dash_width - 2) + ":")
                elif right_colon:
                    parts.append("-" * (dash_width - 1) + ":")
                elif left_colon:
                    parts.append(":" + "-" * (dash_width - 1))
                else:
                    parts.append("-" * dash_width)
            result.append("| " + " | ".join(parts) + " |")
        else:
            parts = []
            for j in range(num_cols):
                cell = cells[j] if j < len(cells) else ""
                parts.append(cell.ljust(col_widths[j]))
            result.append("| " + " | ".join(parts) + " |")
    return result


def align_tables_in_text(text: str) -> str:
    """Find and align all markdown tables in a text string."""
    lines = text.split("\n")
    result: list[str] = []
    i = 0
    while i < len(lines):
        if _is_table_line(lines[i]):
            # Collect consecutive table lines
            table_lines: list[str] = []
            while i < len(lines) and _is_table_line(lines[i]):
                table_lines.append(lines[i])
                i += 1
            # Only align if there's a separator (it's actually a table)
            if any(_is_separator_line(line) for line in table_lines):
                result.extend(_align_table(table_lines))
            else:
                result.extend(table_lines)
        else:
            result.append(lines[i])
            i += 1
    return "\n".join(result)


def main() -> None:
    parser = argparse.ArgumentParser(description="Align markdown tables")
    parser.add_argument("files", nargs="*", help="Markdown files to align")
    parser.add_argument("--check", action="store_true",
                        help="Check alignment without modifying (exit 1 if misaligned)")
    args = parser.parse_args()

    if not args.files:
        print("No files specified.", file=sys.stderr)
        sys.exit(1)

    misaligned: list[str] = []
    for path in args.files:
        with open(path, encoding="utf-8") as f:
            original = f.read()
        aligned = align_tables_in_text(original)
        if aligned != original:
            if args.check:
                misaligned.append(path)
            else:
                with open(path, "w", encoding="utf-8") as f:
                    f.write(aligned)
                print(f"  aligned: {path}")

    if args.check:
        if misaligned:
            print(f"{len(misaligned)} file(s) have misaligned tables:")
            for p in misaligned:
                print(f"  {p}")
            sys.exit(1)
        else:
            print("All tables aligned.")


if __name__ == "__main__":
    main()
