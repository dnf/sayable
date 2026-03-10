#!/usr/bin/env python3
"""Generate locale source files for Go, Kotlin, Python, Ruby, Rust, Scala, and TypeScript from canonical JSON.

Usage:
    python -m codegen.generate                      # generate all
    python -m codegen.generate --check              # dry-run, exit 1 if files would change
    python -m codegen.generate --lang go             # generate one language only
"""

from __future__ import annotations

import argparse
import json
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
JSON_DIR = os.path.join(ROOT, "locales", "src")


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


def _remove_or_check_stale(path: str, check: bool, diffs: list[str]) -> None:
    """Remove a stale generated file, or flag it in check mode."""
    if os.path.exists(path):
        if check:
            diffs.append(path)
        else:
            os.remove(path)


def _clean_go(selected: set[str], all_codes: set[str], check: bool, diffs: list[str]) -> None:
    from codegen.targets.go.emitter import output_path
    for code in sorted(all_codes - selected):
        _remove_or_check_stale(output_path(code, ROOT), check, diffs)


def _clean_typescript(selected: set[str], all_codes: set[str], check: bool, diffs: list[str]) -> None:
    from codegen.targets.typescript.emitter import output_path
    for code in sorted(all_codes - selected):
        _remove_or_check_stale(output_path(code, ROOT), check, diffs)


def _clean_python(selected: set[str], all_codes: set[str], check: bool, diffs: list[str]) -> None:
    from codegen.targets.python.emitter import output_path
    for code in sorted(all_codes - selected):
        _remove_or_check_stale(output_path(code, ROOT), check, diffs)


def _clean_ruby(selected: set[str], all_codes: set[str], check: bool, diffs: list[str]) -> None:
    from codegen.targets.ruby.emitter import output_path
    for code in sorted(all_codes - selected):
        _remove_or_check_stale(output_path(code, ROOT), check, diffs)


def _clean_rust(selected: set[str], all_codes: set[str], check: bool, diffs: list[str]) -> None:
    from codegen.targets.rust.emitter import output_path
    for code in sorted(all_codes - selected):
        _remove_or_check_stale(output_path(code, ROOT), check, diffs)


def _clean_clojure(selected: set[str], all_codes: set[str], check: bool, diffs: list[str]) -> None:
    from codegen.targets.clojure.emitter import output_path
    for code in sorted(all_codes - selected):
        _remove_or_check_stale(output_path(code, ROOT), check, diffs)


def _clean_haskell(selected: set[str], all_codes: set[str], check: bool, diffs: list[str]) -> None:
    from codegen.targets.haskell.emitter import output_path
    for code in sorted(all_codes - selected):
        _remove_or_check_stale(output_path(code, ROOT), check, diffs)


def _clean_lua(selected: set[str], all_codes: set[str], check: bool, diffs: list[str]) -> None:
    from codegen.targets.lua.emitter import output_path
    for code in sorted(all_codes - selected):
        _remove_or_check_stale(output_path(code, ROOT), check, diffs)


def _clean_dart(selected: set[str], all_codes: set[str], check: bool, diffs: list[str]) -> None:
    from codegen.targets.dart.emitter import output_path
    for code in sorted(all_codes - selected):
        _remove_or_check_stale(output_path(code, ROOT), check, diffs)


_PER_FILE_CLEANERS = {
    "clojure": _clean_clojure,
    "dart": _clean_dart,
    "go": _clean_go,
    "haskell": _clean_haskell,
    "lua": _clean_lua,
    "python": _clean_python,
    "ruby": _clean_ruby,
    "rust": _clean_rust,
    "typescript": _clean_typescript,
}


def generate_go(locales: list[dict], check: bool, diffs: list[str]) -> None:
    from codegen.targets.go.emitter import emit_locale, emit_registry, output_path, registry_path

    for loc in locales:
        path = output_path(loc["code"], ROOT)
        content = emit_locale(loc)
        _write_or_check(path, content, check, diffs)

    path = registry_path(ROOT)
    content = emit_registry(locales)
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


