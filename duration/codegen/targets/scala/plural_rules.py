"""Scala plural rule definitions for all 23 patterns."""

from __future__ import annotations

_SCALA = {
    "other_only": "_ => PluralCategory.OTHER",
    "one_other": "n => if (n == 1) PluralCategory.ONE else PluralCategory.OTHER",
    "one_other_zero_one": "n => if (n == 0 || n == 1) PluralCategory.ONE else PluralCategory.OTHER",
    "cs_sk": """\
n => {
            if (n == 1) PluralCategory.ONE
            else if (n >= 2 && n <= 4) PluralCategory.FEW
            else PluralCategory.OTHER
        }""",
    "lt": """\
n => {
            val mod10 = n % 10
            val mod100 = n % 100
            if (mod10 == 1 && mod100 != 11) PluralCategory.ONE
            else if (mod10 >= 2 && mod10 <= 9 && (mod100 < 12 || mod100 > 19)) PluralCategory.FEW
            else PluralCategory.OTHER
        }""",
    "ro": """\
n => {
            if (n == 1) PluralCategory.ONE
            else if (n == 0 || (n % 100 >= 1 && n % 100 <= 19)) PluralCategory.FEW
            else PluralCategory.OTHER
        }""",
    "slavic_bcs": """\
n => {
            val mod10 = n % 10
            val mod100 = n % 100
            if (mod10 == 1 && mod100 != 11) PluralCategory.ONE
            else if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) PluralCategory.FEW
            else PluralCategory.OTHER
        }""",
    "pl": """\
n => {
            if (n == 1) PluralCategory.ONE
            else {
                val mod10 = n % 10
                val mod100 = n % 100
                if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) PluralCategory.FEW
                else PluralCategory.MANY
            }
        }""",
    "ru_uk": """\
n => {
            val mod10 = n % 10
            val mod100 = n % 100
            if (mod10 == 1 && mod100 != 11) PluralCategory.ONE
            else if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) PluralCategory.FEW
            else PluralCategory.MANY
        }""",
    "sl": """\
n => {
            val mod100 = n % 100
            if (mod100 == 1) PluralCategory.ONE
            else if (mod100 == 2) PluralCategory.TWO
            else if (mod100 == 3 || mod100 == 4) PluralCategory.FEW
            else PluralCategory.OTHER
        }""",
    "ar": """\
n => {
            if (n == 0) PluralCategory.ZERO
            else if (n == 1) PluralCategory.ONE
            else if (n == 2) PluralCategory.TWO
            else if (n % 100 >= 3 && n % 100 <= 10) PluralCategory.FEW
            else if (n % 100 >= 11 && n % 100 <= 99) PluralCategory.MANY
            else PluralCategory.OTHER
        }""",
    "lv": """\
n => {
            val mod10 = n % 10
            val mod100 = n % 100
            if (mod10 == 0 || (mod100 >= 11 && mod100 <= 19)) PluralCategory.ZERO
            else if (mod10 == 1 && mod100 != 11) PluralCategory.ONE
            else PluralCategory.OTHER
        }""",
    "he": """\
n => n match {
            case 1 => PluralCategory.ONE
            case 2 => PluralCategory.TWO
            case _ => PluralCategory.OTHER
        }""",
    "mk": """\
n => {
            val mod10 = n % 10
            val mod100 = n % 100
            if (mod10 == 1 && mod100 != 11) PluralCategory.ONE else PluralCategory.OTHER
        }""",
    "cy": """\
n => n match {
            case 0 => PluralCategory.ZERO
            case 1 => PluralCategory.ONE
            case 2 => PluralCategory.TWO
            case 3 => PluralCategory.FEW
            case 6 => PluralCategory.MANY
            case _ => PluralCategory.OTHER
        }""",
    "gv": """\
n => {
            val mod10 = n % 10
            val mod100 = n % 100
            if (mod10 == 1) PluralCategory.ONE
            else if (mod10 == 2) PluralCategory.TWO
            else if (mod100 == 0 || mod100 == 20 || mod100 == 40 || mod100 == 60 || mod100 == 80) PluralCategory.FEW
            else PluralCategory.OTHER
        }""",
    "gd": """\
n => {
            if (n == 1 || n == 11) PluralCategory.ONE
            else if (n == 2 || n == 12) PluralCategory.TWO
            else if ((n >= 3 && n <= 10) || (n >= 13 && n <= 19)) PluralCategory.FEW
            else PluralCategory.OTHER
        }""",
    "ga": """\
n => {
            if (n == 1) PluralCategory.ONE
            else if (n == 2) PluralCategory.TWO
            else if (n >= 3 && n <= 6) PluralCategory.FEW
            else if (n >= 7 && n <= 10) PluralCategory.MANY
            else PluralCategory.OTHER
        }""",
    "mt": """\
n => {
            if (n == 1) PluralCategory.ONE
            else if (n == 2) PluralCategory.TWO
            else if (n == 0 || (n % 100 >= 3 && n % 100 <= 10)) PluralCategory.FEW
            else if (n % 100 >= 11 && n % 100 <= 19) PluralCategory.MANY
            else PluralCategory.OTHER
        }""",
    "br": """\
n => {
            val mod10 = n % 10
            val mod100 = n % 100
            if (mod10 == 1 && mod100 != 11 && mod100 != 71 && mod100 != 91) PluralCategory.ONE
            else if (mod10 == 2 && mod100 != 12 && mod100 != 72 && mod100 != 92) PluralCategory.TWO
            else if ((mod10 == 3 || mod10 == 4 || mod10 == 9) && !(mod100 >= 10 && mod100 <= 19) && !(mod100 >= 70 && mod100 <= 79) && !(mod100 >= 90 && mod100 <= 99)) PluralCategory.FEW
            else if (n != 0 && n % 1000000 == 0) PluralCategory.MANY
            else PluralCategory.OTHER
        }""",
    "kw": """\
n => {
            if (n == 0) PluralCategory.ZERO
            else if (n == 1) PluralCategory.ONE
            else {
                val mod100 = n % 100
                if (mod100 == 2 || mod100 == 22 || mod100 == 42 || mod100 == 62 || mod100 == 82) PluralCategory.TWO
                else if (mod100 == 3 || mod100 == 23 || mod100 == 43 || mod100 == 63 || mod100 == 83) PluralCategory.FEW
                else if (n != 1 && (mod100 == 1 || mod100 == 21 || mod100 == 41 || mod100 == 61 || mod100 == 81)) PluralCategory.MANY
                else PluralCategory.OTHER
            }
        }""",
    "shi": """\
n => {
            if (n == 0 || n == 1) PluralCategory.ONE
            else if (n >= 2 && n <= 10) PluralCategory.FEW
            else PluralCategory.OTHER
        }""",
    "tzm": """\
n => {
            if (n == 0 || n == 1 || (n >= 11 && n <= 99)) PluralCategory.ONE
            else PluralCategory.OTHER
        }""",
}


def get_scala_plural(rule: str) -> str:
    return _SCALA[rule]
