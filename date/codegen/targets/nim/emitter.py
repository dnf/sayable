"""Nim locale emitter for sayable-date."""

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


def _str_dict(d: dict) -> str:
    pairs = ", ".join(f"({_quote(k)}, {_quote(v)})" for k, v in d.items())
    return "@[" + pairs + "].toOrderedTable"


def emit_locale(data: dict) -> str:
    code = data["code"]
    name = data["name"]

    lines = [HEADER + locale_source_comment(code, line_prefix="# ")]
    lines.append(f"## {name} locale.")
    lines.append("")
    lines.append("import ../locale")
    lines.append("")

    lines.append(f"let {_const_name(code)}* = DateLocale(")
    lines.append(f"  code: {_quote(code)},")
    lines.append(f"  months: {_str_list(data['months'])},")
    lines.append(f"  weekdays: {_str_list(data['weekdays'])},")
    lines.append(f"  dayFormat: {_quote(data['dayFormat'])},")

    # Day format exceptions
    if data.get("dayFormatExceptions"):
        lines.append(f"  dayFormatExceptions: {_str_dict(data['dayFormatExceptions'])},")
    else:
        lines.append("  dayFormatExceptions: initOrderedTable[string, string](),")

    lines.append(f"  datePattern: {_quote(data.get('datePattern', '{day} {month}'))},")
    lines.append(f"  datePatternWithYear: {_quote(data.get('datePatternWithYear', '{day} {month} {year}'))},")
    lines.append(f"  today: {_quote(data.get('today', 'today'))},")
    lines.append(f"  tomorrow: {_quote(data.get('tomorrow', 'tomorrow'))},")
    lines.append(f"  yesterday: {_quote(data.get('yesterday', 'yesterday'))},")

    # Optional fields
    for field in ("dayAfterTomorrow", "dayBeforeYesterday", "thisWeekday", "nextWeekday", "lastWeekday"):
        nim_field = field[0].lower() + field[1:]
        if field in data and data[field]:
            lines.append(f"  {nim_field}: some({_quote(data[field])}),")
        else:
            lines.append(f"  {nim_field}: none(string),")

    # monthsInDate
    if data.get("monthsInDate"):
        lines.append(f"  monthsInDate: some({_str_list(data['monthsInDate'])}),")
    else:
        lines.append("  monthsInDate: none(seq[string]),")

    # Short/compact
    for mode in ("short", "compact"):
        if mode in data:
            ovr = data[mode]
            lines.append(f"  {mode}: some(CompactnessOverride(")
            for ofield, default_none in [("months", "none(seq[string])"), ("monthsInDate", "none(seq[string])"),
                                          ("weekdays", "none(seq[string])"),
                                          ("dayFormat", "none(string)"),
                                          ("datePattern", "none(string)"),
                                          ("datePatternWithYear", "none(string)"),
                                          ("today", "none(string)"),
                                          ("tomorrow", "none(string)"),
                                          ("yesterday", "none(string)")]:
                if ofield in ovr and ovr[ofield] is not None:
                    if isinstance(ovr[ofield], list):
                        lines.append(f"    {ofield}: some({_str_list(ovr[ofield])}),")
                    else:
                        lines.append(f"    {ofield}: some({_quote(ovr[ofield])}),")
                else:
                    lines.append(f"    {ofield}: {default_none},")
            if "dayFormatExceptions" in ovr and ovr["dayFormatExceptions"] is not None:
                lines.append(f"    dayFormatExceptions: some({_str_dict(ovr['dayFormatExceptions'])}),")
            else:
                lines.append("    dayFormatExceptions: none(OrderedTable[string, string]),")
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
    lines.append("proc getLocale*(code: string): Option[DateLocale] =")
    lines.append("  if code in allLocales: some(allLocales[code])")
    lines.append("  else: none(DateLocale)")
    lines.append("")
    return "\n".join(lines)


def emit_barrel(all_locales: list[dict]) -> str | None:
    return None


def output_path(code: str, root: str) -> str:
    import os
    return os.path.join(root, "impl", "nim", "src", "sayable_date", "locales", f"{_safe_id(code)}.nim")


def registry_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "nim", "src", "sayable_date", "locales", "registry.nim")


def barrel_path(root: str) -> str | None:
    return None
