#!/usr/bin/env python3
"""One-time bootstrap: read TypeScript locale files and produce canonical JSON.

Usage:
    python codegen/extract.py

Reads typescript/src/locales/*.ts (plus the EN locale) and writes one JSON
file per locale into codegen/locales/.
"""

from __future__ import annotations

import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TS_LOCALES_DIR = os.path.join(ROOT, "typescript", "src", "locales")
JSON_OUT_DIR = os.path.join(ROOT, "codegen", "locales")

# Locale names for doc comments in generated files
LOCALE_NAMES: dict[str, str] = {
    "ar": "Arabic", "bg": "Bulgarian", "bn": "Bengali", "bs": "Bosnian",
    "ca": "Catalan", "cs": "Czech", "da": "Danish", "de": "German",
    "el": "Greek", "en": "English", "es": "Spanish", "et": "Estonian",
    "eu": "Basque", "fa": "Persian", "fi": "Finnish", "fr": "French",
    "ga": "Irish", "gu": "Gujarati", "hi": "Hindi", "hr": "Croatian",
    "hu": "Hungarian", "it": "Italian", "ja": "Japanese", "jv": "Javanese",
    "ko": "Korean", "lt": "Lithuanian", "lv": "Latvian", "mr": "Marathi",
    "ms": "Malay", "nb": "Norwegian Bokmål", "nl": "Dutch", "pa": "Punjabi",
    "pl": "Polish", "pt": "Portuguese", "ro": "Romanian", "ru": "Russian",
    "sk": "Slovak", "sl": "Slovenian", "sq": "Albanian", "sr": "Serbian",
    "sv": "Swedish", "ta": "Tamil", "te": "Telugu", "th": "Thai",
    "tr": "Turkish", "uk": "Ukrainian", "ur": "Urdu", "vi": "Vietnamese",
    "zh": "Chinese",
}

# Plural rule classification based on the plural function body
PLURAL_RULES: dict[str, list[str]] = {
    "other_only": ["ja", "ko", "zh", "th", "vi", "ms", "jv", "hu", "eu", "ga"],
    "one_other": [
        "en", "bg", "et", "el", "fi", "sv", "it", "nb", "nl", "da", "de",
        "es", "ca", "sq", "ta", "te", "tr", "mr", "ur",
    ],
    "one_other_zero_one": ["fr", "pt", "hi", "fa", "bn", "gu", "pa"],
    "cs_sk": ["cs", "sk"],
    "lt": ["lt"],
    "ro": ["ro"],
    "slavic_bcs": ["hr", "bs", "sr"],
    "pl": ["pl"],
    "ru_uk": ["ru", "uk"],
    "sl": ["sl"],
    "ar": ["ar"],
    "lv": ["lv"],
}

# Invert: code -> rule name
CODE_TO_RULE: dict[str, str] = {}
for rule, codes in PLURAL_RULES.items():
    for code in codes:
        CODE_TO_RULE[code] = rule


def unescape_ts_string(s: str) -> str:
    """Handle TS unicode escapes like \\u00BD and \\xC2."""
    s = re.sub(r"\\u([0-9A-Fa-f]{4})", lambda m: chr(int(m.group(1), 16)), s)
    s = re.sub(r"\\x([0-9A-Fa-f]{2})", lambda m: chr(int(m.group(1), 16)), s)
    s = s.replace("\\'", "'")
    s = s.replace('\\"', '"')
    s = s.replace("\\n", "\n")
    s = s.replace("\\t", "\t")
    return s


def extract_string(text: str, pos: int) -> tuple[str, int]:
    """Extract a quoted string starting at pos, return (value, end_pos)."""
    quote = text[pos]
    end = pos + 1
    while end < len(text):
        if text[end] == "\\":
            end += 2
            continue
        if text[end] == quote:
            return unescape_ts_string(text[pos + 1 : end]), end + 1
        end += 1
    raise ValueError(f"Unterminated string at position {pos}")


def skip_whitespace(text: str, pos: int) -> int:
    while pos < len(text) and text[pos] in " \t\n\r":
        pos += 1
    return pos


def parse_value(text: str, pos: int) -> tuple[object, int]:
    """Parse a TS value at pos: string, object, or identifier."""
    pos = skip_whitespace(text, pos)
    if pos >= len(text):
        raise ValueError("Unexpected end of input")

    if text[pos] in ("'", '"', "`"):
        return extract_string(text, pos)

    if text[pos] == "{":
        return parse_object(text, pos)

    # Identifier or other (shouldn't happen for our locale data)
    end = pos
    while end < len(text) and text[end] not in ",}]\n\r ":
        end += 1
    return text[pos:end], end


