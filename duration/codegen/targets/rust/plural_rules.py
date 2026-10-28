"""Rust plural rule definitions for all 23 patterns."""

from __future__ import annotations

_RS = {
    "other_only": "|_n| PluralCategory::Other",
    "one_other": """\
|n| {
            if n == 1 {
                PluralCategory::One
            } else {
                PluralCategory::Other
            }
        }""",
    "one_other_zero_one": """\
|n| {
            if n == 0 || n == 1 {
                PluralCategory::One
            } else {
                PluralCategory::Other
            }
        }""",
    "cs_sk": """\
|n| {
            if n == 1 {
                PluralCategory::One
            } else if (2..=4).contains(&n) {
                PluralCategory::Few
            } else {
                PluralCategory::Other
            }
        }""",
    "lt": """\
|n| {
            let mod10 = n % 10;
            let mod100 = n % 100;
            if mod10 == 1 && mod100 != 11 {
                PluralCategory::One
            } else if (2..=9).contains(&mod10) && !(12..=19).contains(&mod100) {
                PluralCategory::Few
            } else {
                PluralCategory::Other
            }
        }""",
    "ro": """\
|n| {
            if n == 1 {
                PluralCategory::One
            } else if n == 0 || (1..=19).contains(&(n % 100)) {
                PluralCategory::Few
            } else {
                PluralCategory::Other
            }
        }""",
    "slavic_bcs": """\
|n| {
            let mod10 = n % 10;
            let mod100 = n % 100;
            if mod10 == 1 && mod100 != 11 {
                PluralCategory::One
            } else if (2..=4).contains(&mod10) && !(12..=14).contains(&mod100) {
                PluralCategory::Few
            } else {
                PluralCategory::Other
            }
        }""",
    "pl": """\
|n| {
            if n == 1 {
                return PluralCategory::One;
            }
            let mod10 = n % 10;
            let mod100 = n % 100;
            if (2..=4).contains(&mod10) && !(12..=14).contains(&mod100) {
                PluralCategory::Few
            } else {
                PluralCategory::Many
            }
        }""",
    "ru_uk": """\
|n| {
            let mod10 = n % 10;
            let mod100 = n % 100;
            if mod10 == 1 && mod100 != 11 {
                PluralCategory::One
            } else if (2..=4).contains(&mod10) && !(12..=14).contains(&mod100) {
                PluralCategory::Few
            } else {
                PluralCategory::Many
            }
        }""",
    "sl": """\
|n| {
            let mod100 = n % 100;
            if mod100 == 1 {
                PluralCategory::One
            } else if mod100 == 2 {
                PluralCategory::Two
            } else if mod100 == 3 || mod100 == 4 {
                PluralCategory::Few
            } else {
                PluralCategory::Other
            }
        }""",
    "ar": """\
|n| {
            if n == 0 {
                return PluralCategory::Zero;
            }
            if n == 1 {
                return PluralCategory::One;
            }
            if n == 2 {
                return PluralCategory::Two;
            }
            let mod100 = n % 100;
            if (3..=10).contains(&mod100) {
                PluralCategory::Few
            } else if (11..=99).contains(&mod100) {
                PluralCategory::Many
            } else {
                PluralCategory::Other
            }
        }""",
    "lv": """\
|n| {
            let mod10 = n % 10;
            let mod100 = n % 100;
            if mod10 == 0 || (11..=19).contains(&mod100) {
                PluralCategory::Zero
            } else if mod10 == 1 && mod100 != 11 {
                PluralCategory::One
            } else {
                PluralCategory::Other
            }
        }""",
    "he": """\
|n| {
            if n == 1 {
                PluralCategory::One
            } else if n == 2 {
                PluralCategory::Two
            } else {
                PluralCategory::Other
            }
        }""",
    "mk": """\
|n| {
            let mod10 = n % 10;
            let mod100 = n % 100;
            if mod10 == 1 && mod100 != 11 {
                PluralCategory::One
            } else {
                PluralCategory::Other
            }
        }""",
    "cy": """\
|n| {
            if n == 0 {
                return PluralCategory::Zero;
            }
            if n == 1 {
                return PluralCategory::One;
            }
            if n == 2 {
                return PluralCategory::Two;
            }
            if n == 3 {
                PluralCategory::Few
            } else if n == 6 {
                PluralCategory::Many
            } else {
                PluralCategory::Other
            }
        }""",
    "gv": """\
|n| {
            let mod10 = n % 10;
            let mod100 = n % 100;
            if mod10 == 1 {
                PluralCategory::One
            } else if mod10 == 2 {
                PluralCategory::Two
            } else if mod100 == 0 || mod100 == 20 || mod100 == 40 || mod100 == 60 || mod100 == 80 {
                PluralCategory::Few
            } else {
                PluralCategory::Other
            }
        }""",
    "gd": """\
|n| {
            if n == 1 || n == 11 {
                PluralCategory::One
            } else if n == 2 || n == 12 {
                PluralCategory::Two
            } else if (3..=10).contains(&n) || (13..=19).contains(&n) {
                PluralCategory::Few
            } else {
                PluralCategory::Other
            }
        }""",
    "ga": """\
|n| {
            if n == 1 {
                return PluralCategory::One;
            }
            if n == 2 {
                return PluralCategory::Two;
            }
            if (3..=6).contains(&n) {
                PluralCategory::Few
            } else if (7..=10).contains(&n) {
                PluralCategory::Many
            } else {
                PluralCategory::Other
            }
        }""",
    "mt": """\
|n| {
            if n == 1 {
                return PluralCategory::One;
            }
            if n == 2 {
                return PluralCategory::Two;
            }
            let mod100 = n % 100;
            if n == 0 || (3..=10).contains(&mod100) {
                PluralCategory::Few
            } else if (11..=19).contains(&mod100) {
                PluralCategory::Many
            } else {
                PluralCategory::Other
            }
        }""",
    "br": """\
|n| {
            let mod10 = n % 10;
            let mod100 = n % 100;
            if mod10 == 1 && mod100 != 11 && mod100 != 71 && mod100 != 91 {
                PluralCategory::One
            } else if mod10 == 2 && mod100 != 12 && mod100 != 72 && mod100 != 92 {
                PluralCategory::Two
            } else if (mod10 == 3 || mod10 == 4 || mod10 == 9)
                && !(10..=19).contains(&mod100)
                && !(70..=79).contains(&mod100)
                && !(90..=99).contains(&mod100)
            {
                PluralCategory::Few
            } else if n != 0 && n % 1000000 == 0 {
                PluralCategory::Many
            } else {
                PluralCategory::Other
            }
        }""",
    "kw": """\
|n| {
            if n == 0 {
                return PluralCategory::Zero;
            }
            if n == 1 {
                return PluralCategory::One;
            }
            let mod100 = n % 100;
            if mod100 == 2 || mod100 == 22 || mod100 == 42 || mod100 == 62 || mod100 == 82 {
                PluralCategory::Two
            } else if mod100 == 3 || mod100 == 23 || mod100 == 43 || mod100 == 63 || mod100 == 83 {
                PluralCategory::Few
            } else if n != 1
                && (mod100 == 1 || mod100 == 21 || mod100 == 41 || mod100 == 61 || mod100 == 81)
            {
                PluralCategory::Many
            } else {
                PluralCategory::Other
            }
        }""",
    "shi": """\
|n| {
            if n == 0 || n == 1 {
                PluralCategory::One
            } else if (2..=10).contains(&n) {
                PluralCategory::Few
            } else {
                PluralCategory::Other
            }
        }""",
    "tzm": """\
|n| {
            if n == 0 || n == 1 || (11..=99).contains(&n) {
                PluralCategory::One
            } else {
                PluralCategory::Other
            }
        }""",
}


def is_simple_plural(rule: str) -> bool:
    """True if this rule can be expressed as an inline lambda/closure."""
    return rule in ("other_only", "one_other", "one_other_zero_one")


def get_rs_plural(rule: str) -> str:
    return _RS[rule]
