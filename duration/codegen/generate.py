#!/usr/bin/env python3
"""Generate locale source files for C++, Go, Kotlin, Python, Ruby, Rust, Scala, and TypeScript from canonical JSON.

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


def _clean_crystal(selected: set[str], all_codes: set[str], check: bool, diffs: list[str]) -> None:
    from codegen.targets.crystal.emitter import output_path
    for code in sorted(all_codes - selected):
        _remove_or_check_stale(output_path(code, ROOT), check, diffs)


def _clean_dart(selected: set[str], all_codes: set[str], check: bool, diffs: list[str]) -> None:
    from codegen.targets.dart.emitter import output_path
    for code in sorted(all_codes - selected):
        _remove_or_check_stale(output_path(code, ROOT), check, diffs)


def _clean_elixir(selected: set[str], all_codes: set[str], check: bool, diffs: list[str]) -> None:
    from codegen.targets.elixir.emitter import output_path
    for code in sorted(all_codes - selected):
        _remove_or_check_stale(output_path(code, ROOT), check, diffs)


def _clean_gleam(selected: set[str], all_codes: set[str], check: bool, diffs: list[str]) -> None:
    from codegen.targets.gleam.emitter import output_path
    for code in sorted(all_codes - selected):
        _remove_or_check_stale(output_path(code, ROOT), check, diffs)


_PER_FILE_CLEANERS = {
    "clojure": _clean_clojure,
    "crystal": _clean_crystal,
    "dart": _clean_dart,
    "elixir": _clean_elixir,
    "gleam": _clean_gleam,
    "go": _clean_go,
    "haskell": _clean_haskell,
    "lua": _clean_lua,
    "python": _clean_python,
    "ruby": _clean_ruby,
    "rust": _clean_rust,
    "typescript": _clean_typescript,
}


def generate_crystal(locales: list[dict], check: bool, diffs: list[str]) -> None:
    from codegen.targets.crystal.emitter import emit_locale, emit_registry, output_path, registry_path

    for loc in locales:
        path = output_path(loc["code"], ROOT)
        content = emit_locale(loc)
        _write_or_check(path, content, check, diffs)

    path = registry_path(ROOT)
    content = emit_registry(locales)
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
    from codegen.targets.haskell.emitter import (
        barrel_path, cabal_path, emit_barrel, emit_cabal, emit_locale, output_path,
    )

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


def generate_groovy(locales: list[dict], check: bool, diffs: list[str]) -> None:
    from codegen.targets.groovy.emitter import emit_all, emit_range_files, output_path, range_path

    path = output_path(ROOT)
    content = emit_all(locales)
    _write_or_check(path, content, check, diffs)

    for suffix, range_content in emit_range_files(locales).items():
        rpath = range_path(suffix, ROOT)
        _write_or_check(rpath, range_content, check, diffs)


def generate_elixir(locales: list[dict], check: bool, diffs: list[str]) -> None:
    from codegen.targets.elixir.emitter import emit_locale, emit_registry, output_path, registry_path

    for loc in locales:
        path = output_path(loc["code"], ROOT)
        content = emit_locale(loc)
        _write_or_check(path, content, check, diffs)

    path = registry_path(ROOT)
    content = emit_registry(locales)
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


def generate_elm(locales: list[dict], check: bool, diffs: list[str]) -> None:
    from codegen.targets.elm.emitter import barrel_path, emit_barrel, emit_locale, output_path

    for loc in locales:
        path = output_path(loc["code"], ROOT)
        content = emit_locale(loc)
        _write_or_check(path, content, check, diffs)

    path = barrel_path(ROOT)
    content = emit_barrel(locales)
    _write_or_check(path, content, check, diffs)


def generate_swift(locales: list[dict], check: bool, diffs: list[str]) -> None:
    from codegen.targets.swift.emitter import emit_all, output_path

    path = output_path(ROOT)
    content = emit_all(locales)
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


def generate_cobol(locales: list[dict], check: bool, diffs: list[str]) -> None:
    from codegen.targets.cobol.emitter import emit_all, output_path

    path = output_path(ROOT)
    content = emit_all(locales)
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


def generate_r(locales: list[dict], check: bool, diffs: list[str]) -> None:
    from codegen.targets.r.emitter import barrel_path, emit_barrel, emit_locale, output_path

    for loc in locales:
        path = output_path(loc["code"], ROOT)
        content = emit_locale(loc)
        _write_or_check(path, content, check, diffs)

    path = barrel_path(ROOT)
    content = emit_barrel(locales)
    _write_or_check(path, content, check, diffs)


def _clean_r(selected: set[str], all_codes: set[str], check: bool, diffs: list[str]) -> None:
    from codegen.targets.r.emitter import output_path
    for code in sorted(all_codes - selected):
        _remove_or_check_stale(output_path(code, ROOT), check, diffs)


def generate_vbnet(locales: list[dict], check: bool, diffs: list[str]) -> None:
    from codegen.targets.vbnet.emitter import emit_all, output_path

    path = output_path(ROOT)
    content = emit_all(locales)
    _write_or_check(path, content, check, diffs)


def generate_nim(locales: list[dict], check: bool, diffs: list[str]) -> None:
    from codegen.targets.nim.emitter import emit_locale, emit_registry, output_path, registry_path

    for loc in locales:
        path = output_path(loc["code"], ROOT)
        content = emit_locale(loc)
        _write_or_check(path, content, check, diffs)

    path = registry_path(ROOT)
    content = emit_registry(locales)
    _write_or_check(path, content, check, diffs)


def _clean_nim(selected: set[str], all_codes: set[str], check: bool, diffs: list[str]) -> None:
    from codegen.targets.nim.emitter import output_path
    for code in sorted(all_codes - selected):
        _remove_or_check_stale(output_path(code, ROOT), check, diffs)


_PER_FILE_CLEANERS["r"] = _clean_r
_PER_FILE_CLEANERS["nim"] = _clean_nim


def _clean_octave(selected: set[str], all_codes: set[str], check: bool, diffs: list[str]) -> None:
    from codegen.targets.octave.emitter import output_path
    for code in sorted(all_codes - selected):
        _remove_or_check_stale(output_path(code, ROOT), check, diffs)


_PER_FILE_CLEANERS["octave"] = _clean_octave


def generate_octave(locales: list[dict], check: bool, diffs: list[str]) -> None:
    from codegen.targets.octave.emitter import barrel_path, emit_barrel, emit_locale, output_path

    for loc in locales:
        path = output_path(loc["code"], ROOT)
        content = emit_locale(loc)
        _write_or_check(path, content, check, diffs)

    path = barrel_path(ROOT)
    content = emit_barrel(locales)
    _write_or_check(path, content, check, diffs)


def _clean_janet(selected: set[str], all_codes: set[str], check: bool, diffs: list[str]) -> None:
    from codegen.targets.janet.emitter import output_path
    for code in sorted(all_codes - selected):
        _remove_or_check_stale(output_path(code, ROOT), check, diffs)


def _clean_julia(selected: set[str], all_codes: set[str], check: bool, diffs: list[str]) -> None:
    from codegen.targets.julia.emitter import output_path
    for code in sorted(all_codes - selected):
        _remove_or_check_stale(output_path(code, ROOT), check, diffs)


def _clean_lisp(selected: set[str], all_codes: set[str], check: bool, diffs: list[str]) -> None:
    from codegen.targets.lisp.emitter import output_path
    for code in sorted(all_codes - selected):
        _remove_or_check_stale(output_path(code, ROOT), check, diffs)


def _clean_prolog(selected: set[str], all_codes: set[str], check: bool, diffs: list[str]) -> None:
    from codegen.targets.prolog.emitter import output_path
    for code in sorted(all_codes - selected):
        _remove_or_check_stale(output_path(code, ROOT), check, diffs)


def _clean_racket(selected: set[str], all_codes: set[str], check: bool, diffs: list[str]) -> None:
    from codegen.targets.racket.emitter import output_path
    for code in sorted(all_codes - selected):
        _remove_or_check_stale(output_path(code, ROOT), check, diffs)


def _clean_raku(selected: set[str], all_codes: set[str], check: bool, diffs: list[str]) -> None:
    from codegen.targets.raku.emitter import output_path
    for code in sorted(all_codes - selected):
        _remove_or_check_stale(output_path(code, ROOT), check, diffs)


def _clean_tcl(selected: set[str], all_codes: set[str], check: bool, diffs: list[str]) -> None:
    from codegen.targets.tcl.emitter import output_path
    for code in sorted(all_codes - selected):
        _remove_or_check_stale(output_path(code, ROOT), check, diffs)


def _clean_v(selected: set[str], all_codes: set[str], check: bool, diffs: list[str]) -> None:
    from codegen.targets.v.emitter import output_path
    for code in sorted(all_codes - selected):
        _remove_or_check_stale(output_path(code, ROOT), check, diffs)


def _clean_wren(selected: set[str], all_codes: set[str], check: bool, diffs: list[str]) -> None:
    from codegen.targets.wren.emitter import output_path
    for code in sorted(all_codes - selected):
        _remove_or_check_stale(output_path(code, ROOT), check, diffs)


_PER_FILE_CLEANERS["janet"] = _clean_janet
_PER_FILE_CLEANERS["julia"] = _clean_julia
_PER_FILE_CLEANERS["lisp"] = _clean_lisp
_PER_FILE_CLEANERS["prolog"] = _clean_prolog
_PER_FILE_CLEANERS["racket"] = _clean_racket
_PER_FILE_CLEANERS["raku"] = _clean_raku
_PER_FILE_CLEANERS["tcl"] = _clean_tcl
_PER_FILE_CLEANERS["v"] = _clean_v
_PER_FILE_CLEANERS["wren"] = _clean_wren


def generate_julia(locales: list[dict], check: bool, diffs: list[str]) -> None:
    from codegen.targets.julia.emitter import barrel_path, emit_barrel, emit_locale, output_path

    for loc in locales:
        path = output_path(loc["code"], ROOT)
        content = emit_locale(loc)
        _write_or_check(path, content, check, diffs)

    path = barrel_path(ROOT)
    content = emit_barrel(locales)
    _write_or_check(path, content, check, diffs)


def generate_d(locales: list[dict], check: bool, diffs: list[str]) -> None:
    from codegen.targets.d.emitter import barrel_path, emit_barrel

    path = barrel_path(ROOT)
    content = emit_barrel(locales)
    _write_or_check(path, content, check, diffs)


def generate_prolog(locales: list[dict], check: bool, diffs: list[str]) -> None:
    from codegen.targets.prolog.emitter import barrel_path, emit_barrel, emit_locale, output_path

    for loc in locales:
        path = output_path(loc["code"], ROOT)
        content = emit_locale(loc)
        _write_or_check(path, content, check, diffs)

    path = barrel_path(ROOT)
    content = emit_barrel(locales)
    _write_or_check(path, content, check, diffs)


def generate_raku(locales: list[dict], check: bool, diffs: list[str]) -> None:
    from codegen.targets.raku.emitter import barrel_path, emit_barrel, emit_locale, output_path

    for loc in locales:
        path = output_path(loc["code"], ROOT)
        content = emit_locale(loc)
        _write_or_check(path, content, check, diffs)

    path = barrel_path(ROOT)
    content = emit_barrel(locales)
    _write_or_check(path, content, check, diffs)


def generate_v(locales: list[dict], check: bool, diffs: list[str]) -> None:
    from codegen.targets.v.emitter import barrel_path, emit_barrel, emit_locale, output_path

    for loc in locales:
        path = output_path(loc["code"], ROOT)
        content = emit_locale(loc)
        _write_or_check(path, content, check, diffs)

    path = barrel_path(ROOT)
    content = emit_barrel(locales)
    _write_or_check(path, content, check, diffs)


def generate_racket(locales: list[dict], check: bool, diffs: list[str]) -> None:
    from codegen.targets.racket.emitter import barrel_path, emit_barrel, emit_locale, output_path

    for loc in locales:
        path = output_path(loc["code"], ROOT)
        content = emit_locale(loc)
        _write_or_check(path, content, check, diffs)

    path = barrel_path(ROOT)
    content = emit_barrel(locales)
    _write_or_check(path, content, check, diffs)


def generate_pascal(locales: list[dict], check: bool, diffs: list[str]) -> None:
    from codegen.targets.pascal.emitter import emit_all, output_path

    path = output_path(ROOT)
    content = emit_all(locales)
    _write_or_check(path, content, check, diffs)


def generate_lisp(locales: list[dict], check: bool, diffs: list[str]) -> None:
    from codegen.targets.lisp.emitter import barrel_path, emit_barrel, emit_locale, output_path

    for loc in locales:
        path = output_path(loc["code"], ROOT)
        content = emit_locale(loc)
        _write_or_check(path, content, check, diffs)

    path = barrel_path(ROOT)
    content = emit_barrel(locales)
    _write_or_check(path, content, check, diffs)


def generate_tcl(locales: list[dict], check: bool, diffs: list[str]) -> None:
    from codegen.targets.tcl.emitter import emit_locale, emit_registry, output_path, registry_path

    for loc in locales:
        path = output_path(loc["code"], ROOT)
        content = emit_locale(loc)
        _write_or_check(path, content, check, diffs)

    path = registry_path(ROOT)
    content = emit_registry(locales)
    _write_or_check(path, content, check, diffs)


def generate_wren(locales: list[dict], check: bool, diffs: list[str]) -> None:
    from codegen.targets.wren.emitter import barrel_path, emit_barrel, emit_locale, output_path

    for loc in locales:
        path = output_path(loc["code"], ROOT)
        content = emit_locale(loc)
        _write_or_check(path, content, check, diffs)

    path = barrel_path(ROOT)
    content = emit_barrel(locales)
    _write_or_check(path, content, check, diffs)


def generate_janet(locales: list[dict], check: bool, diffs: list[str]) -> None:
    from codegen.targets.janet.emitter import emit_locale, emit_registry, output_path, registry_path

    for loc in locales:
        path = output_path(loc["code"], ROOT)
        content = emit_locale(loc)
        _write_or_check(path, content, check, diffs)

    path = registry_path(ROOT)
    content = emit_registry(locales)
    _write_or_check(path, content, check, diffs)


def generate_bash(locales: list[dict], check: bool, diffs: list[str]) -> None:
    from codegen.targets.bash.emitter import emit_locale, emit_registry, output_path, registry_path

    for loc in locales:
        path = output_path(loc["code"], ROOT)
        content = emit_locale(loc)
        _write_or_check(path, content, check, diffs)

    path = registry_path(ROOT)
    content = emit_registry(locales)
    _write_or_check(path, content, check, diffs)


def _clean_bash(selected: set[str], all_codes: set[str], check: bool, diffs: list[str]) -> None:
    from codegen.targets.bash.emitter import output_path
    for code in sorted(all_codes - selected):
        _remove_or_check_stale(output_path(code, ROOT), check, diffs)


_PER_FILE_CLEANERS["bash"] = _clean_bash


def generate_mojo(locales: list[dict], check: bool, diffs: list[str]) -> None:
    from codegen.targets.mojo.emitter import emit_locale, emit_registry, output_path, registry_path

    for loc in locales:
        path = output_path(loc["code"], ROOT)
        content = emit_locale(loc)
        _write_or_check(path, content, check, diffs)

    path = registry_path(ROOT)
    content = emit_registry(locales)
    _write_or_check(path, content, check, diffs)


def _clean_mojo(selected: set[str], all_codes: set[str], check: bool, diffs: list[str]) -> None:
    from codegen.targets.mojo.emitter import output_path
    for code in sorted(all_codes - selected):
        _remove_or_check_stale(output_path(code, ROOT), check, diffs)


_PER_FILE_CLEANERS["mojo"] = _clean_mojo


def generate_odin(locales: list[dict], check: bool, diffs: list[str]) -> None:
    from codegen.targets.odin.emitter import emit_all, output_path

    path = output_path(ROOT)
    content = emit_all(locales)
    _write_or_check(path, content, check, diffs)


def generate_pharo(locales: list[dict], check: bool, diffs: list[str]) -> None:
    from codegen.targets.pharo.emitter import emit_locale, emit_registry, output_path, registry_path

    for loc in locales:
        path = output_path(loc["code"], ROOT)
        content = emit_locale(loc)
        _write_or_check(path, content, check, diffs)

    path = registry_path(ROOT)
    content = emit_registry(locales)
    _write_or_check(path, content, check, diffs)


def _clean_pharo(selected: set[str], all_codes: set[str], check: bool, diffs: list[str]) -> None:
    from codegen.targets.pharo.emitter import output_path
    for code in sorted(all_codes - selected):
        _remove_or_check_stale(output_path(code, ROOT), check, diffs)


_PER_FILE_CLEANERS["pharo"] = _clean_pharo


def generate_powershell(locales: list[dict], check: bool, diffs: list[str]) -> None:
    from codegen.targets.powershell.emitter import emit_locale, emit_registry, output_path, registry_path

    for loc in locales:
        path = output_path(loc["code"], ROOT)
        content = emit_locale(loc)
        _write_or_check(path, content, check, diffs)

    path = registry_path(ROOT)
    content = emit_registry(locales)
    _write_or_check(path, content, check, diffs)


def _clean_powershell(selected: set[str], all_codes: set[str], check: bool, diffs: list[str]) -> None:
    from codegen.targets.powershell.emitter import output_path
    for code in sorted(all_codes - selected):
        _remove_or_check_stale(output_path(code, ROOT), check, diffs)


_PER_FILE_CLEANERS["powershell"] = _clean_powershell


_GENERATORS = {
    "ada": generate_ada,
    "bash": generate_bash,
    "c": generate_c,
    "clojure": generate_clojure,
    "cobol": generate_cobol,
    "cpp": generate_cpp,
    "crystal": generate_crystal,
    "csharp": generate_csharp,
    "d": generate_d,
    "dart": generate_dart,
    "elixir": generate_elixir,
    "elm": generate_elm,
    "erlang": generate_erlang,
    "fortran": generate_fortran,
    "fsharp": generate_fsharp,
    "gleam": generate_gleam,
    "go": generate_go,
    "groovy": generate_groovy,
    "haskell": generate_haskell,
    "janet": generate_janet,
    "java": generate_java,
    "julia": generate_julia,
    "kotlin": generate_kotlin,
    "lisp": generate_lisp,
    "lua": generate_lua,
    "mojo": generate_mojo,
    "nim": generate_nim,
    "ocaml": generate_ocaml,
    "octave": generate_octave,
    "odin": generate_odin,
    "pascal": generate_pascal,
    "perl": generate_perl,
    "pharo": generate_pharo,
    "php": generate_php,
    "powershell": generate_powershell,
    "prolog": generate_prolog,
    "python": generate_python,
    "r": generate_r,
    "racket": generate_racket,
    "raku": generate_raku,
    "ruby": generate_ruby,
    "rust": generate_rust,
    "scala": generate_scala,
    "swift": generate_swift,
    "tcl": generate_tcl,
    "typescript": generate_typescript,
    "v": generate_v,
    "vbnet": generate_vbnet,
    "wren": generate_wren,
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
            print("\nRun 'python -m codegen.generate' to update.")
            sys.exit(1)
        else:
            print("\nAll files up to date.")
    else:
        print("\nDone.")


if __name__ == "__main__":
    main()
