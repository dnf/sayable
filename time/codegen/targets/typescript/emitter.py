"""TypeScript locale emitter for sayable-time."""

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


def emit_locale(data: dict) -> str:
    """Generate a TypeScript locale file from canonical JSON."""
    code = data["code"]
    clock = data["clock"]
    lines = [HEADER + locale_source_comment(code)]

    lines.append("import type { TimeLocale } from '../locale.js';\n")

    lines.append(f"export const {code}: TimeLocale = {{")
    lines.append(f"  code: {_quote(code)},")

    # Clock config
    lines.append("  clock: {")
    lines.append(f"    hours: {_str_array(clock['hours'])},")
    lines.append(f"    midnight: {_quote(clock['midnight'])},")
    lines.append(f"    noon: {_quote(clock['noon'])},")
    lines.append("    patterns: {")
    for key in ["0", "5", "10", "15", "20", "25", "30", "35", "40", "45", "50", "55"]:
        if key in clock["patterns"]:
            val = clock["patterns"][key]
            lines.append(f"      {key}: {_quote(val)},")
    lines.append("    },")
    lines.append("  },")

    # Short override
    if "short" in data:
        sc = data["short"].get("clock", {})
        use24h = "true" if sc.get("use24h", True) else "false"
        fmt = sc.get("format", "{h}:{mm}")
        am_pm = sc.get("amPm")
        if am_pm:
            lines.append("  short: {")
            lines.append(f"    clock: {{ use24h: {use24h}, amPm: [{_quote(am_pm[0])}, {_quote(am_pm[1])}], format: {_quote(fmt)} }},")
            lines.append("  },")
        else:
            lines.append("  short: {")
            lines.append(f"    clock: {{ use24h: {use24h}, format: {_quote(fmt)} }},")
            lines.append("  },")

    # Compact override
    if "compact" in data:
        sc = data["compact"].get("clock", {})
        use24h = "true" if sc.get("use24h", True) else "false"
        fmt = sc.get("format", "{h}:{mm}")
        am_pm = sc.get("amPm")
        if am_pm:
            lines.append("  compact: {")
            lines.append(f"    clock: {{ use24h: {use24h}, amPm: [{_quote(am_pm[0])}, {_quote(am_pm[1])}], format: {_quote(fmt)} }},")
            lines.append("  },")
        else:
            lines.append("  compact: {")
            lines.append(f"    clock: {{ use24h: {use24h}, format: {_quote(fmt)} }},")
            lines.append("  },")

    lines.append("};")
    lines.append("")

    return "\n".join(lines)


def emit_barrel(all_locales: list[dict]) -> str:
    """Generate the locales/index.ts barrel file."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER]

    lines.append("import type { TimeLocale } from '../locale.js';")

    for loc in sorted_locs:
        code = loc["code"]
        lines.append(f"import {{ {code} }} from './{code}.js';")

    lines.append("")

    # Lookup map + function
    codes = ", ".join(loc["code"] for loc in sorted_locs)
    lines.append(f"const _ALL: Record<string, TimeLocale> = {{ {codes} }};")
    lines.append("")
    lines.append("export function getLocale(code: string): TimeLocale | undefined {")
    lines.append("  return _ALL[code];")
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
