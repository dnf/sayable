"""Elm locale emitter for sayable-duration.

The output is already laid out the way elm-format 0.8.8 leaves it, so
`elm-format --validate` passes on the generated files as they are.
"""

from __future__ import annotations

import unicodedata

from codegen.banner import locale_source_comment, make_header
from codegen.targets.elm.plural_rules import get_elm_plural

HEADER = make_header("codegen/targets/elm/emitter.py", line_prefix="-- ")

_CAT_MAP = {
    "zero": "Zero", "one": "One", "two": "Two",
    "few": "Few", "many": "Many", "other": "Other",
}

_UNIT_NAMES = ["second", "minute", "hour", "day", "week", "month", "year"]


def _module_name(code: str) -> str:
    """Convert locale code to Elm module name (capitalize first letter)."""
    return code[0].upper() + code[1:]


# elm-format writes control, format and unassigned characters and every space
# but U+0020 (U+00A0, U+202F, ...) as \u{XXXX} escapes.
_ESCAPED_CATEGORIES = {"Cc", "Cf", "Cs", "Co", "Cn", "Zl", "Zp", "Zs"}


def _escape_char(c: str) -> str:
    if c == "\\":
        return "\\\\"
    if c == '"':
        return '\\"'
    if c == "\n":
        return "\\n"
    if c == "\t":
        return "\\t"
    if c != " " and unicodedata.category(c) in _ESCAPED_CATEGORIES:
        return f"\\u{{{ord(c):04X}}}"
    return c


def _quote(s: str) -> str:
    return '"' + "".join(_escape_char(c) for c in s) + '"'


