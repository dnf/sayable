"""C++ locale emitter for sayable-date -- 4 source files by alpha range + header."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header

HEADER = make_header("codegen/targets/cpp/emitter.py")

# Alpha ranges for the 4 source files
_RANGES = [
    ("a_e", "a", "e"),
    ("f_k", "f", "k"),
    ("l_r", "l", "r"),
    ("s_z", "s", "z"),
]


def _quote(s: str) -> str:
    escaped = s.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def _string_array(items: list[str], count: int) -> str:
    """Emit a C++ braced initializer for a fixed-size string array."""
    parts = [_quote(s) for s in items]
    assert len(parts) == count, f"Expected {count} items, got {len(parts)}"
    return "{" + ", ".join(parts) + "}"


def _string_map(d: dict[str, str]) -> str:
    """Emit a C++ map initializer."""
    if not d:
        return "{}"
    pairs = ["{" + _quote(k) + ", " + _quote(v) + "}" for k, v in sorted(d.items(), key=lambda x: int(x[0]))]
    return "{" + ", ".join(pairs) + "}"


def _emit_compactness_override(ovr: dict) -> str:
    """Emit a CompactnessOverride initializer."""
    lines = []
    lines.append("        CompactnessOverride{")

    # months (empty vector = no override)
    if "months" in ovr:
        parts = [_quote(s) for s in ovr["months"]]
        lines.append("            {" + ", ".join(parts) + "},")
    else:
        lines.append("            {},")

    # months_in_date (empty vector = no override)
    if "monthsInDate" in ovr:
        parts = [_quote(s) for s in ovr["monthsInDate"]]
        lines.append("            {" + ", ".join(parts) + "},")
    else:
        lines.append("            {},")

    # weekdays (empty vector = no override)
    if "weekdays" in ovr:
        parts = [_quote(s) for s in ovr["weekdays"]]
        lines.append("            {" + ", ".join(parts) + "},")
    else:
        lines.append("            {},")

    # day_format
    if "dayFormat" in ovr:
        lines.append(f"            {_quote(ovr['dayFormat'])},")
    else:
        lines.append('            "",')

    # day_format_exceptions
    if "dayFormatExceptions" in ovr:
        lines.append(f"            {_string_map(ovr['dayFormatExceptions'])},")
    else:
        lines.append("            {},")

    # day_format_exceptions_set
    has_day_format_exceptions = "dayFormatExceptions" in ovr
    lines.append(f"            {'true' if has_day_format_exceptions else 'false'},")

    # date_pattern
    if "datePattern" in ovr:
        lines.append(f"            {_quote(ovr['datePattern'])},")
    else:
        lines.append('            "",')

    # date_pattern_with_year
    if "datePatternWithYear" in ovr:
        lines.append(f"            {_quote(ovr['datePatternWithYear'])},")
    else:
        lines.append('            "",')

    # today
    if "today" in ovr:
        lines.append(f"            {_quote(ovr['today'])},")
    else:
        lines.append('            "",')

    # tomorrow
    if "tomorrow" in ovr:
        lines.append(f"            {_quote(ovr['tomorrow'])},")
    else:
        lines.append('            "",')

    # yesterday
    if "yesterday" in ovr:
        lines.append(f"            {_quote(ovr['yesterday'])}")
    else:
        lines.append('            ""')

    lines.append("        }")
    return "\n".join(lines)


def _emit_one_locale(data: dict) -> str:
    """Emit a single locale function body."""
    code = data["code"]
    uc = code.upper()

    lines = []
    lines.append(f"const DateLocale& {uc}() {{")
    lines.append("    static const DateLocale loc{")

    # code
    lines.append(f"        {_quote(code)},")

    # months[12]
    lines.append(f"        {_string_array(data['months'], 12)},")

    # weekdays[7]
    lines.append(f"        {_string_array(data['weekdays'], 7)},")

    # day_format
    lines.append(f"        {_quote(data['dayFormat'])},")

    # day_format_exceptions
    exceptions = data.get("dayFormatExceptions", {})
    lines.append(f"        {_string_map(exceptions)},")

    # date_pattern
    lines.append(f"        {_quote(data['datePattern'])},")

    # date_pattern_with_year
    lines.append(f"        {_quote(data['datePatternWithYear'])},")

    # today, tomorrow, yesterday
    lines.append(f"        {_quote(data['today'])}, {_quote(data['tomorrow'])}, {_quote(data['yesterday'])},")

    # day_after_tomorrow (optional, empty string if not set)
    lines.append(f"        {_quote(data.get('dayAfterTomorrow', ''))},")

    # day_before_yesterday (optional)
    lines.append(f"        {_quote(data.get('dayBeforeYesterday', ''))},")

    # this_weekday (optional)
    lines.append(f"        {_quote(data.get('thisWeekday', ''))},")

    # next_weekday (optional)
    lines.append(f"        {_quote(data.get('nextWeekday', ''))},")

    # last_weekday (optional)
    lines.append(f"        {_quote(data.get('lastWeekday', ''))},")

    # months_in_date[12] (all empty if not set)
    if "monthsInDate" in data:
        lines.append(f"        {_string_array(data['monthsInDate'], 12)},")
    else:
        empty_months = [""] * 12
        lines.append(f"        {_string_array(empty_months, 12)},")

    # short_override
    if "short" in data:
        lines.append(_emit_compactness_override(data["short"]) + ",")
    else:
        lines.append("        std::nullopt,")

    # compact_override
    if "compact" in data:
        lines.append(_emit_compactness_override(data["compact"]))
    else:
        lines.append("        std::nullopt")

    lines.append("    };")
    lines.append("    return loc;")
    lines.append("}")

    return "\n".join(lines)


def emit_source_file(locales_in_range: list[dict]) -> str:
    """Emit one of the 4 source files."""
    lines = [
        "// -*- coding: utf-8 -*-",
        HEADER.rstrip(),
        '#include "sayabledate/locales/locales.hpp"\n',
        "namespace sayabledate {",
        "namespace locales {\n",
    ]

    for i, data in enumerate(locales_in_range):
        lines.append(locale_source_comment(data["code"]).rstrip())
        lines.append(_emit_one_locale(data))
        if i < len(locales_in_range) - 1:
            lines.append("")

    lines.append("")
    lines.append("} // namespace locales")
    lines.append("} // namespace sayabledate")
    lines.append("")

    return "\n".join(lines)


def emit_header(all_locales: list[dict]) -> str:
    """Emit the locales.hpp header."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER]
    lines.append("#ifndef SAYABLEDATE_LOCALES_HPP")
    lines.append("#define SAYABLEDATE_LOCALES_HPP")
    lines.append("")
    lines.append('#include "../types.hpp"')
    lines.append("#include <string>")
    lines.append("")
    lines.append("namespace sayabledate {")
    lines.append("namespace locales {")
    lines.append("")
    for loc in sorted_locs:
        lines.append(f"const DateLocale& {loc['code'].upper()}();")
    lines.append("")
    lines.append("const DateLocale* get(const std::string& code);")
    lines.append("")
    lines.append("} // namespace locales")
    lines.append("} // namespace sayabledate")
    lines.append("")
    lines.append("#endif // SAYABLEDATE_LOCALES_HPP")
    lines.append("")

    return "\n".join(lines)


