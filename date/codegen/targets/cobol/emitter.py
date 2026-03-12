"""COBOL locale emitter for sayable-date -- active-locale pattern.

Generates a single Locales.cbl COBOL copybook containing:
  - One INIT-LOCALE-XX paragraph per locale (populates WS-ACT-* fields)
  - A GET-LOCALE paragraph that dispatches by WS-LOOKUP-CODE
"""

from __future__ import annotations

import os

from codegen.banner import locale_source_comment, make_header

HEADER = make_header("codegen/targets/cobol/emitter.py", line_prefix="*> ", line_suffix="")

_MAX_STR_LEN = 256


def _quote(s: str) -> str:
    """Escape a string for COBOL literal. Empty strings become SPACES."""
    if not s:
        return "SPACES"
    escaped = s.replace('"', '""')
    return f'"{escaped}"'


def _para_name(code: str) -> str:
    """Return a COBOL paragraph name for a locale code."""
    return f"INIT-LOCALE-{code.upper().replace('-', '-')}"


def _emit_list(items: list[str], var: str, indent: str = "           ") -> list[str]:
    """Emit MOVE statements for a list of strings into an OCCURS array."""
    lines = []
    for i, item in enumerate(items, 1):
        lines.append(f"{indent}MOVE {_quote(item)}")
        lines.append(f"{indent}    TO {var}({i})")
    return lines


def _emit_exceptions(exceptions: dict[str, str], indent: str = "           ") -> list[str]:
    """Emit MOVE statements for day format exceptions."""
    lines = []
    lines.append(f"{indent}MOVE 0 TO WS-ACT-DAY-FMT-EXC-COUNT")
    for key, val in sorted(exceptions.items(), key=lambda x: int(x[0])):
        lines.append(f"{indent}ADD 1 TO WS-ACT-DAY-FMT-EXC-COUNT")
        lines.append(f"{indent}MOVE {_quote(key)}")
        lines.append(f"{indent}    TO WS-ACT-DAY-FMT-EXC-KEY(")
        lines.append(f"{indent}       WS-ACT-DAY-FMT-EXC-COUNT)")
        lines.append(f"{indent}MOVE {_quote(val)}")
        lines.append(f"{indent}    TO WS-ACT-DAY-FMT-EXC-VAL(")
        lines.append(f"{indent}       WS-ACT-DAY-FMT-EXC-COUNT)")
    return lines


