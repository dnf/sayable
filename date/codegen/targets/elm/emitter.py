"""Elm locale emitter for sayable-date."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header

HEADER = make_header("codegen/targets/elm/emitter.py", line_prefix="-- ")


def _module_name(code: str) -> str:
    """Convert locale code to Elm module name (capitalize first letter)."""
    return code[0].upper() + code[1:]


def _quote(s: str) -> str:
    escaped = s.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def _str_list(items: list[str], indent: int = 4) -> str:
    """Emit an Elm list of strings."""
    pad = " " * indent
    parts = []
    for i, item in enumerate(items):
        prefix = "[ " if i == 0 else ", "
        parts.append(f"{pad}{prefix}{_quote(item)}")
    parts.append(f"{pad}]")
    return "\n".join(parts)


def _dict_entries(d: dict[str, str], indent: int = 4) -> str:
    """Emit Dict.fromList entries."""
    pad = " " * indent
    parts = []
    for i, (k, v) in enumerate(d.items()):
        prefix = "[ " if i == 0 else ", "
        parts.append(f"{pad}{prefix}( {_quote(k)}, {_quote(v)} )")
    parts.append(f"{pad}]")
    return "\n".join(parts)


def _compactness_override(ovr: dict, indent: int = 4) -> str:
    """Emit a CompactnessOverride record."""
    pad = " " * indent

    def _maybe_list(key: str) -> str:
        if key in ovr:
            return f"Just\n{_str_list(ovr[key], indent + 4)}"
        return "Nothing"

    def _maybe_str(key: str) -> str:
        if key in ovr:
            return f"Just {_quote(ovr[key])}"
        return "Nothing"

    def _maybe_dict(key: str) -> str:
        if key in ovr and ovr[key]:
            return f"Just\n{pad}    (Dict.fromList\n{_dict_entries(ovr[key], indent + 8)}\n{pad}    )"
        return "Nothing"

    lines = [f"{pad}{{ ovrMonths = {_maybe_list('months')}"]
    lines.append(f"{pad}, ovrMonthsInDate = {_maybe_list('monthsInDate')}")
    lines.append(f"{pad}, ovrWeekdays = {_maybe_list('weekdays')}")
    lines.append(f"{pad}, ovrDayFormat = {_maybe_str('dayFormat')}")

    if "dayFormat" in ovr and "dayFormatExceptions" not in ovr:
        lines.append(f"{pad}, ovrDayFormatExceptions = Just Dict.empty")
    else:
        lines.append(f"{pad}, ovrDayFormatExceptions = {_maybe_dict('dayFormatExceptions')}")

    lines.append(f"{pad}, ovrDatePattern = {_maybe_str('datePattern')}")
    lines.append(f"{pad}, ovrDatePatternWithYear = {_maybe_str('datePatternWithYear')}")
    lines.append(f"{pad}, ovrToday = {_maybe_str('today')}")
    lines.append(f"{pad}, ovrTomorrow = {_maybe_str('tomorrow')}")
    lines.append(f"{pad}, ovrYesterday = {_maybe_str('yesterday')}")
    lines.append(f"{pad}}}")
    return "\n".join(lines)


def emit_locale(data: dict) -> str:
    """Generate an Elm locale file from canonical JSON."""
    code = data["code"]
    mod = _module_name(code)

    lines = [HEADER + locale_source_comment(code, line_prefix="-- ")]
    lines.append("")
    lines.append(f"module SayableDate.Locales.{mod} exposing (locale)")
    lines.append("")
    lines.append("")
    lines.append("import Dict")
    lines.append("import SayableDate.Types exposing (..)")
    lines.append("")
    lines.append("")
    lines.append("locale : Locale")
    lines.append("locale =")
    lines.append(f"    {{ code = {_quote(code)}")
    lines.append("    , months =")
    lines.append(_str_list(data["months"], indent=8))
    lines.append("    , weekdays =")
    lines.append(_str_list(data["weekdays"], indent=8))
    lines.append(f"    , dayFormat = {_quote(data['dayFormat'])}")

    if "dayFormatExceptions" in data and data["dayFormatExceptions"]:
        lines.append("    , dayFormatExceptions =")
        lines.append("        Dict.fromList")
        lines.append(_dict_entries(data["dayFormatExceptions"], indent=12))
    else:
        lines.append("    , dayFormatExceptions = Dict.empty")

    lines.append(f"    , datePattern = {_quote(data['datePattern'])}")
    lines.append(f"    , datePatternWithYear = {_quote(data['datePatternWithYear'])}")
    lines.append(f"    , today = {_quote(data['today'])}")
    lines.append(f"    , tomorrow = {_quote(data['tomorrow'])}")
    lines.append(f"    , yesterday = {_quote(data['yesterday'])}")

    # Optional proximity fields
    if "dayAfterTomorrow" in data:
        lines.append(f"    , dayAfterTomorrow = Just {_quote(data['dayAfterTomorrow'])}")
    else:
        lines.append("    , dayAfterTomorrow = Nothing")

    if "dayBeforeYesterday" in data:
        lines.append(f"    , dayBeforeYesterday = Just {_quote(data['dayBeforeYesterday'])}")
    else:
        lines.append("    , dayBeforeYesterday = Nothing")

    if "thisWeekday" in data:
        lines.append(f"    , thisWeekday = Just {_quote(data['thisWeekday'])}")
    else:
        lines.append("    , thisWeekday = Nothing")

    if "nextWeekday" in data:
        lines.append(f"    , nextWeekday = Just {_quote(data['nextWeekday'])}")
    else:
        lines.append("    , nextWeekday = Nothing")

    if "lastWeekday" in data:
        lines.append(f"    , lastWeekday = Just {_quote(data['lastWeekday'])}")
    else:
        lines.append("    , lastWeekday = Nothing")

    if "monthsInDate" in data:
        lines.append("    , monthsInDate =")
        lines.append("        Just")
        lines.append(_str_list(data["monthsInDate"], indent=12))
    else:
        lines.append("    , monthsInDate = Nothing")

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
    lines.append("module SayableDate.Locales exposing (getLocale)")
    lines.append("")
    lines.append("")
    lines.append("import Dict exposing (Dict)")
    lines.append("import SayableDate.Types exposing (Locale)")

    # Imports
    for loc in sorted_locs:
        mod = _module_name(loc["code"])
        lines.append(f"import SayableDate.Locales.{mod} as {mod}")

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
    return os.path.join(root, "impl", "elm", "src", "SayableDate", "Locales", f"{mod}.elm")


def barrel_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "elm", "src", "SayableDate", "Locales.elm")
