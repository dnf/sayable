"""Nim locale emitter for sayable-time."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header

HEADER = make_header("codegen/targets/nim/emitter.py", line_prefix="# ")

_NIM_RESERVED = {
    "addr", "and", "as", "asm", "bind", "block", "break", "case", "cast",
    "concept", "const", "continue", "converter", "defer", "discard", "distinct",
    "div", "do", "elif", "else", "end", "enum", "except", "export", "finally",
    "for", "from", "func", "if", "import", "in", "include", "interface",
    "is", "isnot", "iterator", "let", "macro", "method", "mixin", "mod",
    "nil", "not", "notin", "object", "of", "or", "out", "proc", "ptr",
    "raise", "ref", "return", "shl", "shr", "static", "template", "try",
    "tuple", "type", "using", "var", "when", "while", "xor", "yield",
}


def _safe_id(code: str) -> str:
    safe = code.replace("-", "_")
    if safe in _NIM_RESERVED:
        return f"{safe}Locale"
    return safe


def _const_name(code: str) -> str:
    return _safe_id(code).upper()


def _quote(s: str) -> str:
    escaped = s.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def _str_list(items: list) -> str:
    return "@[" + ", ".join(_quote(s) for s in items) + "]"


def _int_str_dict(d: dict) -> str:
    pairs = ", ".join(f"({int(k)}, {_quote(v)})" for k, v in d.items())
    return "@[" + pairs + "].toOrderedTable"


def emit_locale(data: dict) -> str:
    code = data["code"]
    name = data["name"]

    lines = [HEADER + locale_source_comment(code, line_prefix="# ")]
    lines.append(f"## {name} locale.")
    lines.append("")
    lines.append("import ../locale")
    lines.append("")

    lines.append(f"let {_const_name(code)}* = TimeLocale(")
    lines.append(f"  code: {_quote(code)},")

    # Clock config
    clock = data["clock"]
    lines.append("  clock: ClockConfig(")
    lines.append(f"    hours: {_str_list(clock['hours'])},")
    lines.append(f"    midnight: {_quote(clock['midnight'])},")
    lines.append(f"    noon: {_quote(clock['noon'])},")
    lines.append(f"    patterns: {_int_str_dict(clock['patterns'])},")
    lines.append("  ),")

    # Short/compact
    for mode in ("short", "compact"):
        if mode in data:
            ovr = data[mode]
            if "clock" in ovr:
                sc = ovr["clock"]
                lines.append(f"  {mode}: some(CompactnessOverride(")
                lines.append("    clock: some(ShortClockConfig(")
                lines.append(f"      use24h: {'true' if sc.get('use24h', False) else 'false'},")
                lines.append(f"      format: {_quote(sc['format'])},")
                if "amPm" in sc and sc["amPm"]:
                    lines.append(f"      amPm: some(({_quote(sc['amPm'][0])}, {_quote(sc['amPm'][1])})),")
                else:
                    lines.append("      amPm: none((string, string)),")
                lines.append("    )),")
                lines.append("  )),")
            else:
                lines.append(f"  {mode}: some(CompactnessOverride(")
                lines.append("    clock: none(ShortClockConfig),")
                lines.append("  )),")
        else:
            lines.append(f"  {mode}: none(CompactnessOverride),")

    lines.append(")")
    lines.append("")
    return "\n".join(lines)


def emit_registry(all_locales: list[dict]) -> str:
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER]
    lines.append("## Locale registry for all supported languages.")
    lines.append("")
    lines.append("import std/[options, tables]")
    lines.append("import ../locale")

    for loc in sorted_locs:
        lines.append(f"import {_safe_id(loc['code'])}")
    lines.append("")
    lines.append("export locale")
    lines.append("")

    lines.append("let allLocales = {")
    for loc in sorted_locs:
        lines.append(f"  {_quote(loc['code'])}: {_const_name(loc['code'])},")
    lines.append("}.toTable")
    lines.append("")
    lines.append("proc getLocale*(code: string): Option[TimeLocale] =")
    lines.append("  if code in allLocales: some(allLocales[code])")
    lines.append("  else: none(TimeLocale)")
    lines.append("")
    return "\n".join(lines)


def emit_barrel(all_locales: list[dict]) -> str | None:
    return None


def output_path(code: str, root: str) -> str:
    import os
    return os.path.join(root, "impl", "nim", "src", "sayable_time", "locales", f"{_safe_id(code)}.nim")


def registry_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "nim", "src", "sayable_time", "locales", "registry.nim")


def barrel_path(root: str) -> str | None:
    return None
