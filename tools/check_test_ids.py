#!/usr/bin/env python3
"""Check that every native test suite implements every canonical test.

Each test in a native suite is annotated with the canonical ID(s) it
implements (CLAUDE.md, "Canonical test IDs"). This scans each
<library>/impl/<lang>/ test file for those annotations and reports the IDs
from <library>/config/tests.json that a suite never mentions.

A test whose notes say "where applicable" (an `undefined` input, which only
some languages have) is optional.

An ID matches when it appears with `.`, `_` or `-` between its parts
("6.12", "test_6_12", "RUN-6-12") and isn't part of a longer number. A line
that mentions the ID only to say it is skipped ("Skipped: 15.1", "TODO 15.1")
doesn't count; "<ID>: not applicable — <reason>" does.

Usage:
    python3 tools/check_test_ids.py              # report gaps, exit 1 if any
    python3 tools/check_test_ids.py --lang go    # one language
    python3 tools/check_test_ids.py --summary    # one line per suite
"""

from __future__ import annotations

import argparse
import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LIBRARIES = ("age", "date", "duration", "time")

# Generated locale code and build output never hold hand-written tests.
SKIP_DIRS = {
    "locales", "Locales", "build", "_build", "target", "node_modules", "dist", "obj", "bin",
    ".zig-cache", "zig-cache", "zig-out", "elm-stuff", "nimcache", ".gradle", "dist-newstyle",
    ".dart_tool", "out", "vendor", ".build", ".precomp", ".lake", "deps", ".deps", "test_runner",
}
TEST_PATH = re.compile(r"test|spec|(^|/)t/", re.I)
SOURCE_EXTENSIONS = {
    ".adb", ".ads", ".sh", ".c", ".h", ".cs", ".cpp", ".hpp", ".clj", ".cbl", ".lisp", ".cr", ".d",
    ".dart", ".exs", ".ex", ".elm", ".erl", ".fs", ".f90", ".gleam", ".go", ".goose", ".groovy",
    ".hs", ".janet", ".java", ".jl", ".kt", ".lua", ".mojo", ".nim", ".ml", ".m", ".odin", ".pas",
    ".t", ".pm", ".st", ".php", ".ps1", ".pl", ".py", ".R", ".r", ".rkt", ".rakutest", ".raku",
    ".rakumod", ".rb", ".rs", ".scala", ".swift", ".tcl", ".ts", ".v", ".vb", ".wren", ".zig",
}


def canonical_ids(library: str) -> list[str]:
    """The IDs every native suite must implement."""
    with open(os.path.join(ROOT, library, "config", "tests.json"), encoding="utf-8") as f:
        spec = json.load(f)
    return [test["id"] for section in spec["sections"] for test in section.get("tests", [])
            if test.get("notes") != "where applicable"]


def suite_text(impl_dir: str) -> str:
    chunks = []
    for dirpath, dirnames, filenames in os.walk(impl_dir):
        dirnames[:] = [d for d in dirnames if d not in SKIP_DIRS]
        for name in filenames:
            path = os.path.join(dirpath, name)
            rel = os.path.relpath(path, impl_dir)
            if os.path.splitext(name)[1] not in SOURCE_EXTENSIONS or not TEST_PATH.search(rel):
                continue
            with open(path, encoding="utf-8", errors="replace") as f:
                chunks.append(f.read())
    return "\n".join(chunks)


# A mention on a line like this records a missing test, not an implemented one.
NOT_IMPLEMENTED = re.compile(r"skip|todo|not implemented|unimplemented|pending|proxy", re.I)


def implemented_lines(text: str) -> str:
    return "\n".join(line for line in text.splitlines() if not NOT_IMPLEMENTED.search(line))


def id_pattern(test_id: str) -> re.Pattern:
    parts = [re.escape(p) for p in test_id.split(".")]
    return re.compile(r"(?<![\d.])" + r"[._-]".join(parts) + r"(?![\d])")


def languages() -> list[str]:
    with open(os.path.join(ROOT, ".hecatron", "config", "languages", "added.json"), encoding="utf-8") as f:
        return json.load(f)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--lang", help="check one language")
    parser.add_argument("--summary", action="store_true", help="one line per suite")
    args = parser.parse_args()

    langs = [args.lang] if args.lang else languages()
    patterns = {lib: [(tid, id_pattern(tid)) for tid in canonical_ids(lib)] for lib in LIBRARIES}
    gaps = 0
    for lang in langs:
        for lib in LIBRARIES:
            impl_dir = os.path.join(ROOT, lib, "impl", lang)
            if not os.path.isdir(impl_dir):
                print(f"{lib}/{lang}: no implementation directory")
                gaps += 1
                continue
            text = implemented_lines(suite_text(impl_dir))
            missing = [tid for tid, pat in patterns[lib] if not pat.search(text)]
            if missing:
                gaps += len(missing)
                total = len(patterns[lib])
                if args.summary:
                    print(f"{lib}/{lang}: {total - len(missing)}/{total}")
                else:
                    print(f"{lib}/{lang}: missing {len(missing)} of {total}: {', '.join(missing)}")
    if gaps:
        print(f"{gaps} canonical test(s) not implemented.", file=sys.stderr)
        return 1
    print(f"Every native suite implements every canonical test ({len(langs)} languages).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
