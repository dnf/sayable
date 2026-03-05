"""Haskell locale emitter for sayable-time — per-file with barrel."""

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


def _emit_clock_config(clock: dict, indent: int = 4) -> str:
    pad = " " * indent
    lines = [f"{pad}ClockConfig"]
    # hours
    hours_str = ", ".join(_quote(h) for h in clock["hours"])
    lines.append(f"{pad}    {{ clockHours = [{hours_str}]")
    lines.append(f"{pad}    , clockMidnight = {_quote(clock['midnight'])}")
    lines.append(f"{pad}    , clockNoon = {_quote(clock['noon'])}")
    # patterns
    patterns = clock["patterns"]
    sorted_keys = sorted(patterns.keys(), key=int)
    pat_entries = []
    for k in sorted_keys:
        pat_entries.append(f"({k}, {_quote(patterns[k])})")
    lines.append(f"{pad}    , clockPatterns =")
    lines.append(f"{pad}        [ " + ("\n" + f"{pad}        , ").join(pat_entries))
    lines.append(f"{pad}        ]")
    lines.append(f"{pad}    }}")
    return "\n".join(lines)


def _emit_short_clock(sc: dict, indent: int = 4) -> str:
    pad = " " * indent
    lines = [f"{pad}ShortClockConfig"]
    lines.append(f"{pad}    {{ shortUse24h = {'True' if sc['use24h'] else 'False'}")
    if "amPm" in sc:
        lines.append(f"{pad}    , shortAmPm = Just ({_quote(sc['amPm'][0])}, {_quote(sc['amPm'][1])})")
    else:
        lines.append(f"{pad}    , shortAmPm = Nothing")
    lines.append(f"{pad}    , shortFormat = {_quote(sc['format'])}")
    lines.append(f"{pad}    }}")
    return "\n".join(lines)


def emit_locale(data: dict) -> str:
    code = data["code"]
    mod = _module_name(code)

    lines = [HEADER + locale_source_comment(code, line_prefix="-- ")]
    lines.append(f"module SayableTime.Locales.{mod} (locale) where")
    lines.append("")
    lines.append("import SayableTime.Types")
    lines.append("")
    lines.append("locale :: TimeLocale")
    lines.append("locale = TimeLocale")
    lines.append(f"    {{ localeCode = {_quote(code)}")

    # Clock config
    lines.append("    , localeClock =")
    lines.append(_emit_clock_config(data["clock"], indent=8))

    # Short/compact
    for mode in ("short", "compact"):
        field = f"locale{mode.capitalize()}"
        if mode in data:
            ovr = data[mode]
            if "clock" in ovr:
                lines.append(f"    , {field} = Just $ CompactnessOverride $ Just $")
                lines.append(_emit_short_clock(ovr["clock"], indent=8))
            else:
                lines.append(f"    , {field} = Just $ CompactnessOverride Nothing")
        else:
            lines.append(f"    , {field} = Nothing")

    lines.append("    }")
    lines.append("")

    return "\n".join(lines)


def emit_barrel(all_locales: list[dict]) -> str:
    """Generate the Locales.hs barrel module."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER]
    lines.append("module SayableTime.Locales (getLocale) where")
    lines.append("")
    lines.append("import SayableTime.Types (TimeLocale)")

    # Qualified imports
    for loc in sorted_locs:
        mod = _module_name(loc["code"])
        lines.append(f"import qualified SayableTime.Locales.{mod} as {mod}")

    lines.append("")
    lines.append("getLocale :: String -> Maybe TimeLocale")

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
    return os.path.join(root, "impl", "haskell", "src", "SayableTime", "Locales", f"{mod}.hs")


def barrel_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "haskell", "src", "SayableTime", "Locales.hs")
