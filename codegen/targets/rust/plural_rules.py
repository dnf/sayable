"""Rust plural rule definitions for all 14 patterns."""

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
            if n == 0 || n == 1 { PluralCategory::One } else { PluralCategory::Other }
        }""",
    "cs_sk": """\
|n| {
            if n == 1 { PluralCategory::One }
            else if (2..=4).contains(&n) { PluralCategory::Few }
            else { PluralCategory::Other }
        }""",
    "lt": """\
|n| {
            let mod10 = n % 10;
            let mod100 = n % 100;
            if mod10 == 1 && mod100 != 11 { PluralCategory::One }
            else if (2..=9).contains(&mod10) && !(12..=19).contains(&mod100) { PluralCategory::Few }
            else { PluralCategory::Other }
        }""",
    "ro": """\
|n| {
            if n == 1 { PluralCategory::One }
            else if n == 0 || (1..=19).contains(&(n % 100)) { PluralCategory::Few }
            else { PluralCategory::Other }
        }""",
    "slavic_bcs": """\
|n| {
            let mod10 = n % 10;
            let mod100 = n % 100;
            if mod10 == 1 && mod100 != 11 { PluralCategory::One }
            else if (2..=4).contains(&mod10) && !(12..=14).contains(&mod100) { PluralCategory::Few }
            else { PluralCategory::Other }
        }""",
    "pl": """\
|n| {
            if n == 1 { return PluralCategory::One; }
            let mod10 = n % 10;
            let mod100 = n % 100;
            if (2..=4).contains(&mod10) && !(12..=14).contains(&mod100) { PluralCategory::Few }
            else { PluralCategory::Many }
        }""",
    "ru_uk": """\
|n| {
            let mod10 = n % 10;
            let mod100 = n % 100;
            if mod10 == 1 && mod100 != 11 { PluralCategory::One }
            else if (2..=4).contains(&mod10) && !(12..=14).contains(&mod100) { PluralCategory::Few }
            else { PluralCategory::Many }
        }""",
    "sl": """\
|n| {
            let mod100 = n % 100;
            if mod100 == 1 { PluralCategory::One }
            else if mod100 == 2 { PluralCategory::Two }
            else if mod100 == 3 || mod100 == 4 { PluralCategory::Few }
            else { PluralCategory::Other }
        }""",
    "ar": """\
|n| {
            if n == 0 { return PluralCategory::Zero; }
            if n == 1 { return PluralCategory::One; }
            if n == 2 { return PluralCategory::Two; }
            let mod100 = n % 100;
            if (3..=10).contains(&mod100) { PluralCategory::Few }
            else if (11..=99).contains(&mod100) { PluralCategory::Many }
            else { PluralCategory::Other }
        }""",
    "lv": """\
|n| {
            let mod10 = n % 10;
            let mod100 = n % 100;
            if mod10 == 0 || (11..=19).contains(&mod100) { PluralCategory::Zero }
            else if mod10 == 1 && mod100 != 11 { PluralCategory::One }
            else { PluralCategory::Other }
        }""",
    "he": """\
|n| {
            if n == 1 { PluralCategory::One }
            else if n == 2 { PluralCategory::Two }
            else { PluralCategory::Other }
        }""",
    "mk": """\
|n| {
            let mod10 = n % 10;
            let mod100 = n % 100;
            if mod10 == 1 && mod100 != 11 { PluralCategory::One }
            else { PluralCategory::Other }
        }""",
}


def is_simple_plural(rule: str) -> bool:
    """True if this rule can be expressed as an inline lambda/closure."""
    return rule in ("other_only", "one_other", "one_other_zero_one")


def get_rs_plural(rule: str) -> str:
    return _RS[rule]
