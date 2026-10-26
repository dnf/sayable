#!/usr/bin/env python3
"""Check that every language's CI workflow tests every component it implements.

A language that has `<component>/impl/<lang>/` must have a step in
`.hecatron/languages/<lang>/workflow.yml` that runs in (or names) that
directory. Without this check a library can drift with no native tests in
CI: until October 2026 only the age suites ran, and Prolog's CI pointed
at a test file that didn't exist.

Usage:
    python3 tools/check_workflow_components.py
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
COMPONENTS = ("age", "date", "duration", "time")


def missing_components(lang: str) -> list[str]:
    workflow = (ROOT / ".hecatron" / "languages" / lang / "workflow.yml").read_text()
    # A matrix over components (as Goose's workflow does) covers them all.
    matrix_covers_all = "${{ matrix.component }}/impl/" + lang in workflow and all(
        c in workflow for c in COMPONENTS)
    if matrix_covers_all:
        return []
    return [c for c in COMPONENTS
            if (ROOT / c / "impl" / lang).is_dir() and f"{c}/impl/{lang}" not in workflow]


def main() -> int:
    added = json.loads((ROOT / ".hecatron" / "config" / "languages" / "added.json").read_text())
    gaps = {lang: missing for lang in added if (missing := missing_components(lang))}
    for lang, missing in sorted(gaps.items()):
        print(f"{lang}: workflow doesn't test {', '.join(missing)} "
              f"(.hecatron/languages/{lang}/workflow.yml)")
    if gaps:
        print(f"\n{len(gaps)} language workflow(s) skip components they implement", file=sys.stderr)
        return 1
    print(f"All {len(added)} language workflows test every component they implement.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
