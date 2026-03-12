"""Elm locale emitter for sayable-duration."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header
from codegen.targets.elm.plural_rules import get_elm_plural

HEADER = make_header("codegen/targets/elm/emitter.py", line_prefix="-- ")

_CAT_MAP = {
    "zero": "Zero", "one": "One", "two": "Two",
    "few": "Few", "many": "Many", "other": "Other",
}


def _module_name(code: str) -> str:
    """Convert locale code to Elm module name (capitalize first letter)."""
    return code[0].upper() + code[1:]


def _quote(s: str) -> str:
    escaped = s.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def _unit_forms(unit: object, indent: int = 4) -> str:
    pad = " " * indent
    if isinstance(unit, str):
        return f"Simple {_quote(unit)}"
    cats = ["zero", "one", "two", "few", "many", "other"]
    pairs = []
    for cat in cats:
        if cat in unit:
            pairs.append(f"( {_CAT_MAP[cat]}, {_quote(unit[cat])} )")
    return "Pluralized\n" + pad + "[ " + ("\n" + pad + ", ").join(pairs) + "\n" + pad + "]"


def _compactness_override(ovr: dict, indent: int = 4) -> str:
    pad = " " * indent
    lines = []

    # Units
    if "units" in ovr:
        lines.append(f"{pad}{{ ovrUnits =")
        lines.append(f"{pad}    Just")
        lines.append(f"{pad}        (Dict.fromList")
        unit_names = ["second", "minute", "hour", "day", "week", "month", "year"]
        entries = [(u, ovr["units"][u]) for u in unit_names if u in ovr["units"]]
        for i, (u, val) in enumerate(entries):
            prefix = "[ " if i == 0 else ", "
            lines.append(f"{pad}            {prefix}( \"{u}\", {_unit_forms(val, indent + 14)} )")
        lines.append(f"{pad}            ]")
        lines.append(f"{pad}        )")
    else:
        lines.append(f"{pad}{{ ovrUnits = Nothing")

    # Simple fields
    if "half" in ovr:
        lines.append(f"{pad}, ovrHalf = Just {_quote(ovr['half'])}")
    else:
        lines.append(f"{pad}, ovrHalf = Nothing")

    if "delimiter" in ovr:
        lines.append(f"{pad}, ovrDelimiter = Just {_quote(ovr['delimiter'])}")
    else:
        lines.append(f"{pad}, ovrDelimiter = Nothing")

    if "ago" in ovr:
        lines.append(f"{pad}, ovrAgo = Just {_quote(ovr['ago'])}")
    else:
        lines.append(f"{pad}, ovrAgo = Nothing")

    if "inFuture" in ovr:
        lines.append(f"{pad}, ovrInFuture = Just {_quote(ovr['inFuture'])}")
    else:
        lines.append(f"{pad}, ovrInFuture = Nothing")

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
    lines.append("")
    lines.append("import Dict")
    lines.append("import SayableDuration.Types exposing (..)")
    lines.append("")
    lines.append("")
    lines.append("locale : Locale")
    lines.append("locale =")

    # Plural
    bindings, body = get_elm_plural(rule)

    lines.append(f"    {{ code = {_quote(code)}")
    if not bindings:
        lines.append(f"    , plural = \\n -> {body}")
    else:
        lines.append("    , plural =")
        lines.append("        \\n ->")
        lines.append("            let")
        for bname, bexpr in bindings:
            lines.append(f"                {bname} =")
            lines.append(f"                    {bexpr}")
        lines.append("            in")
        lines.append(f"            {body}")

    # Units
    lines.append("    , units =")
    lines.append("        Dict.fromList")
    unit_names = ["second", "minute", "hour", "day", "week", "month", "year"]
    for i, unit_name in enumerate(unit_names):
        val = _unit_forms(data["units"][unit_name], indent=14)
        prefix = "[ " if i == 0 else ", "
        lines.append(f"            {prefix}( \"{unit_name}\", {val} )")
    lines.append("            ]")

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
    lines.append("")
    lines.append("import Dict exposing (Dict)")
    lines.append("import SayableDuration.Types exposing (Locale)")

    for loc in sorted_locs:
        mod = _module_name(loc["code"])
        lines.append(f"import SayableDuration.Locales.{mod} as {mod}")

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
