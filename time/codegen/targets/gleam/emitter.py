"""Gleam locale emitter for sayable-time."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header

HEADER = make_header("codegen/targets/gleam/emitter.py")


def _module_name(code: str) -> str:
    """Convert locale code to Gleam module name (lowercase, hyphens to underscores)."""
    return code.replace("-", "_")


def _quote(s: str) -> str:
    escaped = s.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def _str_list(items: list[str]) -> str:
    return "[" + ", ".join(_quote(s) for s in items) + "]"


def emit_locale(data: dict) -> str:
    code = data["code"]
    clock = data["clock"]

    lines = [HEADER + locale_source_comment(code)]
    lines.append("import sayabletime/types")
    lines.append("")
    lines.append("pub fn locale() -> types.TimeLocale {")
    lines.append("  types.TimeLocale(")

    # Code
    lines.append(f"    code: {_quote(code)},")

    # Clock config
    lines.append("    clock: types.ClockConfig(")
    lines.append(f"      hours: {_str_list(clock['hours'])},")
    lines.append(f"      midnight: {_quote(clock['midnight'])},")
    lines.append(f"      noon: {_quote(clock['noon'])},")
    lines.append("      patterns: [")
    for key in ("0", "5", "10", "15", "20", "25", "30", "35", "40", "45", "50", "55"):
        if key in clock["patterns"]:
            lines.append(f"        #({key}, {_quote(clock['patterns'][key])}),")
    lines.append("      ],")
    lines.append("    ),")

    # Short/compact overrides
    for mode in ("short", "compact"):
        if mode in data:
            sc = data[mode].get("clock", {})
            use24h = "True" if sc.get("use24h", True) else "False"
            fmt = sc.get("format", "{h}:{mm}")
            am_pm = sc.get("amPm")
            lines.append(f"    {mode}: Ok(types.CompactnessOverride(")
            if am_pm:
                lines.append(f"      clock: Ok(types.ShortClockConfig(use24h: {use24h}, format: {_quote(fmt)}, am_pm: Ok(#({_quote(am_pm[0])}, {_quote(am_pm[1])})))),")
            else:
                lines.append(f"      clock: Ok(types.ShortClockConfig(use24h: {use24h}, format: {_quote(fmt)}, am_pm: Error(Nil))),")
            lines.append("    )),")
        else:
            lines.append(f"    {mode}: Error(Nil),")

    lines.append("  )")
    lines.append("}")
    lines.append("")

    return "\n".join(lines)


def emit_registry(all_locales: list[dict]) -> str:
    """Generate the locales module with get(code) function."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER]
    lines.append("import sayabletime/types")

    for loc in sorted_locs:
        code = loc["code"]
        mod = _module_name(code)
        lines.append(f"import sayabletime/locales/{mod} as locale_{mod}")
    lines.append("")

    lines.append("pub fn get(code: String) -> Result(types.TimeLocale, Nil) {")
    lines.append("  case code {")
    for loc in sorted_locs:
        code = loc["code"]
        mod = _module_name(code)
        lines.append(f"    {_quote(code)} -> Ok(locale_{mod}.locale())")
    lines.append("    _ -> Error(Nil)")
    lines.append("  }")
    lines.append("}")
    lines.append("")

    return "\n".join(lines)


def output_path(code: str, root: str) -> str:
    import os
    mod = code.replace("-", "_")
    return os.path.join(root, "impl", "gleam", "src", "sayabletime", "locales", f"{mod}.gleam")


def registry_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "gleam", "src", "sayabletime", "locales", "locales.gleam")