def parse_object(text: str, pos: int) -> tuple[dict, int]:
    """Parse a TS object literal starting with { at pos."""
    assert text[pos] == "{"
    pos += 1
    result: dict[str, object] = {}

    while True:
        pos = skip_whitespace(text, pos)
        if pos >= len(text):
            break
        if text[pos] == "}":
            return result, pos + 1

        # Parse key
        if text[pos] in ("'", '"'):
            key, pos = extract_string(text, pos)
        else:
            # Bare identifier key
            end = pos
            while end < len(text) and text[end] not in ":, \t\n\r}":
                end += 1
            key = text[pos:end]
            pos = end

        pos = skip_whitespace(text, pos)
        if pos < len(text) and text[pos] == ":":
            pos += 1
        pos = skip_whitespace(text, pos)

        # Parse value
        val, pos = parse_value(text, pos)
        result[key] = val

        pos = skip_whitespace(text, pos)
        if pos < len(text) and text[pos] == ",":
            pos += 1

    return result, pos


def extract_units(text: str) -> dict[str, object]:
    """Extract the units block from the locale source."""
    # Find units: { ... }
    match = re.search(r"units:\s*\{", text)
    if not match:
        raise ValueError("Could not find units block")

    start = match.end() - 1  # position of {
    units_obj, _ = parse_object(text, start)

    result: dict[str, object] = {}
    for unit_name in ("day", "week", "month", "year"):
        val = units_obj.get(unit_name)
        if val is None:
            raise ValueError(f"Missing unit: {unit_name}")
        if isinstance(val, str):
            # Simple unit (no plurals)
            result[unit_name] = val
        elif isinstance(val, dict):
            # Plural unit — keep only the category->template mapping
            result[unit_name] = val
        else:
            raise ValueError(f"Unexpected unit value type for {unit_name}: {type(val)}")

    return result


def extract_stages(text: str) -> dict[str, object]:
    """Extract the stages block from the locale source."""
    match = re.search(r"stages:\s*\{", text)
    if not match:
        raise ValueError("Could not find stages block")

    start = match.end() - 1
    stages_obj, _ = parse_object(text, start)

    result: dict[str, object] = {}
    for stage_name in ("newborn", "infant", "toddler", "child", "teenager", "adult"):
        val = stages_obj.get(stage_name)
        if val is None:
            raise ValueError(f"Missing stage: {stage_name}")
        if isinstance(val, str):
            result[stage_name] = val
        elif isinstance(val, dict):
            result[stage_name] = {"m": val["m"], "f": val["f"]}
        else:
            raise ValueError(f"Unexpected stage value for {stage_name}")

    return result


def extract_simple_field(text: str, field: str) -> str:
    """Extract a simple string field like half, delimiter, justBorn."""
    # Match field: 'value' or field: "value"
    pattern = rf"{field}:\s*(['\"`])"
    match = re.search(pattern, text)
    if not match:
        raise ValueError(f"Could not find field: {field}")
    return extract_string(text, match.start(1))[0]


def extract_compactness(text: str, field: str) -> dict | None:
    """Extract a short/compact override block."""
    pattern = rf"{field}:\s*\{{"
    match = re.search(pattern, text)
    if not match:
        return None

    start = match.end() - 1
    obj, _ = parse_object(text, start)

    result: dict[str, object] = {}
    if "units" in obj and isinstance(obj["units"], dict):
        result["units"] = {}
        for unit_name in ("day", "week", "month", "year"):
            if unit_name in obj["units"]:
                result["units"][unit_name] = obj["units"][unit_name]
    if "half" in obj:
        result["half"] = obj["half"]
    if "delimiter" in obj:
        result["delimiter"] = obj["delimiter"]
    if "justBorn" in obj:
        result["justBorn"] = obj["justBorn"]

    return result if result else None


def extract_locale(filepath: str, code: str) -> dict:
    """Extract a complete locale definition from a TypeScript file."""
    with open(filepath, encoding="utf-8") as f:
        text = f.read()

    data: dict[str, object] = {
        "code": code,
        "name": LOCALE_NAMES[code],
        "pluralRule": CODE_TO_RULE[code],
    }

    data["units"] = extract_units(text)
    data["half"] = extract_simple_field(text, "half")
    data["delimiter"] = extract_simple_field(text, "delimiter")
    data["justBorn"] = extract_simple_field(text, "justBorn")
    data["stages"] = extract_stages(text)

    short = extract_compactness(text, "short")
    if short:
        data["short"] = short

    compact = extract_compactness(text, "compact")
    if compact:
        data["compact"] = compact

    return data


def main() -> None:
    os.makedirs(JSON_OUT_DIR, exist_ok=True)

    # Get all locale files
    codes = sorted(CODE_TO_RULE.keys())
    errors = []

    for code in codes:
        filepath = os.path.join(TS_LOCALES_DIR, f"{code}.ts")
        if not os.path.exists(filepath):
            errors.append(f"Missing file: {filepath}")
            continue

        try:
            data = extract_locale(filepath, code)
            outpath = os.path.join(JSON_OUT_DIR, f"{code}.json")
            with open(outpath, "w", encoding="utf-8") as f:
                json.dump(data, f, indent=2, ensure_ascii=False)
                f.write("\n")
            print(f"  {code}.json")
        except Exception as e:
            errors.append(f"{code}: {e}")

    print(f"\nExtracted {len(codes) - len(errors)}/{len(codes)} locales")
    if errors:
        print("\nErrors:")
        for err in errors:
            print(f"  {err}")
        sys.exit(1)


if __name__ == "__main__":
    main()
