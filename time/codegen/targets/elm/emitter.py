"""Elm locale emitter for sayable-time."""

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


def _short_clock(sc: dict, indent: int = 4) -> str:
    """Emit a ShortClockConfig record."""
    pad = " " * indent
    use24h = "True" if sc.get("use24h", True) else "False"
    fmt = _quote(sc.get("format", "{h}:{mm}"))
    am_pm = sc.get("amPm")
    lines = [f"{pad}{{ use24h = {use24h}"]
    lines.append(f"{pad}, format = {fmt}")
    if am_pm:
        lines.append(f"{pad}, amPm = Just ( {_quote(am_pm[0])}, {_quote(am_pm[1])} )")
    else:
        lines.append(f"{pad}, amPm = Nothing")
    lines.append(f"{pad}}}")
    return "\n".join(lines)


def emit_locale(data: dict) -> str:
    """Generate an Elm locale file from canonical JSON."""
    code = data["code"]
    clock = data["clock"]
    mod = _module_name(code)

    lines = [HEADER + locale_source_comment(code, line_prefix="-- ")]
    lines.append("")
    lines.append(f"module SayableTime.Locales.{mod} exposing (locale)")
    lines.append("")
    lines.append("")
    lines.append("import Dict")
    lines.append("import SayableTime.Types exposing (..)")
    lines.append("")
    lines.append("")
    lines.append("locale : Locale")
    lines.append("locale =")
    lines.append(f"    {{ code = {_quote(code)}")

    # Clock config
    lines.append("    , clock =")
    lines.append("        { hours =")
    lines.append(_str_list(clock["hours"], indent=12))
    lines.append(f"        , midnight = {_quote(clock['midnight'])}")
    lines.append(f"        , noon = {_quote(clock['noon'])}")
    lines.append("        , patterns =")
    lines.append("            Dict.fromList")
    pattern_keys = ["0", "5", "10", "15", "20", "25", "30", "35", "40", "45", "50", "55"]
    entries = [(int(k), clock["patterns"][k]) for k in pattern_keys if k in clock["patterns"]]
    for i, (k, v) in enumerate(entries):
        prefix = "[ " if i == 0 else ", "
        lines.append(f"                {prefix}( {k}, {_quote(v)} )")
    lines.append("                ]")
    lines.append("        }")

    # Short override
    if "short" in data:
        sc = data["short"].get("clock", {})
        lines.append("    , short =")
        lines.append("        Just")
        lines.append("            { clock =")
        lines.append("                Just")
        lines.append(_short_clock(sc, indent=20))
        lines.append("            }")
    else:
        lines.append("    , short = Nothing")

    # Compact override
    if "compact" in data:
        sc = data["compact"].get("clock", {})
        lines.append("    , compact =")
        lines.append("        Just")
        lines.append("            { clock =")
        lines.append("                Just")
        lines.append(_short_clock(sc, indent=20))
        lines.append("            }")
    else:
        lines.append("    , compact = Nothing")

    lines.append("    }")
    lines.append("")

    return "\n".join(lines)


def emit_barrel(all_locales: list[dict]) -> str:
    """Generate the Locales.elm barrel module."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER]
    lines.append("")
    lines.append("module SayableTime.Locales exposing (getLocale)")
    lines.append("")
    lines.append("")
    lines.append("import Dict exposing (Dict)")
    lines.append("import SayableTime.Types exposing (Locale)")

    for loc in sorted_locs:
        mod = _module_name(loc["code"])
        lines.append(f"import SayableTime.Locales.{mod} as {mod}")

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
    return os.path.join(root, "impl", "elm", "src", "SayableTime", "Locales", f"{mod}.elm")


def barrel_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "elm", "src", "SayableTime", "Locales.elm")
