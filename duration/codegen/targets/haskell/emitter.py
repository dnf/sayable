"""Haskell locale emitter for sayable-duration — per-file with barrel."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header
from codegen.targets.haskell.plural_rules import get_hs_plural

HEADER = make_header("codegen/targets/haskell/emitter.py", line_prefix="-- ")

_CAT_MAP = {
    "zero": "Zero", "one": "One", "two": "Two",
    "few": "Few", "many": "Many", "other": "Other",
}

_UNIT_NAMES = ("second", "minute", "hour", "day", "week", "month", "year")

_UNIT_FIELDS = {
    "second": "unitSecond", "minute": "unitMinute", "hour": "unitHour",
    "day": "unitDay", "week": "unitWeek", "month": "unitMonth", "year": "unitYear",
}

_OVR_FIELDS = {
    "second": "ovrSecond", "minute": "ovrMinute", "hour": "ovrHour",
    "day": "ovrDay", "week": "ovrWeek", "month": "ovrMonth", "year": "ovrYear",
}


def _module_name(code: str) -> str:
    """Convert locale code to Haskell module name (capitalize first letter)."""
    return code[0].upper() + code[1:]


def _quote(s: str) -> str:
    import unicodedata

    buf = []
    for ch in s:
        if ch == "\\":
            buf.append("\\\\")
        elif ch == '"':
            buf.append('\\"')
        elif unicodedata.category(ch) == "Cf":
            # GHC lexer rejects Unicode format characters (Cf) in string
            # literals — escape them as decimal code points (\NNNN).
            buf.append(f"\\{ord(ch)}")
        else:
            buf.append(ch)
    return '"' + "".join(buf) + '"'


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


def _compactness_override(ovr: dict, indent: int = 4) -> str:
    pad = " " * indent
    lines = [f"{pad}CompactnessOverride"]
    # Unit overrides
    for unit_name in _UNIT_NAMES:
        field = _OVR_FIELDS[unit_name]
        prefix = "{ " if unit_name == "second" else ", "
        if "units" in ovr and unit_name in ovr["units"]:
            val = ovr["units"][unit_name]
            lines.append(f"{pad}    {prefix}{field} = Just ({_unit_forms(val, indent + 6)})")
        else:
            lines.append(f"{pad}    {prefix}{field} = Nothing")
    # half
    if "half" in ovr:
        lines.append(f"{pad}    , ovrHalf = Just {_quote(ovr['half'])}")
    else:
        lines.append(f"{pad}    , ovrHalf = Nothing")
    # delimiter
    if "delimiter" in ovr:
        lines.append(f"{pad}    , ovrDelimiter = Just {_quote(ovr['delimiter'])}")
    else:
        lines.append(f"{pad}    , ovrDelimiter = Nothing")
    # ago
    if "ago" in ovr:
        lines.append(f"{pad}    , ovrAgo = Just {_quote(ovr['ago'])}")
    else:
        lines.append(f"{pad}    , ovrAgo = Nothing")
    # inFuture
    if "inFuture" in ovr:
        lines.append(f"{pad}    , ovrInFuture = Just {_quote(ovr['inFuture'])}")
    else:
        lines.append(f"{pad}    , ovrInFuture = Nothing")
    lines.append(f"{pad}    }}")
    return "\n".join(lines)


def emit_locale(data: dict) -> str:
    code = data["code"]
    rule = data["pluralRule"]
    mod = _module_name(code)

    lines = [HEADER + locale_source_comment(code, line_prefix="-- ")]
    lines.append(f"module SayableDuration.Locales.{mod} (locale) where")
    lines.append("")
    lines.append("import SayableDuration.Types")
    lines.append("")
    lines.append("locale :: DurationLocale")
    lines.append("locale = DurationLocale")
    lines.append(f"    {{ localeCode = {_quote(code)}")

    # Plural
    plural = get_hs_plural(rule)
    lines.append(f"    , localePlural = {plural}")

    # Units
    lines.append("    , localeUnits = Units")
    for i, unit_name in enumerate(_UNIT_NAMES):
        field = _UNIT_FIELDS[unit_name]
        val = _unit_forms(data["units"][unit_name], indent=10)
        prefix = "{ " if i == 0 else ", "
        lines.append(f"        {prefix}{field} = {val}")
    lines.append("        }")

    # Simple fields
    lines.append(f"    , localeHalf = {_quote(data['half'])}")
    lines.append(f"    , localeDelimiter = {_quote(data['delimiter'])}")
    lines.append(f"    , localeJustNow = {_quote(data['justNow'])}")
    lines.append(f"    , localeAgo = {_quote(data['ago'])}")
    lines.append(f"    , localeInFuture = {_quote(data['inFuture'])}")

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
    lines.append("module SayableDuration.Locales (getLocale) where")
    lines.append("")
    lines.append("import SayableDuration.Types (DurationLocale)")

    # Qualified imports
    for loc in sorted_locs:
        mod = _module_name(loc["code"])
        lines.append(f"import qualified SayableDuration.Locales.{mod} as {mod}")

    lines.append("")
    lines.append("getLocale :: String -> Maybe DurationLocale")

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
    return os.path.join(root, "impl", "haskell", "src", "SayableDuration", "Locales", f"{mod}.hs")


def barrel_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "haskell", "src", "SayableDuration", "Locales.hs")