def _next_indent(column: int) -> int:
    """elm-format indents a function's arguments to the next multiple of four."""
    return (column // 4 + 1) * 4


def _pluralized(unit: dict, column: int) -> list[str]:
    """`Pluralized` (written at `column`) with its list of forms on the lines below."""
    pad = " " * _next_indent(column)
    cats = ["zero", "one", "two", "few", "many", "other"]
    pairs = [f"( {_CAT_MAP[cat]}, {_quote(unit[cat])} )" for cat in cats if cat in unit]
    lines = ["Pluralized", f"{pad}[ {pairs[0]}"]
    lines.extend(f"{pad}, {pair}" for pair in pairs[1:])
    lines.append(f"{pad}]")
    return lines


def _unit_entries(units: dict, column: int) -> list[str]:
    """The `[ ( "second", ... ) ... ]` list of a `Dict.fromList`, its `[` at `column`."""
    pad = " " * column
    tuple_pad = " " * (column + 2)
    lines = []
    names = [u for u in _UNIT_NAMES if u in units]
    for i, name in enumerate(names):
        prefix = "[ " if i == 0 else ", "
        unit = units[name]
        if isinstance(unit, str):
            lines.append(f"{pad}{prefix}( \"{name}\", Simple {_quote(unit)} )")
            continue
        value = _pluralized(unit, column + 4)
        lines.append(f"{pad}{prefix}( \"{name}\"")
        lines.append(f"{tuple_pad}, {value[0]}")
        lines.extend(value[1:])
        lines.append(f"{tuple_pad})")
    lines.append(f"{pad}]")
    return lines


def _if_chain(body: str, indent: int) -> list[str]:
    """Lay out `if a then X else if b then Y else Z` the way elm-format does."""
    pad = " " * indent
    lines: list[str] = []
    rest = body
    keyword = "if"
    while rest.startswith("if "):
        cond, rest = rest[len("if "):].split(" then ", 1)
        result, rest = rest.split(" else ", 1)
        lines.append(f"{pad}{keyword} {cond} then")
        lines.append(f"{pad}    {result}")
        lines.append("")
        keyword = "else if"
    lines.append(f"{pad}else")
    lines.append(f"{pad}    {rest}")
    return lines


def _plural_field(rule: str) -> list[str]:
    bindings, body = get_elm_plural(rule)
    if not bindings and not body.startswith("if "):
        return [f"    , plural = \\n -> {body}"]
    lines = ["    , plural =", "        \\n ->"]
    if bindings:
        lines.append("            let")
        for i, (bname, bexpr) in enumerate(bindings):
            if i > 0:
                lines.append("")
            lines.append(f"                {bname} =")
            lines.append(f"                    {bexpr}")
        lines.append("            in")
    lines.extend(_if_chain(body, 12))
    return lines


def _maybe_str_field(field: str, value: str | None, pad: str) -> str:
    if value is None:
        return f"{pad}, {field} = Nothing"
    return f"{pad}, {field} = Just {_quote(value)}"


def _compactness_override(ovr: dict, indent: int = 4) -> str:
    pad = " " * indent
    lines = []

    # Units
    if "units" in ovr:
        lines.append(f"{pad}{{ ovrUnits =")
        lines.append(f"{pad}    Just")
        lines.append(f"{pad}        (Dict.fromList")
        lines.extend(_unit_entries(ovr["units"], indent + 12))
        lines.append(f"{pad}        )")
    else:
        lines.append(f"{pad}{{ ovrUnits = Nothing")

    # Simple fields
    lines.append(_maybe_str_field("ovrHalf", ovr.get("half"), pad))
    lines.append(_maybe_str_field("ovrDelimiter", ovr.get("delimiter"), pad))
    lines.append(_maybe_str_field("ovrAgo", ovr.get("ago"), pad))
    lines.append(_maybe_str_field("ovrInFuture", ovr.get("inFuture"), pad))

    lines.append(f"{pad}}}")
    return "\n".join(lines)


def emit_locale(data: dict) -> str:
    """Generate an Elm locale file from canonical JSON."""
    code = data["code"]
    rule = data["pluralRule"]
    mod = _module_name(code)

    lines = [HEADER + locale_source_comment(code, line_prefix="-- ")]
    lines.append("")
    lines.append(f"module SayableDuration.Locales.{mod} exposing (locale)")
    lines.append("")
    lines.append("import Dict")
    lines.append("import SayableDuration.Types exposing (..)")
    lines.append("")
    lines.append("")
    lines.append("locale : Locale")
    lines.append("locale =")
    lines.append(f"    {{ code = {_quote(code)}")
    lines.extend(_plural_field(rule))

    # Units
    lines.append("    , units =")
    lines.append("        Dict.fromList")
    lines.extend(_unit_entries(data["units"], 12))

    # Simple fields
    lines.append(f"    , half = {_quote(data['half'])}")
    lines.append(f"    , delimiter = {_quote(data['delimiter'])}")
    lines.append(f"    , justNow = {_quote(data['justNow'])}")
    lines.append(f"    , ago = {_quote(data['ago'])}")
    lines.append(f"    , inFuture = {_quote(data['inFuture'])}")

    # Short/compact
    for mode in ("short", "compact"):
        if mode in data:
            lines.append(f"    , {mode} =")
            lines.append("        Just")
            lines.append(_compactness_override(data[mode], indent=12))
        else:
            lines.append(f"    , {mode} = Nothing")

    lines.append("    }")
    lines.append("")

    return "\n".join(lines)


def emit_barrel(all_locales: list[dict]) -> str:
    """Generate the Locales.elm barrel module."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER]
    lines.append("")
    lines.append("module SayableDuration.Locales exposing (getLocale)")
    lines.append("")

    # elm-format sorts imports by module name
    imports = ["Dict exposing (Dict)", "SayableDuration.Types exposing (Locale)"]
    for loc in sorted_locs:
        mod = _module_name(loc["code"])
        imports.append(f"SayableDuration.Locales.{mod} as {mod}")
    lines.extend(f"import {imp}" for imp in sorted(imports, key=lambda imp: imp.split()[0]))

    lines.append("")
    lines.append("")
    lines.append("allLocales : Dict String Locale")
    lines.append("allLocales =")
    lines.append("    Dict.fromList")

    for i, loc in enumerate(sorted_locs):
        code = loc["code"]
        mod = _module_name(code)
        prefix = "[ " if i == 0 else ", "
        lines.append(f"        {prefix}( \"{code}\", {mod}.locale )")

    lines.append("        ]")
    lines.append("")
    lines.append("")
    lines.append("getLocale : String -> Maybe Locale")
    lines.append("getLocale code =")
    lines.append("    Dict.get code allLocales")
    lines.append("")

    return "\n".join(lines)


def output_path(code: str, root: str) -> str:
    import os
    mod = _module_name(code)
    return os.path.join(root, "impl", "elm", "src", "SayableDuration", "Locales", f"{mod}.elm")


def barrel_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "elm", "src", "SayableDuration", "Locales.elm")
