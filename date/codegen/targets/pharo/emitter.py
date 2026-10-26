"""Pharo Smalltalk locale emitter for sayable-date.

Generates Pharo chunk-format (.st) files loadable via FileStream fileIn:.
"""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header

HEADER = make_header("codegen/targets/pharo/emitter.py", line_prefix='" ', line_suffix=' "')


def _quote(s: str) -> str:
    """Quote a string for Smalltalk — single quotes with doubling."""
    escaped = s.replace("'", "''")
    return f"'{escaped}'"


def _str_list(items: list[str]) -> str:
    """Emit a Smalltalk ordered collection literal from a list of strings."""
    elems = ". ".join(_quote(item) for item in items)
    return f"(OrderedCollection withAll: {{ {elems} }})"


def _dict_from_pairs(pairs: list[tuple[str, str]]) -> str:
    """Emit a Dictionary newFromPairs expression."""
    items = ". ".join(f"{_quote(k)}. {_quote(v)}" for k, v in pairs)
    return f"(Dictionary newFromPairs: {{ {items} }})"


def emit_locale(data: dict) -> str:
    code = data["code"]

    lines = [HEADER + locale_source_comment(code, line_prefix='" ', line_suffix=' "')]
    lines.append(f'"Locale: {code}"!')
    lines.append("")

    lines.append(f"!SayableDateLocales class methodsFor: 'locales'!")
    lines.append(f"{code}")
    lines.append(f"\t| locale |")
    lines.append(f"\tlocale := SayableDateLocale new.")
    lines.append(f"\tlocale code: {_quote(code)}.")

    # months
    lines.append(f"\tlocale months: {_str_list(data['months'])}.")

    # weekdays
    lines.append(f"\tlocale weekdays: {_str_list(data['weekdays'])}.")

    # dayFormat
    lines.append(f"\tlocale dayFormat: {_quote(data['dayFormat'])}.")

    # dayFormatExceptions
    if "dayFormatExceptions" in data and data["dayFormatExceptions"]:
        exc = data["dayFormatExceptions"]
        pairs = [(k, exc[k]) for k in sorted(exc.keys(), key=lambda x: int(x))]
        lines.append(f"\tlocale dayFormatExceptions: {_dict_from_pairs(pairs)}.")
    else:
        lines.append(f"\tlocale dayFormatExceptions: Dictionary new.")

    # datePattern
    lines.append(f"\tlocale datePattern: {_quote(data['datePattern'])}.")
    lines.append(f"\tlocale datePatternWithYear: {_quote(data['datePatternWithYear'])}.")

    # proximity strings
    lines.append(f"\tlocale today: {_quote(data['today'])}.")
    lines.append(f"\tlocale tomorrow: {_quote(data['tomorrow'])}.")
    lines.append(f"\tlocale yesterday: {_quote(data['yesterday'])}.")

    # optional proximity strings
    for field in ("dayAfterTomorrow", "dayBeforeYesterday", "thisWeekday", "nextWeekday", "lastWeekday"):
        if field in data and data[field]:
            lines.append(f"\tlocale {field}: {_quote(data[field])}.")
        else:
            lines.append(f"\tlocale {field}: nil.")

    # monthsInDate (optional genitive forms)
    if "monthsInDate" in data and data["monthsInDate"]:
        lines.append(f"\tlocale monthsInDate: {_str_list(data['monthsInDate'])}.")
    else:
        lines.append(f"\tlocale monthsInDate: nil.")

    # Short/compact overrides
    for mode in ("short", "compact"):
        if mode in data:
            ovr = data[mode]
            lines.append(f"\tlocale {mode}: (Dictionary newFromPairs: {{")
            if "months" in ovr:
                lines.append(f"\t\t#months. {_str_list(ovr['months'])}.")
            if "monthsInDate" in ovr:
                lines.append(f"\t\t#monthsInDate. {_str_list(ovr['monthsInDate'])}.")
            if "weekdays" in ovr:
                lines.append(f"\t\t#weekdays. {_str_list(ovr['weekdays'])}.")
            if "dayFormat" in ovr:
                lines.append(f"\t\t#dayFormat. {_quote(ovr['dayFormat'])}.")
            if "dayFormatExceptions" in ovr:
                exc = ovr["dayFormatExceptions"]
                pairs = [(k, exc[k]) for k in sorted(exc.keys(), key=lambda x: int(x))]
                lines.append(f"\t\t#dayFormatExceptions. {_dict_from_pairs(pairs)}.")
            if "datePattern" in ovr:
                lines.append(f"\t\t#datePattern. {_quote(ovr['datePattern'])}.")
            if "datePatternWithYear" in ovr:
                lines.append(f"\t\t#datePatternWithYear. {_quote(ovr['datePatternWithYear'])}.")
            if "today" in ovr:
                lines.append(f"\t\t#today. {_quote(ovr['today'])}.")
            if "tomorrow" in ovr:
                lines.append(f"\t\t#tomorrow. {_quote(ovr['tomorrow'])}.")
            if "yesterday" in ovr:
                lines.append(f"\t\t#yesterday. {_quote(ovr['yesterday'])}.")
            lines.append(f"\t}}).")

    lines.append(f"\t^ locale")
    lines.append("! !")
    lines.append("")

    return "\n".join(lines)


def emit_registry(all_locales: list[dict]) -> str:
    """Generate registry.st with lookup methods in chunk format."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER]
    lines.append('"Locale registry — maps code strings to locale objects."!')
    lines.append("")

    lines.append("!SayableDateLocales class methodsFor: 'registry'!")
    lines.append("buildRegistry")
    lines.append("\t| registry |")
    lines.append("\tregistry := Dictionary new.")
    for loc in sorted_locs:
        code = loc["code"]
        lines.append(f"\tregistry at: {_quote(code)} put: self {code}.")
    lines.append("\t^ registry")
    lines.append("!")
    lines.append("")
    lines.append("get: aCode")
    lines.append("\t^ self registry at: aCode ifAbsent: [ nil ]")
    lines.append("!")
    lines.append("")
    lines.append("registry")
    lines.append("\tRegistry ifNil: [ Registry := self buildRegistry ].")
    lines.append("\t^ Registry")
    lines.append("! !")
    lines.append("")

    return "\n".join(lines)


def output_path(code: str, root: str) -> str:
    import os
    return os.path.join(root, "impl", "pharo", "locales", f"{code}.st")


def registry_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "pharo", "locales", "registry.st")
