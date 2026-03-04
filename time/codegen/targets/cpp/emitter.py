"""C++ locale emitter for sayable-time — 4 source files by alpha range + header."""

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


def _emit_one_locale(data: dict) -> str:
    """Emit a single locale function body."""
    code = data["code"]
    clock = data["clock"]
    uc = code.upper()

    lines = []
    lines.append(f"const TimeLocale& {uc}() {{")
    lines.append("    static const TimeLocale loc{")
    lines.append(f"        {_quote(code)},")

    # ClockConfig
    lines.append("        ClockConfig{")
    # hours array
    hour_parts = ", ".join(_quote(h) for h in clock["hours"])
    lines.append(f"            {{{hour_parts}}},")
    lines.append(f"            {_quote(clock['midnight'])},")
    lines.append(f"            {_quote(clock['noon'])},")
    # patterns map
    keys = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55]
    pattern_parts = []
    for key in keys:
        skey = str(key)
        if skey in clock["patterns"]:
            pattern_parts.append(f"{{{key}, {_quote(clock['patterns'][skey])}}}")
    lines.append("            {" + ", ".join(pattern_parts) + "}")
    lines.append("        },")

    # Short/compact overrides
    for mode in ("short", "compact"):
        if mode in data:
            ovr = data[mode]
            if "clock" in ovr:
                sc = ovr["clock"]
                use24h = "true" if sc.get("use24h", True) else "false"
                fmt = sc.get("format", "{h}:{mm}")
                am_pm = sc.get("amPm")
                if am_pm:
                    lines.append(f"        CompactnessOverride{{ShortClockConfig{{{use24h}, {_quote(fmt)}, {{{_quote(am_pm[0])}, {_quote(am_pm[1])}}}}}}},")
                else:
                    lines.append(f"        CompactnessOverride{{ShortClockConfig{{{use24h}, {_quote(fmt)}, {{\"\", \"\"}}}}}},")
            else:
                lines.append("        std::nullopt,")
        else:
            lines.append("        std::nullopt,")

    lines.append("    };")
    lines.append("    return loc;")
    lines.append("}")

    return "\n".join(lines)


def emit_source_file(locales_in_range: list[dict]) -> str:
    """Emit one of the 4 source files."""
    lines = [
        "// -*- coding: utf-8 -*-",
        HEADER.rstrip(),
        '#include "sayabletime/locales/locales.hpp"\n',
        "namespace sayabletime {",
        "namespace locales {\n",
    ]

    for i, data in enumerate(locales_in_range):
        lines.append(locale_source_comment(data["code"]).rstrip())
        lines.append(_emit_one_locale(data))
        if i < len(locales_in_range) - 1:
            lines.append("")

    lines.append("")
    lines.append("} // namespace locales")
    lines.append("} // namespace sayabletime")
    lines.append("")

    return "\n".join(lines)


def emit_header(all_locales: list[dict]) -> str:
    """Emit the locales.hpp header."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER]
    lines.append("#ifndef SAYABLETIME_LOCALES_HPP")
    lines.append("#define SAYABLETIME_LOCALES_HPP")
    lines.append("")
    lines.append('#include "../types.hpp"')
    lines.append("#include <string>")
    lines.append("")
    lines.append("namespace sayabletime {")
    lines.append("namespace locales {")
    lines.append("")
    for loc in sorted_locs:
        lines.append(f"const TimeLocale& {loc['code'].upper()}();")
    lines.append("")
    lines.append("const TimeLocale* get(const std::string& code);")
    lines.append("")
    lines.append("} // namespace locales")
    lines.append("} // namespace sayabletime")
    lines.append("")
    lines.append("#endif // SAYABLETIME_LOCALES_HPP")
    lines.append("")

    return "\n".join(lines)


def emit_registry(all_locales: list[dict]) -> str:
    """Emit locales_registry.cpp with the get() lookup function."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [
        "// -*- coding: utf-8 -*-",
        HEADER.rstrip(),
        '#include "sayabletime/locales/locales.hpp"\n',
        "namespace sayabletime {",
        "namespace locales {\n",
        "const TimeLocale* get(const std::string& code) {",
    ]
    for loc in sorted_locs:
        code = loc["code"]
        lines.append(f'    if (code == {_quote(code)}) return &{code.upper()}();')
    lines.append("    return nullptr;")
    lines.append("}")
    lines.append("")
    lines.append("} // namespace locales")
    lines.append("} // namespace sayabletime")
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
    return os.path.join(root, "impl", "cpp", "include", "sayabletime", "locales", "locales.hpp")
