"""COBOL locale emitter for sayable-time -- active-locale pattern.

Generates a single Locales.cbl COBOL copybook containing:
  - One INIT-LOCALE-XX paragraph per locale (populates WS-ACT-* fields)
  - A GET-LOCALE paragraph that dispatches by WS-LOOKUP-CODE
"""

from __future__ import annotations

import os

from codegen.banner import locale_source_comment, make_header

HEADER = make_header("codegen/targets/cobol/emitter.py", line_prefix="*> ", line_suffix="")

_MAX_STR_LEN = 256

_PATTERN_KEYS = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55]


def _quote(s: str) -> str:
    """Escape a string for COBOL literal. Empty strings become SPACES."""
    if not s:
        return "SPACES"
    escaped = s.replace('"', '""')
    return f'"{escaped}"'


def _para_name(code: str) -> str:
    """Return a COBOL paragraph name for a locale code."""
    return f"INIT-LOCALE-{code.upper().replace('-', '-')}"


def emit_all(all_locales: list[dict]) -> str:
    """Generate the single Locales.cbl copybook."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])

    lines: list[str] = []
    lines.append(HEADER.rstrip())

    # GET-LOCALE dispatcher paragraph
    lines.append("       GET-LOCALE.")
    lines.append("           MOVE 0 TO WS-LOOKUP-FOUND")
    lines.append("           EVALUATE WS-LOOKUP-CODE")
    for data in sorted_locs:
        code = data["code"]
        lines.append(f'               WHEN "{code}"')
        lines.append(f"                   PERFORM {_para_name(code)}")
        lines.append("                   MOVE 1 TO WS-LOOKUP-FOUND")
    lines.append("           END-EVALUATE")
    lines.append("           .")
    lines.append("")

    # INIT-LOCALE-XX paragraphs
    for data in sorted_locs:
        code = data["code"]
        clock = data["clock"]

        lines.append(locale_source_comment(code, line_prefix="*> ", line_suffix="").rstrip())
        lines.append(f"       {_para_name(code)}.")
        lines.append(f'           MOVE "{code}" TO WS-ACT-CODE')

        # Clock hours (12 entries, index 0-11)
        for i, hour_name in enumerate(clock["hours"], 1):
            lines.append(f"           MOVE {_quote(hour_name)}")
            lines.append(f"               TO WS-ACT-HOUR({i})")

        # Midnight and noon
        lines.append(f"           MOVE {_quote(clock['midnight'])}")
        lines.append(f"               TO WS-ACT-MIDNIGHT")
        lines.append(f"           MOVE {_quote(clock['noon'])}")
        lines.append(f"               TO WS-ACT-NOON")

        # Clock patterns (keyed by rounded minute)
        for i, key in enumerate(_PATTERN_KEYS, 1):
            pattern = clock["patterns"].get(str(key), "")
            lines.append(f"           MOVE {_quote(pattern)}")
            lines.append(f"               TO WS-ACT-PATTERN({i})")

        # Short override
        if "short" in data and "clock" in data["short"]:
            sc = data["short"]["clock"]
            lines.append("           MOVE 1 TO WS-ACT-HAS-SHORT")
            lines.append(f"           MOVE {1 if sc.get('use24h', False) else 0}")
            lines.append(f"               TO WS-ACT-SHORT-USE24H")
            lines.append(f"           MOVE {_quote(sc.get('format', ''))}")
            lines.append(f"               TO WS-ACT-SHORT-FORMAT")
            ampm = sc.get("amPm", ["", ""])
            lines.append(f"           MOVE {_quote(ampm[0])}")
            lines.append(f"               TO WS-ACT-SHORT-AM")
            lines.append(f"           MOVE {_quote(ampm[1])}")
            lines.append(f"               TO WS-ACT-SHORT-PM")
        else:
            lines.append("           MOVE 0 TO WS-ACT-HAS-SHORT")

        # Compact override
        if "compact" in data and "clock" in data["compact"]:
            sc = data["compact"]["clock"]
            lines.append("           MOVE 1 TO WS-ACT-HAS-COMPACT")
            lines.append(f"           MOVE {1 if sc.get('use24h', False) else 0}")
            lines.append(f"               TO WS-ACT-COMPACT-USE24H")
            lines.append(f"           MOVE {_quote(sc.get('format', ''))}")
            lines.append(f"               TO WS-ACT-COMPACT-FORMAT")
            ampm = sc.get("amPm", ["", ""])
            lines.append(f"           MOVE {_quote(ampm[0])}")
            lines.append(f"               TO WS-ACT-COMPACT-AM")
            lines.append(f"           MOVE {_quote(ampm[1])}")
            lines.append(f"               TO WS-ACT-COMPACT-PM")
        else:
            lines.append("           MOVE 0 TO WS-ACT-HAS-COMPACT")

        lines.append("           .")
        lines.append("")

    lines.append("")
    return "\n".join(lines)


def output_path(root: str) -> str:
    return os.path.join(root, "impl", "cobol", "src", "locales", "Locales.cbl")