def _emit_compactness(ovr: dict, prefix: str, indent: str = "           ") -> list[str]:
    """Emit MOVE statements for a compactness override block."""
    lines = []
    if "months" in ovr:
        lines.append(f"{indent}MOVE 1 TO {prefix}-HAS-MONTHS")
        for sl in _emit_list(ovr["months"], f"{prefix}-MONTH", indent):
            lines.append(sl)
    else:
        lines.append(f"{indent}MOVE 0 TO {prefix}-HAS-MONTHS")

    if "monthsInDate" in ovr:
        lines.append(f"{indent}MOVE 1 TO {prefix}-HAS-MID")
        for sl in _emit_list(ovr["monthsInDate"], f"{prefix}-MID", indent):
            lines.append(sl)
    else:
        lines.append(f"{indent}MOVE 0 TO {prefix}-HAS-MID")

    if "weekdays" in ovr:
        lines.append(f"{indent}MOVE 1 TO {prefix}-HAS-WKDAYS")
        for sl in _emit_list(ovr["weekdays"], f"{prefix}-WKDAY", indent):
            lines.append(sl)
    else:
        lines.append(f"{indent}MOVE 0 TO {prefix}-HAS-WKDAYS")

    if "dayFormat" in ovr:
        lines.append(f"{indent}MOVE 1 TO {prefix}-HAS-DAY-FMT")
        lines.append(f"{indent}MOVE {_quote(ovr['dayFormat'])}")
        lines.append(f"{indent}    TO {prefix}-DAY-FMT")
    else:
        lines.append(f"{indent}MOVE 0 TO {prefix}-HAS-DAY-FMT")

    if "dayFormatExceptions" in ovr:
        lines.append(f"{indent}MOVE 1 TO {prefix}-HAS-DAY-EXC")
        # Emit inline exception data for this override
        lines.append(f"{indent}MOVE 0 TO {prefix}-DAY-EXC-COUNT")
        for key, val in sorted(ovr["dayFormatExceptions"].items(), key=lambda x: int(x[0])):
            lines.append(f"{indent}ADD 1 TO {prefix}-DAY-EXC-COUNT")
            lines.append(f"{indent}MOVE {_quote(key)}")
            lines.append(f"{indent}    TO {prefix}-DAY-EXC-KEY(")
            lines.append(f"{indent}       {prefix}-DAY-EXC-COUNT)")
            lines.append(f"{indent}MOVE {_quote(val)}")
            lines.append(f"{indent}    TO {prefix}-DAY-EXC-VAL(")
            lines.append(f"{indent}       {prefix}-DAY-EXC-COUNT)")
    else:
        lines.append(f"{indent}MOVE 0 TO {prefix}-HAS-DAY-EXC")

    if "datePattern" in ovr:
        lines.append(f"{indent}MOVE 1 TO {prefix}-HAS-DATE-PAT")
        lines.append(f"{indent}MOVE {_quote(ovr['datePattern'])}")
        lines.append(f"{indent}    TO {prefix}-DATE-PAT")
    else:
        lines.append(f"{indent}MOVE 0 TO {prefix}-HAS-DATE-PAT")

    if "datePatternWithYear" in ovr:
        lines.append(f"{indent}MOVE 1 TO {prefix}-HAS-DATE-PAT-YR")
        lines.append(f"{indent}MOVE {_quote(ovr['datePatternWithYear'])}")
        lines.append(f"{indent}    TO {prefix}-DATE-PAT-YR")
    else:
        lines.append(f"{indent}MOVE 0 TO {prefix}-HAS-DATE-PAT-YR")

    if "today" in ovr:
        lines.append(f"{indent}MOVE 1 TO {prefix}-HAS-TODAY")
        lines.append(f"{indent}MOVE {_quote(ovr['today'])}")
        lines.append(f"{indent}    TO {prefix}-TODAY")
    else:
        lines.append(f"{indent}MOVE 0 TO {prefix}-HAS-TODAY")

    if "tomorrow" in ovr:
        lines.append(f"{indent}MOVE 1 TO {prefix}-HAS-TOMORROW")
        lines.append(f"{indent}MOVE {_quote(ovr['tomorrow'])}")
        lines.append(f"{indent}    TO {prefix}-TOMORROW")
    else:
        lines.append(f"{indent}MOVE 0 TO {prefix}-HAS-TOMORROW")

    if "yesterday" in ovr:
        lines.append(f"{indent}MOVE 1 TO {prefix}-HAS-YESTERDAY")
        lines.append(f"{indent}MOVE {_quote(ovr['yesterday'])}")
        lines.append(f"{indent}    TO {prefix}-YESTERDAY")
    else:
        lines.append(f"{indent}MOVE 0 TO {prefix}-HAS-YESTERDAY")

    return lines


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

        lines.append(locale_source_comment(code, line_prefix="*> ", line_suffix="").rstrip())
        lines.append(f"       {_para_name(code)}.")
        lines.append(f'           MOVE "{code}" TO WS-ACT-CODE')

        # Months
        for sl in _emit_list(data["months"], "WS-ACT-MONTH"):
            lines.append(sl)

        # Months in date (genitive)
        if "monthsInDate" in data and data["monthsInDate"]:
            lines.append("           MOVE 1 TO WS-ACT-HAS-MONTHS-IN-DATE")
            for sl in _emit_list(data["monthsInDate"], "WS-ACT-MONTH-IN-DATE"):
                lines.append(sl)
        else:
            lines.append("           MOVE 0 TO WS-ACT-HAS-MONTHS-IN-DATE")

        # Weekdays
        for sl in _emit_list(data["weekdays"], "WS-ACT-WEEKDAY"):
            lines.append(sl)

        # Day format
        lines.append(f'           MOVE {_quote(data["dayFormat"])}')
        lines.append(f'               TO WS-ACT-DAY-FORMAT')

        # Day format exceptions
        if "dayFormatExceptions" in data and data["dayFormatExceptions"]:
            for sl in _emit_exceptions(data["dayFormatExceptions"]):
                lines.append(sl)
        else:
            lines.append("           MOVE 0 TO WS-ACT-DAY-FMT-EXC-COUNT")

        # Date patterns
        lines.append(f'           MOVE {_quote(data["datePattern"])}')
        lines.append(f'               TO WS-ACT-DATE-PATTERN')
        lines.append(f'           MOVE {_quote(data["datePatternWithYear"])}')
        lines.append(f'               TO WS-ACT-DATE-PAT-WITH-YEAR')

        # Proximity strings
        lines.append(f'           MOVE {_quote(data["today"])}')
        lines.append(f'               TO WS-ACT-TODAY')
        lines.append(f'           MOVE {_quote(data["tomorrow"])}')
        lines.append(f'               TO WS-ACT-TOMORROW')
        lines.append(f'           MOVE {_quote(data["yesterday"])}')
        lines.append(f'               TO WS-ACT-YESTERDAY')

        # Optional proximity extensions
        dat = data.get("dayAfterTomorrow", "")
        lines.append(f'           MOVE {_quote(dat)}')
        lines.append(f'               TO WS-ACT-DAY-AFTER-TOMORROW')

        dby = data.get("dayBeforeYesterday", "")
        lines.append(f'           MOVE {_quote(dby)}')
        lines.append(f'               TO WS-ACT-DAY-BEFORE-YESTERDAY')

        tw = data.get("thisWeekday", "")
        lines.append(f'           MOVE {_quote(tw)}')
        lines.append(f'               TO WS-ACT-THIS-WEEKDAY')

        nw = data.get("nextWeekday", "")
        lines.append(f'           MOVE {_quote(nw)}')
        lines.append(f'               TO WS-ACT-NEXT-WEEKDAY')

        lw = data.get("lastWeekday", "")
        lines.append(f'           MOVE {_quote(lw)}')
        lines.append(f'               TO WS-ACT-LAST-WEEKDAY')

        # Short override
        if "short" in data:
            lines.append("           MOVE 1 TO WS-ACT-HAS-SHORT")
            for sl in _emit_compactness(data["short"], "WS-ACT-SHORT"):
                lines.append(sl)
        else:
            lines.append("           MOVE 0 TO WS-ACT-HAS-SHORT")

        # Compact override
        if "compact" in data:
            lines.append("           MOVE 1 TO WS-ACT-HAS-COMPACT")
            for sl in _emit_compactness(data["compact"], "WS-ACT-COMPACT"):
                lines.append(sl)
        else:
            lines.append("           MOVE 0 TO WS-ACT-HAS-COMPACT")

        lines.append("           .")
        lines.append("")

    lines.append("")
    return "\n".join(lines)


def output_path(root: str) -> str:
    return os.path.join(root, "impl", "cobol", "src", "locales", "Locales.cbl")