def generate_typescript(locales: list[dict], check: bool, diffs: list[str]) -> None:
    from codegen.targets.typescript.emitter import barrel_path, emit_barrel, emit_locale, output_path

    for loc in locales:
        path = output_path(loc["code"], ROOT)
        content = emit_locale(loc)
        _write_or_check(path, content, check, diffs)

    path = barrel_path(ROOT)
    content = emit_barrel(locales)
    _write_or_check(path, content, check, diffs)


def generate_ruby(locales: list[dict], check: bool, diffs: list[str]) -> None:
    from codegen.targets.ruby.emitter import emit_locale, emit_registry, output_path, registry_path

    for loc in locales:
        path = output_path(loc["code"], ROOT)
        content = emit_locale(loc)
        _write_or_check(path, content, check, diffs)

    path = registry_path(ROOT)
    content = emit_registry(locales)
    _write_or_check(path, content, check, diffs)


def generate_csharp(locales: list[dict], check: bool, diffs: list[str]) -> None:
    from codegen.targets.csharp.emitter import emit_all, output_path

    path = output_path(ROOT)
    content = emit_all(locales)
    _write_or_check(path, content, check, diffs)


def generate_kotlin(locales: list[dict], check: bool, diffs: list[str]) -> None:
    from codegen.targets.kotlin.emitter import emit_all, output_path

    path = output_path(ROOT)
    content = emit_all(locales)
    _write_or_check(path, content, check, diffs)


def generate_php(locales: list[dict], check: bool, diffs: list[str]) -> None:
    from codegen.targets.php.emitter import emit_all, output_path

    path = output_path(ROOT)
    content = emit_all(locales)
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


def generate_cpp(locales: list[dict], check: bool, diffs: list[str]) -> None:
    from codegen.targets.cpp.emitter import (
        emit_header, emit_registry, emit_source_file,
        header_path, registry_source_path, source_path, split_by_range,
    )

    ranges = split_by_range(locales)
    for suffix, locs_in_range in ranges.items():
        path = source_path(suffix, ROOT)
        content = emit_source_file(locs_in_range)
        _write_or_check(path, content, check, diffs)

    path = header_path(ROOT)
    content = emit_header(locales)
    _write_or_check(path, content, check, diffs)

    path = registry_source_path(ROOT)
    content = emit_registry(locales)
    _write_or_check(path, content, check, diffs)


def generate_scala(locales: list[dict], check: bool, diffs: list[str]) -> None:
    from codegen.targets.scala.emitter import emit_all, output_path

    path = output_path(ROOT)
    content = emit_all(locales)
    _write_or_check(path, content, check, diffs)


def generate_clojure(locales: list[dict], check: bool, diffs: list[str]) -> None:
    from codegen.targets.clojure.emitter import barrel_path, emit_barrel, emit_locale, output_path

    for loc in locales:
        path = output_path(loc["code"], ROOT)
        content = emit_locale(loc)
        _write_or_check(path, content, check, diffs)

    path = barrel_path(ROOT)
    content = emit_barrel(locales)
    _write_or_check(path, content, check, diffs)


def generate_fsharp(locales: list[dict], check: bool, diffs: list[str]) -> None:
    from codegen.targets.fsharp.emitter import emit_all, output_path

    path = output_path(ROOT)
    content = emit_all(locales)
    _write_or_check(path, content, check, diffs)


def generate_lua(locales: list[dict], check: bool, diffs: list[str]) -> None:
    from codegen.targets.lua.emitter import barrel_path, emit_barrel, emit_locale, output_path

    for loc in locales:
        path = output_path(loc["code"], ROOT)
        content = emit_locale(loc)
        _write_or_check(path, content, check, diffs)

    path = barrel_path(ROOT)
    content = emit_barrel(locales)
    _write_or_check(path, content, check, diffs)


