#!/usr/bin/env python3
"""Generate locale source files for all 8 languages from canonical JSON.

Usage:
    python -m codegen.generate          # generate all
    python -m codegen.generate --check  # dry-run, exit 1 if files would change
    python -m codegen.generate --lang typescript  # generate one language only
"""

from __future__ import annotations

import argparse
import json
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
JSON_DIR = os.path.join(ROOT, "codegen", "locales")


def load_locales() -> list[dict]:
    """Load all canonical JSON locale files."""
    locales = []
    for fname in sorted(os.listdir(JSON_DIR)):
        if not fname.endswith(".json"):
            continue
        with open(os.path.join(JSON_DIR, fname), encoding="utf-8") as f:
            locales.append(json.load(f))
    return locales


def _write_or_check(path: str, content: str, check: bool, diffs: list[str]) -> None:
    """Write file or check for differences."""
    if check:
        if os.path.exists(path):
            with open(path, encoding="utf-8") as f:
                existing = f.read()
            if existing != content:
                diffs.append(path)
        else:
            diffs.append(path)
    else:
        os.makedirs(os.path.dirname(path), exist_ok=True)
        with open(path, "w", encoding="utf-8") as f:
            f.write(content)


def generate_typescript(locales: list[dict], check: bool, diffs: list[str]) -> None:
    from codegen.targets.typescript.emitter import barrel_path, emit_barrel, emit_locale, output_path

    for loc in locales:
        path = output_path(loc["code"], ROOT)
        content = emit_locale(loc)
        _write_or_check(path, content, check, diffs)

    path = barrel_path(ROOT)
    content = emit_barrel(locales)
    _write_or_check(path, content, check, diffs)


def generate_python(locales: list[dict], check: bool, diffs: list[str]) -> None:
    from codegen.targets.python.emitter import barrel_path, emit_barrel, emit_locale, output_path

    for loc in locales:
        path = output_path(loc["code"], ROOT)
        content = emit_locale(loc)
        _write_or_check(path, content, check, diffs)

    path = barrel_path(ROOT)
    content = emit_barrel(locales)
    _write_or_check(path, content, check, diffs)


def generate_go(locales: list[dict], check: bool, diffs: list[str]) -> None:
    from codegen.targets.go.emitter import emit_locale, output_path

    for loc in locales:
        path = output_path(loc["code"], ROOT)
        content = emit_locale(loc)
        _write_or_check(path, content, check, diffs)


def generate_ruby(locales: list[dict], check: bool, diffs: list[str]) -> None:
    from codegen.targets.ruby.emitter import emit_locale, output_path

    for loc in locales:
        path = output_path(loc["code"], ROOT)
        content = emit_locale(loc)
        _write_or_check(path, content, check, diffs)


def generate_rust(locales: list[dict], check: bool, diffs: list[str]) -> None:
    from codegen.targets.rust.emitter import barrel_path, emit_barrel, emit_locale, output_path

    for loc in locales:
        path = output_path(loc["code"], ROOT)
        content = emit_locale(loc)
        _write_or_check(path, content, check, diffs)

    path = barrel_path(ROOT)
    content = emit_barrel(locales)
    _write_or_check(path, content, check, diffs)


def generate_kotlin(locales: list[dict], check: bool, diffs: list[str]) -> None:
    from codegen.targets.kotlin.emitter import emit_all, output_path

    path = output_path(ROOT)
    content = emit_all(locales)
    _write_or_check(path, content, check, diffs)


def generate_cpp(locales: list[dict], check: bool, diffs: list[str]) -> None:
    from codegen.targets.cpp.emitter import emit_header, emit_source_file, header_path, source_path, split_by_range

    ranges = split_by_range(locales)
    for suffix, range_locales in ranges.items():
        path = source_path(suffix, ROOT)
        content = emit_source_file(range_locales)
        _write_or_check(path, content, check, diffs)

    path = header_path(ROOT)
    content = emit_header(locales)
    _write_or_check(path, content, check, diffs)


def generate_php(locales: list[dict], check: bool, diffs: list[str]) -> None:
    from codegen.targets.php.emitter import emit_all, output_path

    path = output_path(ROOT)
    content = emit_all(locales)
    _write_or_check(path, content, check, diffs)


_GENERATORS = {
    "typescript": generate_typescript,
    "python": generate_python,
    "go": generate_go,
    "ruby": generate_ruby,
    "rust": generate_rust,
    "kotlin": generate_kotlin,
    "cpp": generate_cpp,
    "php": generate_php,
}


def main() -> None:
    parser = argparse.ArgumentParser(description="Generate locale source files")
    parser.add_argument("--check", action="store_true",
                        help="Check files are up-to-date (exit 1 if not)")
    parser.add_argument("--lang", choices=list(_GENERATORS.keys()),
                        help="Generate only this language")
    args = parser.parse_args()

    locales = load_locales()
    print(f"Loaded {len(locales)} locales from {JSON_DIR}")

    diffs: list[str] = []
    generators = {args.lang: _GENERATORS[args.lang]} if args.lang else _GENERATORS

    for lang, gen in generators.items():
        print(f"  {'Checking' if args.check else 'Generating'} {lang}...")
        gen(locales, args.check, diffs)

    if args.check:
        if diffs:
            print(f"\n{len(diffs)} file(s) out of date:")
            for d in diffs:
                rel = os.path.relpath(d, ROOT)
                print(f"  {rel}")
            print("\nRun 'python -m codegen.generate' to update.")
            sys.exit(1)
        else:
            print("\nAll files up to date.")
    else:
        print("\nDone.")


if __name__ == "__main__":
    main()
