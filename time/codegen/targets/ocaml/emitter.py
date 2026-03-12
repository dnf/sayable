"""OCaml locale emitter for sayable-time."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header

HEADER = make_header("codegen/targets/ocaml/emitter.py", line_prefix="(* ", line_suffix=" *)")


def _module_name(code: str) -> str:
    """Convert locale code to OCaml module name (capitalize first letter)."""
    return code[0].upper() + code[1:]


def _quote(s: str) -> str:
    escaped = s.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def _str_list(items: list[str], indent: int = 4) -> str:
    pad = " " * indent
    parts = [f"{_quote(s)}" for s in items]
    return "[ " + ("\n" + pad + "; ").join(parts) + "\n" + pad + "]"


def _patterns_list(patterns: dict[str, str], indent: int = 4) -> str:
    """Emit an OCaml association list for minute patterns."""
    pad = " " * indent
    keys = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55]
    pairs = []
    for key in keys:
        skey = str(key)
        if skey in patterns:
            pairs.append(f"({key}, {_quote(patterns[skey])})")
    return "[ " + ("\n" + pad + "; ").join(pairs) + "\n" + pad + "]"


def _clock_override(clock: dict, indent: int = 6) -> str:
    """Emit a short_clock_config record for short/compact overrides."""
    pad = " " * indent
    use24h = "true" if clock.get("use24h", True) else "false"
    am_pm = clock.get("amPm")
    fmt = clock.get("format", "{h}:{mm}")

    lines = [f"{pad}{{ use_24h = {use24h}"]
    lines.append(f"{pad}; format = {_quote(fmt)}")
    if am_pm:
        lines.append(f"{pad}; am_pm = Some ({_quote(am_pm[0])}, {_quote(am_pm[1])})")
    else:
        lines.append(f"{pad}; am_pm = None")
    lines.append(f"{pad}}}")
    return "\n".join(lines)


def emit_locale(data: dict) -> str:
    code = data["code"]
    clock = data["clock"]

    lines = [HEADER + locale_source_comment(code, line_prefix="(* ", line_suffix=" *)")]
    lines.append("open Types")
    lines.append("")
    lines.append("let locale : time_locale =")

    # Code
    lines.append(f"  {{ code = {_quote(code)}")

    # Clock config
    lines.append("  ; clock =")
    lines.append("    { hours =")
    lines.append(f"      {_str_list(clock['hours'], 6)}")
    lines.append(f"    ; midnight = {_quote(clock['midnight'])}")
    lines.append(f"    ; noon = {_quote(clock['noon'])}")
    lines.append("    ; patterns =")
    lines.append(f"      {_patterns_list(clock['patterns'], 6)}")
    lines.append("    }")

    # Short override
    if "short" in data:
        lines.append("  ; short = Some")
        lines.append("    { clock = Some")
        lines.append(_clock_override(data["short"]["clock"], indent=8))
        lines.append("    }")
    else:
        lines.append("  ; short = None")

    # Compact override
    if "compact" in data:
        lines.append("  ; compact = Some")
        lines.append("    { clock = Some")
        lines.append(_clock_override(data["compact"]["clock"], indent=8))
        lines.append("    }")
    else:
        lines.append("  ; compact = None")

    lines.append("  }")
    lines.append("")

    return "\n".join(lines)


def emit_barrel(all_locales: list[dict]) -> str:
    """Generate the locales.ml barrel module."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER]
    lines.append("let get_locale (code : string) : Types.time_locale option =")
    lines.append("  match code with")

    for loc in sorted_locs:
        code = loc["code"]
        mod = _module_name(code)
        lines.append(f'  | "{code}" -> Some {mod}.locale')

    lines.append("  | _ -> None")
    lines.append("")

    return "\n".join(lines)


def output_path(code: str, root: str) -> str:
    import os
    return os.path.join(root, "impl", "ocaml", "lib", "locales", f"{code}.ml")


def barrel_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "ocaml", "lib", "locales", "locales.ml")
