"""PHP plural rule definitions for all 12 patterns."""

from __future__ import annotations

_PHP_INLINE = {
    "other_only": "static fn(int $n): PluralCategory => PluralCategory::Other",
    "one_other": "static fn(int $n): PluralCategory => $n === 1 ? PluralCategory::One : PluralCategory::Other",
    "one_other_zero_one": "static fn(int $n): PluralCategory => $n === 0 || $n === 1 ? PluralCategory::One : PluralCategory::Other",
}

_PHP_NAMED = {
    "cs_sk": """\
    private static function plural{CODE}(int $n): PluralCategory
    {{
        if ($n === 1) {{
            return PluralCategory::One;
        }}
        if ($n >= 2 && $n <= 4) {{
            return PluralCategory::Few;
        }}

        return PluralCategory::Other;
    }}""",
    "lt": """\
    private static function plural{CODE}(int $n): PluralCategory
    {{
        $mod10 = $n % 10;
        $mod100 = $n % 100;
        if ($mod10 === 1 && $mod100 !== 11) {{
            return PluralCategory::One;
        }}
        if ($mod10 >= 2 && $mod10 <= 9 && ($mod100 < 12 || $mod100 > 19)) {{
            return PluralCategory::Few;
        }}

        return PluralCategory::Other;
    }}""",
    "ro": """\
    private static function plural{CODE}(int $n): PluralCategory
    {{
        if ($n === 1) {{
            return PluralCategory::One;
        }}
        if ($n === 0 || ($n % 100 >= 1 && $n % 100 <= 19)) {{
            return PluralCategory::Few;
        }}

        return PluralCategory::Other;
    }}""",
    "slavic_bcs": """\
    private static function plural{CODE}(int $n): PluralCategory
    {{
        $mod10 = $n % 10;
        $mod100 = $n % 100;
        if ($mod10 === 1 && $mod100 !== 11) {{
            return PluralCategory::One;
        }}
        if ($mod10 >= 2 && $mod10 <= 4 && ($mod100 < 12 || $mod100 > 14)) {{
            return PluralCategory::Few;
        }}

        return PluralCategory::Other;
    }}""",
    "pl": """\
    private static function plural{CODE}(int $n): PluralCategory
    {{
        if ($n === 1) {{
            return PluralCategory::One;
        }}
        $mod10 = $n % 10;
        $mod100 = $n % 100;
        if ($mod10 >= 2 && $mod10 <= 4 && ($mod100 < 12 || $mod100 > 14)) {{
            return PluralCategory::Few;
        }}

        return PluralCategory::Many;
    }}""",
    "ru_uk": """\
    private static function plural{CODE}(int $n): PluralCategory
    {{
        $mod10 = $n % 10;
        $mod100 = $n % 100;
        if ($mod10 === 1 && $mod100 !== 11) {{
            return PluralCategory::One;
        }}
        if ($mod10 >= 2 && $mod10 <= 4 && ($mod100 < 12 || $mod100 > 14)) {{
            return PluralCategory::Few;
        }}

        return PluralCategory::Many;
    }}""",
    "sl": """\
    private static function plural{CODE}(int $n): PluralCategory
    {{
        $mod100 = $n % 100;
        if ($mod100 === 1) {{
            return PluralCategory::One;
        }}
        if ($mod100 === 2) {{
            return PluralCategory::Two;
        }}
        if ($mod100 === 3 || $mod100 === 4) {{
            return PluralCategory::Few;
        }}

        return PluralCategory::Other;
    }}""",
    "ar": """\
    private static function plural{CODE}(int $n): PluralCategory
    {{
        if ($n === 0) {{
            return PluralCategory::Zero;
        }}
        if ($n === 1) {{
            return PluralCategory::One;
        }}
        if ($n === 2) {{
            return PluralCategory::Two;
        }}
        $mod100 = $n % 100;
        if ($mod100 >= 3 && $mod100 <= 10) {{
            return PluralCategory::Few;
        }}
        if ($mod100 >= 11 && $mod100 <= 99) {{
            return PluralCategory::Many;
        }}

        return PluralCategory::Other;
    }}""",
    "lv": """\
    private static function plural{CODE}(int $n): PluralCategory
    {{
        $mod10 = $n % 10;
        $mod100 = $n % 100;
        if ($mod10 === 0 || ($mod100 >= 11 && $mod100 <= 19)) {{
            return PluralCategory::Zero;
        }}
        if ($mod10 === 1 && $mod100 !== 11) {{
            return PluralCategory::One;
        }}

        return PluralCategory::Other;
    }}""",
}


def is_simple_plural(rule: str) -> bool:
    """True if this rule can be expressed as an inline lambda/closure."""
    return rule in ("other_only", "one_other", "one_other_zero_one")


def get_php_inline_plural(rule: str) -> str | None:
    """Get PHP inline plural for simple rules."""
    return _PHP_INLINE.get(rule)


def get_php_named_function(rule: str, code: str) -> str | None:
    """Get PHP named static method for complex rules."""
    template = _PHP_NAMED.get(rule)
    if template is None:
        return None
    return template.format(CODE=code.upper())
