"""TypeScript locale emitter for sayable-date."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header

HEADER = make_header("codegen/targets/typescript/emitter.py")


def _quote(s: str) -> str:
    """Quote a string for TypeScript, using single quotes and escaping."""
    escaped = s.replace("\\", "\\\\").replace("'", "\\'")
    return f"'{escaped}'"


def _str_array(items: list[str]) -> str:
    """Emit a TypeScript string array on one line."""
    return "[" + ", ".join(_quote(s) for s in items) + "]"


def _str_record(d: dict[str, str]) -> str:
    """Emit a TypeScript Record<string, string> on one line."""
    pairs = [f"{_quote(k)}: {_quote(v)}" for k, v in d.items()]
    return "{ " + ", ".join(pairs) + " }"


def emit_locale(data: dict) -> str:
    """Generate a TypeScript locale file from canonical JSON."""
    code = data["code"]
    lines = [HEADER + locale_source_comment(code)]

    lines.append("import type { DateLocale } from '../locale.js';\n")

    lines.append(f"export const {code}: DateLocale = {{")
    lines.append(f"  code: {_quote(code)},")
    lines.append(f"  months: {_str_array(data['months'])},")
    lines.append(f"  weekdays: {_str_array(data['weekdays'])},")
    lines.append(f"  dayFormat: {_quote(data['dayFormat'])},")

    if "dayFormatExceptions" in data and data["dayFormatExceptions"]:
        lines.append(f"  dayFormatExceptions: {_str_record(data['dayFormatExceptions'])},")
    else:
        lines.append("  dayFormatExceptions: {},")

    lines.append(f"  datePattern: {_quote(data['datePattern'])},")
    lines.append(f"  datePatternWithYear: {_quote(data['datePatternWithYear'])},")
    lines.append(f"  today: {_quote(data['today'])},")
    lines.append(f"  tomorrow: {_quote(data['tomorrow'])},")
    lines.append(f"  yesterday: {_quote(data['yesterday'])},")

    if "dayAfterTomorrow" in data:
        lines.append(f"  dayAfterTomorrow: {_quote(data['dayAfterTomorrow'])},")
    if "dayBeforeYesterday" in data:
        lines.append(f"  dayBeforeYesterday: {_quote(data['dayBeforeYesterday'])},")
    if "thisWeekday" in data:
        lines.append(f"  thisWeekday: {_quote(data['thisWeekday'])},")
    if "nextWeekday" in data:
        lines.append(f"  nextWeekday: {_quote(data['nextWeekday'])},")
    if "lastWeekday" in data:
        lines.append(f"  lastWeekday: {_quote(data['lastWeekday'])},")
    if "monthsInDate" in data:
        lines.append(f"  monthsInDate: {_str_array(data['monthsInDate'])},")

    # Short override
    if "short" in data:
        ovr = data["short"]
        lines.append("  short: {")
        if "months" in ovr:
            lines.append(f"    months: {_str_array(ovr['months'])},")
        if "weekdays" in ovr:
            lines.append(f"    weekdays: {_str_array(ovr['weekdays'])},")
        if "dayFormat" in ovr:
            lines.append(f"    dayFormat: {_quote(ovr['dayFormat'])},")
        if "datePattern" in ovr:
            lines.append(f"    datePattern: {_quote(ovr['datePattern'])},")
        if "datePatternWithYear" in ovr:
            lines.append(f"    datePatternWithYear: {_quote(ovr['datePatternWithYear'])},")
        lines.append("  },")

    # Compact override
    if "compact" in data:
        ovr = data["compact"]
        lines.append("  compact: {")
        if "datePattern" in ovr:
            lines.append(f"    datePattern: {_quote(ovr['datePattern'])},")
        if "datePatternWithYear" in ovr:
            lines.append(f"    datePatternWithYear: {_quote(ovr['datePatternWithYear'])},")
        lines.append("  },")

    lines.append("};")
    lines.append("")

    return "\n".join(lines)


def emit_barrel(all_locales: list[dict]) -> str:
    """Generate the locales/index.ts barrel file."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER]

    lines.append("import type { DateLocale } from '../locale.js';")

    for loc in sorted_locs:
        code = loc["code"]
        lines.append(f"import {{ {code} }} from './{code}.js';")

    lines.append("")

    # Lookup map + function
    codes = ", ".join(loc["code"] for loc in sorted_locs)
    lines.append(f"const _ALL: Record<string, DateLocale> = {{ {codes} }};")
    lines.append("")
    lines.append("export function getLocale(code: string): DateLocale | undefined {")
    lines.append("  return Object.hasOwn(_ALL, code) ? _ALL[code] : undefined;")
    lines.append("}")
    lines.append("")

    # Re-export all locale constants
    lines.append(f"export {{ {codes} }};")
    lines.append("")
    return "\n".join(lines)


def output_path(code: str, root: str) -> str:
    import os
    return os.path.join(root, "impl", "typescript", "src", "locales", f"{code}.ts")


def barrel_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "typescript", "src", "locales", "index.ts")
