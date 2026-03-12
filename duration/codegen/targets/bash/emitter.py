"""Bash locale emitter for sayable-duration."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header
from codegen.targets.bash.plural_rules import get_bash_plural

HEADER = make_header("codegen/targets/bash/emitter.py", line_prefix="# ")


def _quote(s: str) -> str:
    """Quote a string for Bash using single quotes with proper escaping."""
    return "'" + s.replace("'", "'\\''") + "'"


def emit_locale(data: dict) -> str:
    code = data["code"]
    rule = data["pluralRule"]

    lines = [HEADER + locale_source_comment(code, line_prefix="# ")]

    # Plural rule function
    plural_body = get_bash_plural(rule).replace("$CODE", code)
    lines.append(plural_body)
    lines.append("")

    # Locale data function that sets variables in the caller's scope
    lines.append(f"_locale_{code}() {{")

    # Units
    for unit_name in ("second", "minute", "hour", "day", "week", "month", "year"):
        unit = data["units"][unit_name]
        if isinstance(unit, str):
            lines.append(f"    _unit_{unit_name}={_quote(unit)}")
        else:
            cats = ["zero", "one", "two", "few", "many", "other"]
            for cat in cats:
                if cat in unit:
                    lines.append(f"    _unit_{unit_name}_{cat}={_quote(unit[cat])}")

    # Simple fields
    lines.append(f"    _half={_quote(data['half'])}")
    lines.append(f"    _delimiter={_quote(data['delimiter'])}")
    lines.append(f"    _just_now={_quote(data['justNow'])}")
    lines.append(f"    _ago={_quote(data['ago'])}")
    lines.append(f"    _in_future={_quote(data['inFuture'])}")

    # Short/compact overrides
    for mode in ("short", "compact"):
        if mode in data:
            ovr = data[mode]
            if "units" in ovr:
                for unit_name in ("second", "minute", "hour", "day", "week", "month", "year"):
                    if unit_name in ovr["units"]:
                        unit = ovr["units"][unit_name]
                        if isinstance(unit, str):
                            lines.append(f"    _{mode}_unit_{unit_name}={_quote(unit)}")
                        else:
                            cats = ["zero", "one", "two", "few", "many", "other"]
                            for cat in cats:
                                if cat in unit:
                                    lines.append(f"    _{mode}_unit_{unit_name}_{cat}={_quote(unit[cat])}")
            if "half" in ovr:
                lines.append(f"    _{mode}_half={_quote(ovr['half'])}")
            if "delimiter" in ovr:
                lines.append(f"    _{mode}_delimiter={_quote(ovr['delimiter'])}")
            if "ago" in ovr:
                lines.append(f"    _{mode}_ago={_quote(ovr['ago'])}")
            if "inFuture" in ovr:
                lines.append(f"    _{mode}_in_future={_quote(ovr['inFuture'])}")

    # Plural function name
    lines.append(f"    _plural_func=_plural_{code}")

    lines.append("}")
    lines.append("")

    return "\n".join(lines)


def emit_registry(all_locales: list[dict]) -> str:
    """Generate registry.sh with locale loading."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER]

    # Source all locale files
    lines.append("# Source all locale files relative to this script's directory")
    lines.append('_sayableduration_locales_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"')
    lines.append("")
    for loc in sorted_locs:
        code = loc["code"]
        lines.append(f'source "${{_sayableduration_locales_dir}}/{code}.sh"')
    lines.append("")

    # Registry: known locale codes
    codes = " ".join(loc["code"] for loc in sorted_locs)
    lines.append(f'_SAYABLEDURATION_LOCALES="{codes}"')
    lines.append("")

    # load_locale function
    lines.append("_sayableduration_load_locale() {")
    lines.append("    local code=\"$1\"")
    lines.append("    local known")
    lines.append("    for known in ${_SAYABLEDURATION_LOCALES}; do")
    lines.append("        if [ \"${known}\" = \"${code}\" ]; then")
    lines.append("            _locale_${code}")
    lines.append("            return 0")
    lines.append("        fi")
    lines.append("    done")
    lines.append("    return 1")
    lines.append("}")
    lines.append("")

    return "\n".join(lines)


def output_path(code: str, root: str) -> str:
    import os
    return os.path.join(root, "impl", "bash", "locales", f"{code}.sh")


def registry_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "bash", "locales", "registry.sh")
