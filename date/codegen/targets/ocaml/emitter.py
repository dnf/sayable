"""OCaml locale emitter for sayable-date."""

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


def _str_map(d: dict[str, str], indent: int = 4) -> str:
    pad = " " * indent
    if not d:
        return "[]"
    pairs = [f"({_quote(k)}, {_quote(v)})" for k, v in d.items()]
    return "[ " + ("\n" + pad + "; ").join(pairs) + "\n" + pad + "]"


def _compactness_override(ovr: dict, indent: int = 4) -> str:
    pad = " " * indent
    lines = [f"{pad}{{ ovr_months = {_opt_list(ovr, 'months', indent + 2)}"]
    lines.append(f"{pad}; ovr_months_in_date = {_opt_list(ovr, 'monthsInDate', indent + 2)}")
    lines.append(f"{pad}; ovr_weekdays = {_opt_list(ovr, 'weekdays', indent + 2)}")
    lines.append(f"{pad}; ovr_day_format = {_opt_str(ovr, 'dayFormat')}")
    if "dayFormat" in ovr and "dayFormatExceptions" not in ovr:
        lines.append(f"{pad}; ovr_day_format_exceptions = Some []")
    else:
        lines.append(f"{pad}; ovr_day_format_exceptions = {_opt_map(ovr, 'dayFormatExceptions', indent + 2)}")
    lines.append(f"{pad}; ovr_date_pattern = {_opt_str(ovr, 'datePattern')}")
    lines.append(f"{pad}; ovr_date_pattern_with_year = {_opt_str(ovr, 'datePatternWithYear')}")
    lines.append(f"{pad}; ovr_today = {_opt_str(ovr, 'today')}")
    lines.append(f"{pad}; ovr_tomorrow = {_opt_str(ovr, 'tomorrow')}")
    lines.append(f"{pad}; ovr_yesterday = {_opt_str(ovr, 'yesterday')}")
    lines.append(f"{pad}}}")
    return "\n".join(lines)


def _opt_str(data: dict, key: str) -> str:
    if key in data:
        return f"Some {_quote(data[key])}"
    return "None"


def _opt_list(data: dict, key: str, indent: int) -> str:
    if key in data:
        return f"Some\n{' ' * indent}{_str_list(data[key], indent)}"
    return "None"


def _opt_map(data: dict, key: str, indent: int) -> str:
    if key in data:
        return f"Some\n{' ' * indent}{_str_map(data[key], indent)}"
    return "None"


def emit_locale(data: dict) -> str:
    code = data["code"]

    lines = [HEADER + locale_source_comment(code, line_prefix="(* ", line_suffix=" *)")]
    lines.append("open Types")
    lines.append("")
    lines.append("let locale : date_locale =")

    # Code
    lines.append(f"  {{ code = {_quote(code)}")

    # Months
    lines.append(f"  ; months =")
    lines.append(f"    {_str_list(data['months'], 4)}")

    # Weekdays
    lines.append(f"  ; weekdays =")
    lines.append(f"    {_str_list(data['weekdays'], 4)}")

    # Day format
    lines.append(f"  ; day_format = {_quote(data['dayFormat'])}")

    # Day format exceptions
    exceptions = data.get("dayFormatExceptions", {})
    lines.append(f"  ; day_format_exceptions =")
    lines.append(f"    {_str_map(exceptions, 4)}")

    # Date patterns
    lines.append(f"  ; date_pattern = {_quote(data['datePattern'])}")
    lines.append(f"  ; date_pattern_with_year = {_quote(data['datePatternWithYear'])}")

    # Required strings
    lines.append(f"  ; today = {_quote(data['today'])}")
    lines.append(f"  ; tomorrow = {_quote(data['tomorrow'])}")
    lines.append(f"  ; yesterday = {_quote(data['yesterday'])}")

    # Optional strings
    for key, field in [("dayAfterTomorrow", "day_after_tomorrow"),
                        ("dayBeforeYesterday", "day_before_yesterday"),
                        ("thisWeekday", "this_weekday"),
                        ("nextWeekday", "next_weekday"),
                        ("lastWeekday", "last_weekday")]:
        if key in data:
            lines.append(f"  ; {field} = Some {_quote(data[key])}")
        else:
            lines.append(f"  ; {field} = None")

    # Months in date (optional)
    if "monthsInDate" in data:
        lines.append(f"  ; months_in_date = Some")
        lines.append(f"    {_str_list(data['monthsInDate'], 4)}")
    else:
        lines.append(f"  ; months_in_date = None")

    # Short/compact
    for mode in ("short", "compact"):
        if mode in data:
            lines.append(f"  ; {mode} = Some")
            lines.append(_compactness_override(data[mode], indent=6))
        else:
            lines.append(f"  ; {mode} = None")

    lines.append("  }")
    lines.append("")

    return "\n".join(lines)


def emit_barrel(all_locales: list[dict]) -> str:
    """Generate the locales.ml barrel module."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER]
    lines.append("let get_locale (code : string) : Types.date_locale option =")
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
