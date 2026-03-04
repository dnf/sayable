"""Kotlin plural rule definitions for all 23 patterns."""

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
    "he": """\
{ n ->
            when (n) {
                1 -> PluralCategory.ONE
                2 -> PluralCategory.TWO
                else -> PluralCategory.OTHER
            }
        }""",
    "mk": """\
{ n ->
            val mod10 = n % 10
            val mod100 = n % 100
            if (mod10 == 1 && mod100 != 11) PluralCategory.ONE else PluralCategory.OTHER
        }""",
    "cy": """\
{ n ->
            when (n) {
                0 -> PluralCategory.ZERO
                1 -> PluralCategory.ONE
                2 -> PluralCategory.TWO
                3 -> PluralCategory.FEW
                6 -> PluralCategory.MANY
                else -> PluralCategory.OTHER
            }
        }""",
    "gv": """\
{ n ->
            val mod10 = n % 10
            val mod100 = n % 100
            when {
                mod10 == 1 -> PluralCategory.ONE
                mod10 == 2 -> PluralCategory.TWO
                mod100 == 0 || mod100 == 20 || mod100 == 40 || mod100 == 60 || mod100 == 80 -> PluralCategory.FEW
                else -> PluralCategory.OTHER
            }
        }""",
    "gd": """\
{ n ->
            when {
                n == 1 || n == 11 -> PluralCategory.ONE
                n == 2 || n == 12 -> PluralCategory.TWO
                n in 3..10 || n in 13..19 -> PluralCategory.FEW
                else -> PluralCategory.OTHER
            }
        }""",
    "ga": """\
{ n ->
            when {
                n == 1 -> PluralCategory.ONE
                n == 2 -> PluralCategory.TWO
                n in 3..6 -> PluralCategory.FEW
                n in 7..10 -> PluralCategory.MANY
                else -> PluralCategory.OTHER
            }
        }""",
    "mt": """\
{ n ->
            when {
                n == 1 -> PluralCategory.ONE
                n == 2 -> PluralCategory.TWO
                n == 0 || n % 100 in 3..10 -> PluralCategory.FEW
                n % 100 in 11..19 -> PluralCategory.MANY
                else -> PluralCategory.OTHER
            }
        }""",
    "br": """\
{ n ->
            val mod10 = n % 10
            val mod100 = n % 100
            when {
                mod10 == 1 && mod100 != 11 && mod100 != 71 && mod100 != 91 -> PluralCategory.ONE
                mod10 == 2 && mod100 != 12 && mod100 != 72 && mod100 != 92 -> PluralCategory.TWO
                (mod10 == 3 || mod10 == 4 || mod10 == 9) && mod100 !in 10..19 && mod100 !in 70..79 && mod100 !in 90..99 -> PluralCategory.FEW
                n != 0 && n % 1000000 == 0 -> PluralCategory.MANY
                else -> PluralCategory.OTHER
            }
        }""",
    "kw": """\
{ n ->
            when {
                n == 0 -> PluralCategory.ZERO
                n == 1 -> PluralCategory.ONE
                else -> {
                    val mod100 = n % 100
                    when {
                        mod100 == 2 || mod100 == 22 || mod100 == 42 || mod100 == 62 || mod100 == 82 -> PluralCategory.TWO
                        mod100 == 3 || mod100 == 23 || mod100 == 43 || mod100 == 63 || mod100 == 83 -> PluralCategory.FEW
                        n != 1 && (mod100 == 1 || mod100 == 21 || mod100 == 41 || mod100 == 61 || mod100 == 81) -> PluralCategory.MANY
                        else -> PluralCategory.OTHER
                    }
                }
            }
        }""",
    "shi": """\
{ n ->
            when {
                n == 0 || n == 1 -> PluralCategory.ONE
                n in 2..10 -> PluralCategory.FEW
                else -> PluralCategory.OTHER
            }
        }""",
    "tzm": """\
{ n ->
            when {
                n == 0 || n == 1 || n in 11..99 -> PluralCategory.ONE
                else -> PluralCategory.OTHER
            }
        }""",
}


def get_kt_plural(rule: str) -> str:
    return _KT[rule]
