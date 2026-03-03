#!/usr/bin/env python3
"""Generate locale source files for all languages from canonical JSON.

Usage:
    python -m codegen.generate                      # generate all
    python -m codegen.generate --check              # dry-run, exit 1 if files would change
    python -m codegen.generate --lang typescript     # generate one language only
    python -m codegen.generate --locales core        # top 10 locales only
    python -m codegen.generate --locales core,ja,ko  # combine groups and codes
    python -m codegen.generate --list-groups         # print available groups
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


# --- Per-file languages: stale file cleanup helpers ---

_PER_FILE_CLEANERS: dict[str, callable] = {}


def _clean_stale_per_file(
    lang: str,
    selected_codes: set[str],
    all_codes: set[str],
    check: bool,
    diffs: list[str],
) -> None:
    """Delete (or flag) locale files for codes not in the selected set."""
    cleaner = _PER_FILE_CLEANERS.get(lang)
    if cleaner:
        cleaner(selected_codes, all_codes, check, diffs)


def _clean_typescript(selected: set[str], all_codes: set[str], check: bool, diffs: list[str]) -> None:
    from codegen.targets.typescript.emitter import output_path
    for code in sorted(all_codes - selected):
        _remove_or_check_stale(output_path(code, ROOT), check, diffs)


def _clean_python(selected: set[str], all_codes: set[str], check: bool, diffs: list[str]) -> None:
    from codegen.targets.python.emitter import output_path
    for code in sorted(all_codes - selected):
        _remove_or_check_stale(output_path(code, ROOT), check, diffs)


def _clean_go(selected: set[str], all_codes: set[str], check: bool, diffs: list[str]) -> None:
    from codegen.targets.go.emitter import output_path
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


def _clean_c(selected: set[str], all_codes: set[str], check: bool, diffs: list[str]) -> None:
    from codegen.targets.c.emitter import locale_path
    for code in sorted(all_codes - selected):
        _remove_or_check_stale(locale_path(code, ROOT), check, diffs)


def _clean_haskell(selected: set[str], all_codes: set[str], check: bool, diffs: list[str]) -> None:
    from codegen.targets.haskell.emitter import output_path
    for code in sorted(all_codes - selected):
        _remove_or_check_stale(output_path(code, ROOT), check, diffs)


def _clean_erlang(selected: set[str], all_codes: set[str], check: bool, diffs: list[str]) -> None:
    from codegen.targets.erlang.emitter import output_path
    for code in sorted(all_codes - selected):
        _remove_or_check_stale(output_path(code, ROOT), check, diffs)


def _clean_clojure(selected: set[str], all_codes: set[str], check: bool, diffs: list[str]) -> None:
    from codegen.targets.clojure.emitter import output_path
    for code in sorted(all_codes - selected):
        _remove_or_check_stale(output_path(code, ROOT), check, diffs)


def _clean_elixir(selected: set[str], all_codes: set[str], check: bool, diffs: list[str]) -> None:
    from codegen.targets.elixir.emitter import output_path
    for code in sorted(all_codes - selected):
        _remove_or_check_stale(output_path(code, ROOT), check, diffs)


def _clean_elm(selected: set[str], all_codes: set[str], check: bool, diffs: list[str]) -> None:
    from codegen.targets.elm.emitter import output_path
    for code in sorted(all_codes - selected):
        _remove_or_check_stale(output_path(code, ROOT), check, diffs)


def _clean_lua(selected: set[str], all_codes: set[str], check: bool, diffs: list[str]) -> None:
    from codegen.targets.lua.emitter import output_path
    for code in sorted(all_codes - selected):
        _remove_or_check_stale(output_path(code, ROOT), check, diffs)


def _clean_ocaml(selected: set[str], all_codes: set[str], check: bool, diffs: list[str]) -> None:
    from codegen.targets.ocaml.emitter import output_path
    for code in sorted(all_codes - selected):
        _remove_or_check_stale(output_path(code, ROOT), check, diffs)


def _clean_perl(selected: set[str], all_codes: set[str], check: bool, diffs: list[str]) -> None:
    from codegen.targets.perl.emitter import output_path
    for code in sorted(all_codes - selected):
        _remove_or_check_stale(output_path(code, ROOT), check, diffs)


def _clean_dart(selected: set[str], all_codes: set[str], check: bool, diffs: list[str]) -> None:
    from codegen.targets.dart.emitter import output_path
    for code in sorted(all_codes - selected):
        _remove_or_check_stale(output_path(code, ROOT), check, diffs)


def _clean_gleam(selected: set[str], all_codes: set[str], check: bool, diffs: list[str]) -> None:
    from codegen.targets.gleam.emitter import output_path
    for code in sorted(all_codes - selected):
        _remove_or_check_stale(output_path(code, ROOT), check, diffs)


_PER_FILE_CLEANERS = {
    "typescript": _clean_typescript,
    "python": _clean_python,
    "go": _clean_go,
    "ruby": _clean_ruby,
    "rust": _clean_rust,
    "c": _clean_c,
    "haskell": _clean_haskell,
    "erlang": _clean_erlang,
    "clojure": _clean_clojure,
    "elixir": _clean_elixir,
    "elm": _clean_elm,
    "lua": _clean_lua,
    "ocaml": _clean_ocaml,
    "perl": _clean_perl,
    "dart": _clean_dart,
    "gleam": _clean_gleam,
}


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
    from codegen.targets.go.emitter import (
        emit_helpers, emit_locale, emit_registry, helpers_path, output_path, registry_path,
    )

    for loc in locales:
        path = output_path(loc["code"], ROOT)
        content = emit_locale(loc)
        _write_or_check(path, content, check, diffs)

    path = registry_path(ROOT)
    content = emit_registry(locales)
    _write_or_check(path, content, check, diffs)

    path = helpers_path(ROOT)
    content = emit_helpers()
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
    from codegen.targets.cpp.emitter import (
        emit_header, emit_registry, emit_source_file, header_path,
        registry_source_path, source_path, split_by_range,
    )

    ranges = split_by_range(locales)
    for suffix, range_locales in ranges.items():
        path = source_path(suffix, ROOT)
        content = emit_source_file(range_locales)
        _write_or_check(path, content, check, diffs)

    path = header_path(ROOT)
    content = emit_header(locales)
    _write_or_check(path, content, check, diffs)

    path = registry_source_path(ROOT)
    content = emit_registry(locales)
    _write_or_check(path, content, check, diffs)


def generate_php(locales: list[dict], check: bool, diffs: list[str]) -> None:
    from codegen.targets.php.emitter import emit_all, output_path

    path = output_path(ROOT)
    content = emit_all(locales)
    _write_or_check(path, content, check, diffs)


def generate_java(locales: list[dict], check: bool, diffs: list[str]) -> None:
    from codegen.targets.java.emitter import emit_all, output_path

    path = output_path(ROOT)
    content = emit_all(locales)
    _write_or_check(path, content, check, diffs)


def generate_csharp(locales: list[dict], check: bool, diffs: list[str]) -> None:
    from codegen.targets.csharp.emitter import emit_all, output_path

    path = output_path(ROOT)
    content = emit_all(locales)
    _write_or_check(path, content, check, diffs)


def generate_swift(locales: list[dict], check: bool, diffs: list[str]) -> None:
    from codegen.targets.swift.emitter import emit_all, output_path

    path = output_path(ROOT)
    content = emit_all(locales)
    _write_or_check(path, content, check, diffs)


def generate_haskell(locales: list[dict], check: bool, diffs: list[str]) -> None:
    from codegen.targets.haskell.emitter import barrel_path, emit_barrel, emit_locale, output_path

    for loc in locales:
        path = output_path(loc["code"], ROOT)
        content = emit_locale(loc)
        _write_or_check(path, content, check, diffs)

    path = barrel_path(ROOT)
    content = emit_barrel(locales)
    _write_or_check(path, content, check, diffs)


def generate_erlang(locales: list[dict], check: bool, diffs: list[str]) -> None:
    from codegen.targets.erlang.emitter import barrel_path, emit_barrel, emit_locale, output_path

    for loc in locales:
        path = output_path(loc["code"], ROOT)
        content = emit_locale(loc)
        _write_or_check(path, content, check, diffs)

    path = barrel_path(ROOT)
    content = emit_barrel(locales)
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


def generate_c(locales: list[dict], check: bool, diffs: list[str]) -> None:
    from codegen.targets.c.emitter import (
        emit_formatter, emit_header, emit_locale, emit_locales_header,
        emit_registry, formatter_path, header_path, locale_path,
        locales_header_path, registry_path,
    )

    for loc in locales:
        path = locale_path(loc["code"], ROOT)
        content = emit_locale(loc)
        _write_or_check(path, content, check, diffs)

    _write_or_check(header_path(ROOT), emit_header(locales), check, diffs)
    _write_or_check(locales_header_path(ROOT), emit_locales_header(locales), check, diffs)
    _write_or_check(registry_path(ROOT), emit_registry(locales), check, diffs)
    _write_or_check(formatter_path(ROOT), emit_formatter(), check, diffs)


def generate_scala(locales: list[dict], check: bool, diffs: list[str]) -> None:
    from codegen.targets.scala.emitter import emit_all, output_path

    path = output_path(ROOT)
    content = emit_all(locales)
    _write_or_check(path, content, check, diffs)


def generate_elm(locales: list[dict], check: bool, diffs: list[str]) -> None:
    from codegen.targets.elm.emitter import barrel_path, emit_barrel, emit_locale, output_path

    for loc in locales:
        path = output_path(loc["code"], ROOT)
        content = emit_locale(loc)
        _write_or_check(path, content, check, diffs)

    path = barrel_path(ROOT)
    content = emit_barrel(locales)
    _write_or_check(path, content, check, diffs)


def generate_elixir(locales: list[dict], check: bool, diffs: list[str]) -> None:
    from codegen.targets.elixir.emitter import emit_locale, emit_registry, output_path, registry_path

    for loc in locales:
        path = output_path(loc["code"], ROOT)
        content = emit_locale(loc)
        _write_or_check(path, content, check, diffs)

    path = registry_path(ROOT)
    content = emit_registry(locales)
    _write_or_check(path, content, check, diffs)


def generate_gleam(locales: list[dict], check: bool, diffs: list[str]) -> None:
    from codegen.targets.gleam.emitter import emit_locale, emit_registry, output_path, registry_path

    for loc in locales:
        path = output_path(loc["code"], ROOT)
        content = emit_locale(loc)
        _write_or_check(path, content, check, diffs)

    path = registry_path(ROOT)
    content = emit_registry(locales)
    _write_or_check(path, content, check, diffs)


def generate_dart(locales: list[dict], check: bool, diffs: list[str]) -> None:
    from codegen.targets.dart.emitter import emit_locale, emit_registry, output_path, registry_path

    for loc in locales:
        path = output_path(loc["code"], ROOT)
        content = emit_locale(loc)
        _write_or_check(path, content, check, diffs)

    path = registry_path(ROOT)
    content = emit_registry(locales)
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


def generate_ocaml(locales: list[dict], check: bool, diffs: list[str]) -> None:
    from codegen.targets.ocaml.emitter import barrel_path, emit_barrel, emit_locale, output_path

    for loc in locales:
        path = output_path(loc["code"], ROOT)
        content = emit_locale(loc)
        _write_or_check(path, content, check, diffs)

    path = barrel_path(ROOT)
    content = emit_barrel(locales)
    _write_or_check(path, content, check, diffs)


def generate_fortran(locales: list[dict], check: bool, diffs: list[str]) -> None:
    from codegen.targets.fortran.emitter import emit_all, output_path

    path = output_path(ROOT)
    content = emit_all(locales)
    _write_or_check(path, content, check, diffs)


def generate_perl(locales: list[dict], check: bool, diffs: list[str]) -> None:
    from codegen.targets.perl.emitter import emit_locale, emit_registry, output_path, registry_path

    for loc in locales:
        path = output_path(loc["code"], ROOT)
        content = emit_locale(loc)
        _write_or_check(path, content, check, diffs)

    path = registry_path(ROOT)
    content = emit_registry(locales)
    _write_or_check(path, content, check, diffs)


def generate_ada(locales: list[dict], check: bool, diffs: list[str]) -> None:
    from codegen.targets.ada.emitter import body_path, emit_body, emit_spec, spec_path

    path = spec_path(ROOT)
    content = emit_spec(locales)
    _write_or_check(path, content, check, diffs)

    path = body_path(ROOT)
    content = emit_body(locales)
    _write_or_check(path, content, check, diffs)


def generate_groovy(locales: list[dict], check: bool, diffs: list[str]) -> None:
    from codegen.targets.groovy.emitter import emit_all, output_path

    path = output_path(ROOT)
    content = emit_all(locales)
    _write_or_check(path, content, check, diffs)


def generate_zig(locales: list[dict], check: bool, diffs: list[str]) -> None:
    from codegen.targets.zig.emitter import emit_all, output_path

    path = output_path(ROOT)
    content = emit_all(locales)
    _write_or_check(path, content, check, diffs)


_GENERATORS = {
    "ada": generate_ada,
    "typescript": generate_typescript,
    "python": generate_python,
    "go": generate_go,
    "ruby": generate_ruby,
    "rust": generate_rust,
    "kotlin": generate_kotlin,
    "cpp": generate_cpp,
    "php": generate_php,
    "java": generate_java,
    "csharp": generate_csharp,
    "swift": generate_swift,
    "c": generate_c,
    "haskell": generate_haskell,
    "erlang": generate_erlang,
    "fsharp": generate_fsharp,
    "clojure": generate_clojure,
    "scala": generate_scala,
    "zig": generate_zig,
    "elixir": generate_elixir,
    "elm": generate_elm,
    "fortran": generate_fortran,
    "lua": generate_lua,
    "ocaml": generate_ocaml,
    "perl": generate_perl,
    "dart": generate_dart,
    "gleam": generate_gleam,
    "groovy": generate_groovy,
}


def main() -> None:
    parser = argparse.ArgumentParser(description="Generate locale source files")
    parser.add_argument("--check", action="store_true",
                        help="Check files are up-to-date (exit 1 if not)")
    parser.add_argument("--lang", choices=list(_GENERATORS.keys()),
                        help="Generate only this language")
    parser.add_argument("--locales",
                        help="Comma-separated locale codes and/or group names (default: all)")
    parser.add_argument("--list-groups", action="store_true",
                        help="Print available locale groups and exit")
    args = parser.parse_args()

    if args.list_groups:
        from codegen.locale_groups import list_groups
        print(list_groups())
        return

    all_locales = load_locales()
    all_codes = {loc["code"] for loc in all_locales}

    if args.locales:
        from codegen.locale_groups import GROUPS, REQUIRED_LOCALES, resolve_locales
        try:
            selected = resolve_locales(args.locales, all_codes)
        except ValueError as e:
            print(f"Error: {e}", file=sys.stderr)
            sys.exit(1)
        selected_set = set(selected)
        # Check if en was only added by REQUIRED_LOCALES (not explicit or via group)
        explicit_codes: set[str] = set()
        for token in args.locales.split(","):
            token = token.strip()
            if token in GROUPS:
                explicit_codes.update(GROUPS[token])
            elif token in all_codes:
                explicit_codes.add(token)
        if REQUIRED_LOCALES - explicit_codes:
            print("Note: 'en' auto-included (required fallback locale)")
        all_locales = [loc for loc in all_locales if loc["code"] in selected_set]
        print(f"Selected {len(all_locales)} of {len(all_codes)} locales: {', '.join(selected)}")
    else:
        selected_set = None
        print(f"Loaded {len(all_locales)} locales from {JSON_DIR}")

    diffs: list[str] = []
    generators = {args.lang: _GENERATORS[args.lang]} if args.lang else _GENERATORS

    for lang, gen in generators.items():
        print(f"  {'Checking' if args.check else 'Generating'} {lang}...")
        gen(all_locales, args.check, diffs)
        if selected_set is not None:
            _clean_stale_per_file(lang, selected_set, all_codes, args.check, diffs)

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