def emit_registry(all_locales: list[dict]) -> str:
    """Emit locales_registry.cpp with the get() lookup function."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [
        "// -*- coding: utf-8 -*-",
        HEADER.rstrip(),
        '#include "sayabledate/locales/locales.hpp"\n',
        "namespace sayabledate {",
        "namespace locales {\n",
        "const DateLocale* get(const std::string& code) {",
    ]
    for loc in sorted_locs:
        code = loc["code"]
        lines.append(f'    if (code == {_quote(code)}) return &{code.upper()}();')
    lines.append("    return nullptr;")
    lines.append("}")
    lines.append("")
    lines.append("} // namespace locales")
    lines.append("} // namespace sayabledate")
    lines.append("")
    return "\n".join(lines)


def registry_source_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "cpp", "src", "locales", "locales_registry.cpp")


def split_by_range(all_locales: list[dict]) -> dict[str, list[dict]]:
    """Split locales into the 4 alpha ranges."""
    result: dict[str, list[dict]] = {}
    for suffix, start, end in _RANGES:
        result[suffix] = [
            d for d in sorted(all_locales, key=lambda x: x["code"])
            if start <= d["code"][0] <= end
        ]
    return result


def source_path(suffix: str, root: str) -> str:
    import os
    return os.path.join(root, "impl", "cpp", "src", "locales", f"locales_{suffix}.cpp")


def header_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "cpp", "include", "sayabledate", "locales", "locales.hpp")
