"""Haskell locale emitter for sayable-date — per-file with barrel."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header

HEADER = make_header("codegen/targets/haskell/emitter.py", line_prefix="-- ")


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


def _string_list(items: list[str], indent: int = 8) -> str:
    pad = " " * indent
    quoted = [_quote(s) for s in items]
    return pad + "[ " + ("\n" + pad + ", ").join(quoted) + "\n" + pad + "]"


def _map_entries(d: dict, indent: int = 8) -> str:
    pad = " " * indent
    if not d:
        return pad + "[]"
    entries = [f"({_quote(k)}, {_quote(v)})" for k, v in d.items()]
    return pad + "[ " + ("\n" + pad + ", ").join(entries) + "\n" + pad + "]"


def _compactness_override(ovr: dict, indent: int = 4) -> str:
    pad = " " * indent
    lines = [f"{pad}CompactnessOverride"]

    # months
    if "months" in ovr:
        lines.append(f"{pad}    {{ ovrMonths = Just $")
        lines.append(_string_list(ovr["months"], indent + 8))
    else:
        lines.append(f"{pad}    {{ ovrMonths = Nothing")

    # monthsInDate
    if "monthsInDate" in ovr:
        lines.append(f"{pad}    , ovrMonthsInDate = Just $")
        lines.append(_string_list(ovr["monthsInDate"], indent + 8))
    else:
        lines.append(f"{pad}    , ovrMonthsInDate = Nothing")

    # weekdays
    if "weekdays" in ovr:
        lines.append(f"{pad}    , ovrWeekdays = Just $")
        lines.append(_string_list(ovr["weekdays"], indent + 8))
    else:
        lines.append(f"{pad}    , ovrWeekdays = Nothing")

    # dayFormat
    if "dayFormat" in ovr:
        lines.append(f"{pad}    , ovrDayFormat = Just {_quote(ovr['dayFormat'])}")
    else:
        lines.append(f"{pad}    , ovrDayFormat = Nothing")

    # dayFormatExceptions
    if "dayFormatExceptions" in ovr:
        lines.append(f"{pad}    , ovrDayFormatExceptions = Just $")
        lines.append(_map_entries(ovr["dayFormatExceptions"], indent + 8))
    else:
        lines.append(f"{pad}    , ovrDayFormatExceptions = Nothing")

    # datePattern
    if "datePattern" in ovr:
        lines.append(f"{pad}    , ovrDatePattern = Just {_quote(ovr['datePattern'])}")
    else:
        lines.append(f"{pad}    , ovrDatePattern = Nothing")

    # datePatternWithYear
    if "datePatternWithYear" in ovr:
        lines.append(f"{pad}    , ovrDatePatternWithYear = Just {_quote(ovr['datePatternWithYear'])}")
    else:
        lines.append(f"{pad}    , ovrDatePatternWithYear = Nothing")

    # today
    if "today" in ovr:
        lines.append(f"{pad}    , ovrToday = Just {_quote(ovr['today'])}")
    else:
        lines.append(f"{pad}    , ovrToday = Nothing")

    # tomorrow
    if "tomorrow" in ovr:
        lines.append(f"{pad}    , ovrTomorrow = Just {_quote(ovr['tomorrow'])}")
    else:
        lines.append(f"{pad}    , ovrTomorrow = Nothing")

    # yesterday
    if "yesterday" in ovr:
        lines.append(f"{pad}    , ovrYesterday = Just {_quote(ovr['yesterday'])}")
    else:
        lines.append(f"{pad}    , ovrYesterday = Nothing")

    lines.append(f"{pad}    }}")
    return "\n".join(lines)


def emit_locale(data: dict) -> str:
    code = data["code"]
    mod = _module_name(code)

    lines = [HEADER + locale_source_comment(code, line_prefix="-- ")]
    lines.append(f"module SayableDate.Locales.{mod} (locale) where")
    lines.append("")
    lines.append("import SayableDate.Types")
    lines.append("")
    lines.append("locale :: DateLocale")
    lines.append("locale = DateLocale")
    lines.append(f"    {{ localeCode = {_quote(code)}")

    # months
    lines.append("    , localeMonths =")
    lines.append(_string_list(data["months"], indent=8))

    # weekdays
    lines.append("    , localeWeekdays =")
    lines.append(_string_list(data["weekdays"], indent=8))

    # dayFormat
    lines.append(f"    , localeDayFormat = {_quote(data['dayFormat'])}")

    # dayFormatExceptions
    if "dayFormatExceptions" in data and data["dayFormatExceptions"]:
        lines.append("    , localeDayFormatExceptions =")
        lines.append(_map_entries(data["dayFormatExceptions"], indent=8))
    else:
        lines.append("    , localeDayFormatExceptions = []")

    # datePattern
    lines.append(f"    , localeDatePattern = {_quote(data.get('datePattern', '{day} {month}'))}")

    # datePatternWithYear
    lines.append(f"    , localeDatePatternWithYear = {_quote(data.get('datePatternWithYear', '{day} {month} {year}'))}")

    # today/tomorrow/yesterday
    lines.append(f"    , localeToday = {_quote(data.get('today', 'today'))}")
    lines.append(f"    , localeTomorrow = {_quote(data.get('tomorrow', 'tomorrow'))}")
    lines.append(f"    , localeYesterday = {_quote(data.get('yesterday', 'yesterday'))}")

    # Optional fields
    for field, key in [("localeDayAfterTomorrow", "dayAfterTomorrow"),
                       ("localeDayBeforeYesterday", "dayBeforeYesterday"),
                       ("localeThisWeekday", "thisWeekday"),
                       ("localeNextWeekday", "nextWeekday"),
                       ("localeLastWeekday", "lastWeekday")]:
        if key in data and data[key] is not None:
            lines.append(f"    , {field} = Just {_quote(data[key])}")
        else:
            lines.append(f"    , {field} = Nothing")

    # monthsInDate
    if "monthsInDate" in data and data["monthsInDate"] is not None:
        lines.append("    , localeMonthsInDate = Just $")
        lines.append(_string_list(data["monthsInDate"], indent=8))
    else:
        lines.append("    , localeMonthsInDate = Nothing")

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
    lines.append("module SayableDate.Locales (getLocale) where")
    lines.append("")
    lines.append("import SayableDate.Types (DateLocale)")

    # Qualified imports
    for loc in sorted_locs:
        mod = _module_name(loc["code"])
        lines.append(f"import qualified SayableDate.Locales.{mod} as {mod}")

    lines.append("")
    lines.append("getLocale :: String -> Maybe DateLocale")

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
    return os.path.join(root, "impl", "haskell", "src", "SayableDate", "Locales", f"{mod}.hs")


def barrel_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "haskell", "src", "SayableDate", "Locales.hs")
