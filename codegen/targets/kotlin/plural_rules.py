"""Kotlin plural rule definitions for all 12 patterns."""

from __future__ import annotations

_KT = {
    "other_only": "{ _ -> PluralCategory.OTHER }",
    "one_other": "{ n -> if (n == 1) PluralCategory.ONE else PluralCategory.OTHER }",
    "one_other_zero_one": "{ n -> if (n == 0 || n == 1) PluralCategory.ONE else PluralCategory.OTHER }",
    "cs_sk": """\
{ n ->
            when {
                n == 1 -> PluralCategory.ONE
                n in 2..4 -> PluralCategory.FEW
                else -> PluralCategory.OTHER
            }
        }""",
    "lt": """\
{ n ->
            val mod10 = n % 10
            val mod100 = n % 100
            when {
                mod10 == 1 && mod100 != 11 -> PluralCategory.ONE
                mod10 in 2..9 && (mod100 < 12 || mod100 > 19) -> PluralCategory.FEW
                else -> PluralCategory.OTHER
            }
        }""",
    "ro": """\
{ n ->
            when {
                n == 1 -> PluralCategory.ONE
                n == 0 || n % 100 in 1..19 -> PluralCategory.FEW
                else -> PluralCategory.OTHER
            }
        }""",
    "slavic_bcs": """\
{ n ->
            val mod10 = n % 10
            val mod100 = n % 100
            when {
                mod10 == 1 && mod100 != 11 -> PluralCategory.ONE
                mod10 in 2..4 && (mod100 < 12 || mod100 > 14) -> PluralCategory.FEW
                else -> PluralCategory.OTHER
            }
        }""",
    "pl": """\
{ n ->
            if (n == 1) PluralCategory.ONE
            else {
                val mod10 = n % 10
                val mod100 = n % 100
                if (mod10 in 2..4 && (mod100 < 12 || mod100 > 14)) PluralCategory.FEW
                else PluralCategory.MANY
            }
        }""",
    "ru_uk": """\
{ n ->
            val mod10 = n % 10
            val mod100 = n % 100
            when {
                mod10 == 1 && mod100 != 11 -> PluralCategory.ONE
                mod10 in 2..4 && (mod100 < 12 || mod100 > 14) -> PluralCategory.FEW
                else -> PluralCategory.MANY
            }
        }""",
    "sl": """\
{ n ->
            val mod100 = n % 100
            when {
                mod100 == 1 -> PluralCategory.ONE
                mod100 == 2 -> PluralCategory.TWO
                mod100 in 3..4 -> PluralCategory.FEW
                else -> PluralCategory.OTHER
            }
        }""",
    "ar": """\
{ n ->
            when {
                n == 0 -> PluralCategory.ZERO
                n == 1 -> PluralCategory.ONE
                n == 2 -> PluralCategory.TWO
                n % 100 in 3..10 -> PluralCategory.FEW
                n % 100 in 11..99 -> PluralCategory.MANY
                else -> PluralCategory.OTHER
            }
        }""",
    "lv": """\
{ n ->
            val mod10 = n % 10
            val mod100 = n % 100
            when {
                mod10 == 0 || mod100 in 11..19 -> PluralCategory.ZERO
                mod10 == 1 && mod100 != 11 -> PluralCategory.ONE
                else -> PluralCategory.OTHER
            }
        }""",
}


def get_kt_plural(rule: str) -> str:
    return _KT[rule]