def generate_haskell(locales: list[dict], check: bool, diffs: list[str]) -> None:
    from codegen.targets.haskell.emitter import barrel_path, cabal_path, emit_barrel, emit_cabal, emit_locale, output_path

    for loc in locales:
        path = output_path(loc["code"], ROOT)
        content = emit_locale(loc)
        _write_or_check(path, content, check, diffs)

    path = barrel_path(ROOT)
    content = emit_barrel(locales)
    _write_or_check(path, content, check, diffs)

    path = cabal_path(ROOT)
    content = emit_cabal(locales)
    _write_or_check(path, content, check, diffs)


def generate_java(locales: list[dict], check: bool, diffs: list[str]) -> None:
    from codegen.targets.java.emitter import emit_all, output_path

    path = output_path(ROOT)
    content = emit_all(locales)
    _write_or_check(path, content, check, diffs)


def generate_zig(locales: list[dict], check: bool, diffs: list[str]) -> None:
    from codegen.targets.zig.emitter import emit_all, output_path

    path = output_path(ROOT)
    content = emit_all(locales)
    _write_or_check(path, content, check, diffs)


def generate_c(locales: list[dict], check: bool, diffs: list[str]) -> None:
    from codegen.targets.c.emitter import (
        emit_formatter, emit_header, emit_locale, emit_locales_header, emit_registry,
        formatter_path, header_path, locale_path, locales_header_path, registry_path,
    )

    for loc in locales:
        _write_or_check(locale_path(loc["code"], ROOT), emit_locale(loc), check, diffs)
    _write_or_check(header_path(ROOT), emit_header(locales), check, diffs)
    _write_or_check(locales_header_path(ROOT), emit_locales_header(locales), check, diffs)
    _write_or_check(registry_path(ROOT), emit_registry(locales), check, diffs)
    _write_or_check(formatter_path(ROOT), emit_formatter(), check, diffs)


def generate_dart(locales: list[dict], check: bool, diffs: list[str]) -> None:
    from codegen.targets.dart.emitter import emit_locale, emit_registry, output_path, registry_path

    for loc in locales:
        path = output_path(loc["code"], ROOT)
        content = emit_locale(loc)
        _write_or_check(path, content, check, diffs)

    path = registry_path(ROOT)
    content = emit_registry(locales)
    _write_or_check(path, content, check, diffs)



_GENERATORS = {
    "c": generate_c,
    "clojure": generate_clojure,
    "cpp": generate_cpp,
    "csharp": generate_csharp,
    "dart": generate_dart,
    "fsharp": generate_fsharp,
    "go": generate_go,
    "haskell": generate_haskell,
    "java": generate_java,
    "kotlin": generate_kotlin,
    "lua": generate_lua,
    "php": generate_php,
    "python": generate_python,
    "ruby": generate_ruby,
    "rust": generate_rust,
    "scala": generate_scala,
    "typescript": generate_typescript,
    "zig": generate_zig,
}


def main() -> None:
    parser = argparse.ArgumentParser(description="Generate locale source files")
    parser.add_argument("--check", action="store_true",
                        help="Check files are up-to-date (exit 1 if not)")
    parser.add_argument("--lang", choices=list(_GENERATORS.keys()),
                        help="Generate only this language")
    args = parser.parse_args()

    all_locales = load_locales()
    all_codes = {loc["code"] for loc in all_locales}
    print(f"Loaded {len(all_locales)} locales from {JSON_DIR}")

    diffs: list[str] = []
    generators = {args.lang: _GENERATORS[args.lang]} if args.lang else _GENERATORS

    for lang, gen in generators.items():
        print(f"  {'Checking' if args.check else 'Generating'} {lang}...")
        gen(all_locales, args.check, diffs)

    if args.check:
        if diffs:
            print(f"\n{len(diffs)} file(s) out of date:")
            for d in diffs:
                rel = os.path.relpath(d, ROOT)
                print(f"  {rel}")
            print("\nRun 'cd time && python -m codegen.generate' to update.")
            sys.exit(1)
        else:
            print("\nAll files up to date.")
    else:
        print("\nDone.")


if __name__ == "__main__":
    main()
