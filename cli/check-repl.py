#!/usr/bin/env python3
"""Check that a sayable CLI's `--repl` mode follows cli/SPEC.md.

Sends one request at a time and waits for its response, so a REPL that
does not flush after each line fails with a timeout instead of passing
by accident when its output is flushed at exit.

Usage:
    python3 cli/check-repl.py cli/impl/<lang>/sayable
"""

from __future__ import annotations

import os
import selectors
import subprocess
import sys

TIMEOUT_SECONDS = 60  # generous: the first request may trigger a JIT or a build

CHECKS = [
    # (description, request fields, expected exit, expected output or None for "any")
    ("age", ["age", "2020-06-15", "-d", "2025-06-15"], 0, "5 years"),
    ("null result", ["age", "null", "-d", "2025-06-15"], 1, ""),
    ("empty-string argument", ["age", "", "-d", "2025-06-15"], 1, ""),
    ("locale and compactness", ["age", "2020-06-15", "-d", "2025-06-15", "--compact", "-l", "fr"], 0, "5a"),
    ("usage error keeps serving", ["bogus"], 2, ""),
    ("blank line", [""], 2, None),
    ("unknown locale", ["age", "2020-06-15", "-d", "2025-06-15", "-l", "xx"], 2, ""),
    ("version", ["version"], 0, "sayable 0.5.0"),
    ("still alive", ["age", "2025-06-14", "-d", "2025-06-15"], 0, "1 day"),
]


def read_line(proc: subprocess.Popen, sel: selectors.BaseSelector) -> str | None:
    buf = b""
    while not buf.endswith(b"\n"):
        if not sel.select(TIMEOUT_SECONDS):
            return None
        chunk = os.read(proc.stdout.fileno(), 65536)
        if not chunk:
            return None
        buf += chunk
    return buf.decode("utf-8")


def main() -> int:
    if len(sys.argv) != 2:
        print(__doc__, file=sys.stderr)
        return 2
    proc = subprocess.Popen([sys.argv[1], "--repl"], stdin=subprocess.PIPE,
                            stdout=subprocess.PIPE, stderr=subprocess.DEVNULL)
    sel = selectors.DefaultSelector()
    sel.register(proc.stdout, selectors.EVENT_READ)
    failures = 0

    def exchange(fields: list[str]) -> tuple[str, str] | None:
        proc.stdin.write(("\t".join(fields) + "\n").encode("utf-8"))
        proc.stdin.flush()
        line = read_line(proc, sel)
        if line is None or "\t" not in line:
            return None
        code, _, output = line.rstrip("\n").partition("\t")
        return code, output

    for desc, fields, want_code, want_output in CHECKS:
        got = exchange(fields)
        if got is None:
            print(f"FAIL {desc}: no response line within {TIMEOUT_SECONDS}s (not flushed, crashed, or malformed)")
            failures += 1
            break
        code, output = got
        if code != str(want_code) or (want_output is not None and output != want_output):
            print(f"FAIL {desc}: got {code!r} {output!r}, want {str(want_code)!r} {want_output!r}")
            failures += 1

    if failures == 0:
        got = exchange(["locales"])
        codes = got[1].split("\t") if got else []
        if not got or got[0] != "0" or "en" not in codes or len(codes) < 100:
            print(f"FAIL locales: want exit 0 and the codes joined by tabs, got {got!r:.120}")
            failures += 1

    proc.stdin.close()
    try:
        rc = proc.wait(timeout=TIMEOUT_SECONDS)
        if rc != 0:
            print(f"FAIL end of input: exit {rc}, want 0")
            failures += 1
    except subprocess.TimeoutExpired:
        proc.kill()
        print("FAIL end of input: REPL did not exit")
        failures += 1

    print("REPL protocol OK" if failures == 0 else f"{failures} REPL protocol check(s) failed")
    return 0 if failures == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
