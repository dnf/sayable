"""Haskell locale emitter."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header
from codegen.targets.haskell.plural_rules import get_hs_plural

HEADER = make_header("codegen/targets/haskell/emitter.py", line_prefix="-- ")

_CAT_MAP = {
    "zero": "Zero", "one": "One", "two": "Two",
    "few": "Few", "many": "Many", "other": "Other",
}


def _module_name(code: str) -> str:
    """Convert locale code to Haskell module name (capitalize first letter)."""
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
            pairs.append(f"({_CAT_MAP[cat]}, {_quote(unit[cat])})")
    return "Pluralized\n" + pad + "[ " + ("\n" + pad + ", ").join(pairs) + "\n" + pad + "]"


def _stage_label(stage: object) -> str:
    if isinstance(stage, str):
        return f"Neutral {_quote(stage)}"
    return f"Gendered {_quote(stage['m'])} {_quote(stage['f'])}"


def _compactness_override(ovr: dict, indent: int = 4) -> str:
    pad = " " * indent
    lines = [f"{pad}CompactnessOverride"]
    lines.append(f"{pad}    {{ ovrDay = {_ovr_unit(ovr, 'day', indent + 4)}")
    lines.append(f"{pad}    , ovrWeek = {_ovr_unit(ovr, 'week', indent + 4)}")
    lines.append(f"{pad}    , ovrMonth = {_ovr_unit(ovr, 'month', indent + 4)}")
    lines.append(f"{pad}    , ovrYear = {_ovr_unit(ovr, 'year', indent + 4)}")
    if "half" in ovr:
        lines.append(f"{pad}    , ovrHalf = Just {_quote(ovr['half'])}")
    else:
        lines.append(f"{pad}    , ovrHalf = Nothing")
    if "delimiter" in ovr:
        lines.append(f"{pad}    , ovrDelimiter = Just {_quote(ovr['delimiter'])}")
    else:
        lines.append(f"{pad}    , ovrDelimiter = Nothing")
    if "justBorn" in ovr:
        lines.append(f"{pad}    , ovrJustBorn = Just {_quote(ovr['justBorn'])}")
    else:
        lines.append(f"{pad}    , ovrJustBorn = Nothing")
    lines.append(f"{pad}    }}")
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
    lines.append(f"module ParentTime.Locales.{mod} (locale) where")
    lines.append("")
    lines.append("import ParentTime.Types")
    lines.append("")
    lines.append("locale :: Locale")
    lines.append("locale = Locale")
    lines.append(f"    {{ localeCode = {_quote(code)}")

    # Plural
    plural = get_hs_plural(rule)
    lines.append(f"    , localePlural = {plural}")

    # Units
    for unit_name in ("day", "week", "month", "year"):
        field = f"locale{unit_name.capitalize()}"
        val = _unit_forms(data["units"][unit_name], indent=6)
        lines.append(f"    , {field} = {val}")

    # Simple fields
    lines.append(f"    , localeHalf = {_quote(data['half'])}")
    lines.append(f"    , localeDelimiter = {_quote(data['delimiter'])}")
    lines.append(f"    , localeJustBorn = {_quote(data['justBorn'])}")

    # Stages
    lines.append("    , localeStages = Stages")
    stages = data["stages"]
    stage_names = ["newborn", "infant", "toddler", "child", "teenager", "adult"]
    for i, stage in enumerate(stage_names):
        prefix = "{ " if i == 0 else ", "
        field = f"stage{stage.capitalize()}"
        val = _stage_label(stages[stage])
        lines.append(f"        {prefix}{field} = {val}")
    lines.append("        }")

    # Short/compact
    for mode in ("short", "compact"):
        field = f"locale{mode.capitalize()}"
        if mode in data:
            lines.append(f"    , {field} = Just $")
            lines.append(_compactness_override(data[mode], indent=8))
        else:
            lines.append(f"    , {field} = Nothing")

    lines.append("    }")
    lines.append("")

    return "\n".join(lines)


def emit_barrel(all_locales: list[dict]) -> str:
    """Generate the Locales.hs barrel module."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER]
    lines.append("module ParentTime.Locales (getLocale) where")
    lines.append("")
    lines.append("import ParentTime.Types (Locale)")

    # Qualified imports
    for loc in sorted_locs:
        mod = _module_name(loc["code"])
        lines.append(f"import qualified ParentTime.Locales.{mod} as {mod}")

    lines.append("")
    lines.append("getLocale :: String -> Maybe Locale")

    for loc in sorted_locs:
        code = loc["code"]
        mod = _module_name(code)
        lines.append(f'getLocale "{code}" = Just {mod}.locale')

    lines.append("getLocale _ = Nothing")
    lines.append("")

    return "\n".join(lines)


def output_path(code: str, root: str) -> str:
    import os
    mod = _module_name(code)
    return os.path.join(root, "src", "haskell", "src", "ParentTime", "Locales", f"{mod}.hs")


def barrel_path(root: str) -> str:
    import os
    return os.path.join(root, "src", "haskell", "src", "ParentTime", "Locales.hs")
