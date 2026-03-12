"""Perl locale emitter for sayable-duration."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header
from codegen.targets.perl.plural_rules import get_pl_plural

HEADER = make_header("codegen/targets/perl/emitter.py", line_prefix="# ")

_UNIT_NAMES = ("second", "minute", "hour", "day", "week", "month", "year")


def _quote(s: str) -> str:
    escaped = s.replace("\\", "\\\\").replace("'", "\\'")
    return f"'{escaped}'"


def _unit_forms(unit: object) -> str:
    if isinstance(unit, str):
        return _quote(unit)
    cats = ["zero", "one", "two", "few", "many", "other"]
    pairs = []
    for cat in cats:
        if cat in unit:
            pairs.append(f"{cat} => {_quote(unit[cat])}")
    return "{ " + ", ".join(pairs) + " }"


def emit_locale(data: dict) -> str:
    code = data["code"]
    rule = data["pluralRule"]
    uc = code.upper()

    lines = []
    lines.append("use strict;")
    lines.append("use warnings;")
    lines.append("use utf8;")
    lines.append("")
    lines.append((HEADER + locale_source_comment(code, line_prefix="# ")).rstrip())
    lines.append(f"package SayableDuration::Locales::{uc};")
    lines.append("")
    lines.append("sub locale {{")

    # Code
    lines.append(f"  code => {_quote(code)},")

    # Plural
    plural = get_pl_plural(rule)
    lines.append(f"  plural => {plural},")

    # Units
    lines.append("  units => {")
    for unit_name in _UNIT_NAMES:
        val = _unit_forms(data["units"][unit_name])
        lines.append(f"    {unit_name} => {val},")
    lines.append("  },")

    # Simple fields
    lines.append(f"  half => {_quote(data['half'])},")
    lines.append(f"  delimiter => {_quote(data['delimiter'])},")
    lines.append(f"  just_now => {_quote(data['justNow'])},")
    lines.append(f"  ago => {_quote(data['ago'])},")
    lines.append(f"  in_future => {_quote(data['inFuture'])},")

    # Short/compact
    for mode in ("short", "compact"):
        if mode in data:
            ovr = data[mode]
            lines.append(f"  {mode} => {{")
            if "units" in ovr:
                lines.append("    units => {")
                for unit_name in _UNIT_NAMES:
                    if unit_name in ovr["units"]:
                        val = _unit_forms(ovr["units"][unit_name])
                        lines.append(f"      {unit_name} => {val},")
                lines.append("    },")
            if "delimiter" in ovr:
                lines.append(f"    delimiter => {_quote(ovr['delimiter'])},")
            if "half" in ovr:
                lines.append(f"    half => {_quote(ovr['half'])},")
            if "ago" in ovr:
                lines.append(f"    ago => {_quote(ovr['ago'])},")
            if "inFuture" in ovr:
                lines.append(f"    in_future => {_quote(ovr['inFuture'])},")
            lines.append("  },")

    lines.append("}}")
    lines.append("")
    lines.append("1;")
    lines.append("")

    return "\n".join(lines)


def emit_barrel(all_locales: list[dict]) -> str | None:
    return None


def emit_registry(all_locales: list[dict]) -> str:
    """Generate Locales.pm with get($code) function."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = ["use strict;", "use warnings;", "", HEADER.rstrip()]
    lines.append("package SayableDuration::Locales;")
    lines.append("")

    for loc in sorted_locs:
        uc = loc["code"].upper()
        lines.append(f"use SayableDuration::Locales::{uc};")
    lines.append("")

    lines.append("my %_LOCALES = (")
    for loc in sorted_locs:
        code = loc["code"]
        uc = code.upper()
        lines.append(f"  {_quote(code)} => SayableDuration::Locales::{uc}::locale(),")
    lines.append(");")
    lines.append("")

    lines.append("sub get {")
    lines.append("  my ($class, $code) = @_;")
    lines.append("  return $_LOCALES{$code};")
    lines.append("}")
    lines.append("")
    lines.append("1;")
    lines.append("")

    return "\n".join(lines)


def output_path(code: str, root: str) -> str:
    import os
    return os.path.join(root, "impl", "perl", "lib", "SayableDuration", "Locales", f"{code.upper()}.pm")


def registry_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "perl", "lib", "SayableDuration", "Locales.pm")


def barrel_path(root: str) -> str | None:
    return None
