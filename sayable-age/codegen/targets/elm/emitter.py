"""Elm locale emitter."""

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


def _stage_label(stage: object) -> str:
    if isinstance(stage, str):
        return f"Neutral {_quote(stage)}"
    return f"Gendered {_quote(stage['m'])} {_quote(stage['f'])}"


def _compactness_override(ovr: dict, indent: int = 4) -> str:
    pad = " " * indent
    lines = [f"{pad}{{ ovrDay = {_ovr_unit(ovr, 'day', indent + 4)}"]
    lines.append(f"{pad}, ovrWeek = {_ovr_unit(ovr, 'week', indent + 4)}")
    lines.append(f"{pad}, ovrMonth = {_ovr_unit(ovr, 'month', indent + 4)}")
    lines.append(f"{pad}, ovrYear = {_ovr_unit(ovr, 'year', indent + 4)}")
    if "half" in ovr:
        lines.append(f"{pad}, ovrHalf = Just {_quote(ovr['half'])}")
    else:
        lines.append(f"{pad}, ovrHalf = Nothing")
    if "delimiter" in ovr:
        lines.append(f"{pad}, ovrDelimiter = Just {_quote(ovr['delimiter'])}")
    else:
        lines.append(f"{pad}, ovrDelimiter = Nothing")
    if "justBorn" in ovr:
        lines.append(f"{pad}, ovrJustBorn = Just {_quote(ovr['justBorn'])}")
    else:
        lines.append(f"{pad}, ovrJustBorn = Nothing")
    lines.append(f"{pad}}}")
    return "\n".join(lines)


def _ovr_unit(ovr: dict, unit_name: str, indent: int) -> str:
    if "units" in ovr and unit_name in ovr["units"]:
        val = ovr["units"][unit_name]
        return f"Just ({_unit_forms(val, indent + 2)})"
    return "Nothing"


def emit_locale(data: dict) -> str:
    code = data["code"]
    rule = data["pluralRule"]
    mod = _module_name(code)

    lines = [HEADER + locale_source_comment(code, line_prefix="-- ")]
    lines.append("")
    lines.append(f"module SayableAge.Locales.{mod} exposing (locale)")
    lines.append("")
    lines.append("")
    lines.append("import SayableAge.Types exposing (..)")
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
    for unit_name in ("day", "week", "month", "year"):
        val = _unit_forms(data["units"][unit_name], indent=6)
        lines.append(f"    , {unit_name} = {val}")

    # Simple fields
    lines.append(f"    , half = {_quote(data['half'])}")
    lines.append(f"    , delimiter = {_quote(data['delimiter'])}")
    lines.append(f"    , justBorn = {_quote(data['justBorn'])}")

    # Stages
    stages = data["stages"]
    stage_names = ["newborn", "infant", "toddler", "child", "teenager", "adult"]
    lines.append("    , stages =")
    for i, stage in enumerate(stage_names):
        prefix = "{ " if i == 0 else ", "
        val = _stage_label(stages[stage])
        lines.append(f"        {prefix}{stage} = {val}")
    lines.append("        }")

    # Short/compact
    for mode in ("short", "compact"):
        if mode in data:
            lines.append(f"    , {mode} =")
            lines.append(f"        Just")
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
    lines.append("module SayableAge.Locales exposing (getLocale)")
    lines.append("")
    lines.append("")
    lines.append("import Dict exposing (Dict)")
    lines.append("import SayableAge.Types exposing (Locale)")

    # Imports
    for loc in sorted_locs:
        mod = _module_name(loc["code"])
        lines.append(f"import SayableAge.Locales.{mod} as {mod}")

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
    return os.path.join(root, "src", "elm", "src", "SayableAge", "Locales", f"{mod}.elm")


def barrel_path(root: str) -> str:
    import os
    return os.path.join(root, "src", "elm", "src", "SayableAge", "Locales.elm")
