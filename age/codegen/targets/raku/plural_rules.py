"""Raku plural rule definitions for all 23 patterns."""

from __future__ import annotations

_RAKU = {
    "other_only": "-> $n { 'other' }",
    "one_other": "-> $n { $n == 1 ?? 'one' !! 'other' }",
    "one_other_zero_one": "-> $n { $n == 0 || $n == 1 ?? 'one' !! 'other' }",
    "cs_sk": """\
-> $n {
        if $n == 1 { 'one' }
        elsif 2 <= $n <= 4 { 'few' }
        else { 'other' }
    }""",
    "lt": """\
-> $n {
        my $mod10 = $n mod 10;
        my $mod100 = $n mod 100;
        if $mod10 == 1 && $mod100 != 11 { 'one' }
        elsif 2 <= $mod10 <= 9 && ($mod100 < 12 || $mod100 > 19) { 'few' }
        else { 'other' }
    }""",
    "ro": """\
-> $n {
        if $n == 1 { 'one' }
        elsif $n == 0 || (1 <= $n mod 100 <= 19) { 'few' }
        else { 'other' }
    }""",
    "slavic_bcs": """\
-> $n {
        my $mod10 = $n mod 10;
        my $mod100 = $n mod 100;
        if $mod10 == 1 && $mod100 != 11 { 'one' }
        elsif 2 <= $mod10 <= 4 && ($mod100 < 12 || $mod100 > 14) { 'few' }
        else { 'other' }
    }""",
    "pl": """\
-> $n {
        if $n == 1 { 'one' }
        else {
            my $mod10 = $n mod 10;
            my $mod100 = $n mod 100;
            if 2 <= $mod10 <= 4 && ($mod100 < 12 || $mod100 > 14) { 'few' }
            else { 'many' }
        }
    }""",
    "ru_uk": """\
-> $n {
        my $mod10 = $n mod 10;
        my $mod100 = $n mod 100;
        if $mod10 == 1 && $mod100 != 11 { 'one' }
        elsif 2 <= $mod10 <= 4 && ($mod100 < 12 || $mod100 > 14) { 'few' }
        else { 'many' }
    }""",
    "sl": """\
-> $n {
        my $mod100 = $n mod 100;
        if $mod100 == 1 { 'one' }
        elsif $mod100 == 2 { 'two' }
        elsif $mod100 == 3 || $mod100 == 4 { 'few' }
        else { 'other' }
    }""",
    "ar": """\
-> $n {
        if $n == 0 { 'zero' }
        elsif $n == 1 { 'one' }
        elsif $n == 2 { 'two' }
        else {
            my $mod100 = $n mod 100;
            if 3 <= $mod100 <= 10 { 'few' }
            elsif 11 <= $mod100 <= 99 { 'many' }
            else { 'other' }
        }
    }""",
    "lv": """\
-> $n {
        my $mod10 = $n mod 10;
        my $mod100 = $n mod 100;
        if $mod10 == 0 || (11 <= $mod100 <= 19) { 'zero' }
        elsif $mod10 == 1 && $mod100 != 11 { 'one' }
        else { 'other' }
    }""",
    "he": """\
-> $n {
        if $n == 1 { 'one' }
        elsif $n == 2 { 'two' }
        else { 'other' }
    }""",
    "mk": """\
-> $n {
        my $mod10 = $n mod 10;
        my $mod100 = $n mod 100;
        if $mod10 == 1 && $mod100 != 11 { 'one' }
        else { 'other' }
    }""",
    "cy": """\
-> $n {
        if $n == 0 { 'zero' }
        elsif $n == 1 { 'one' }
        elsif $n == 2 { 'two' }
        elsif $n == 3 { 'few' }
        elsif $n == 6 { 'many' }
        else { 'other' }
    }""",
    "gv": """\
-> $n {
        my $mod10 = $n mod 10;
        my $mod100 = $n mod 100;
        if $mod10 == 1 { 'one' }
        elsif $mod10 == 2 { 'two' }
        elsif $mod100 == any(0, 20, 40, 60, 80) { 'few' }
        else { 'other' }
    }""",
    "gd": """\
-> $n {
        if $n == 1 || $n == 11 { 'one' }
        elsif $n == 2 || $n == 12 { 'two' }
        elsif (3 <= $n <= 10) || (13 <= $n <= 19) { 'few' }
        else { 'other' }
    }""",
    "ga": """\
-> $n {
        if $n == 1 { 'one' }
        elsif $n == 2 { 'two' }
        elsif 3 <= $n <= 6 { 'few' }
        elsif 7 <= $n <= 10 { 'many' }
        else { 'other' }
    }""",
    "mt": """\
-> $n {
        if $n == 1 { 'one' }
        elsif $n == 2 { 'two' }
        else {
            my $mod100 = $n mod 100;
            if $n == 0 || (3 <= $mod100 <= 10) { 'few' }
            elsif 11 <= $mod100 <= 19 { 'many' }
            else { 'other' }
        }
    }""",
    "br": """\
-> $n {
        my $mod10 = $n mod 10;
        my $mod100 = $n mod 100;
        if $mod10 == 1 && $mod100 != 11 && $mod100 != 71 && $mod100 != 91 { 'one' }
        elsif $mod10 == 2 && $mod100 != 12 && $mod100 != 72 && $mod100 != 92 { 'two' }
        elsif $mod10 == any(3, 4, 9) && !(10 <= $mod100 <= 19) && !(70 <= $mod100 <= 79) && !(90 <= $mod100 <= 99) { 'few' }
        elsif $n != 0 && $n mod 1000000 == 0 { 'many' }
        else { 'other' }
    }""",
    "kw": """\
-> $n {
        if $n == 0 { 'zero' }
        elsif $n == 1 { 'one' }
        else {
            my $mod100 = $n mod 100;
            if $mod100 == any(2, 22, 42, 62, 82) { 'two' }
            elsif $mod100 == any(3, 23, 43, 63, 83) { 'few' }
            elsif $n != 1 && $mod100 == any(1, 21, 41, 61, 81) { 'many' }
            else { 'other' }
        }
    }""",
    "shi": """\
-> $n {
        if $n == 0 || $n == 1 { 'one' }
        elsif 2 <= $n <= 10 { 'few' }
        else { 'other' }
    }""",
    "tzm": """\
-> $n {
        if $n == 0 || $n == 1 || (11 <= $n <= 99) { 'one' }
        else { 'other' }
    }""",
}


def get_raku_plural(rule: str) -> str:
    """Get Raku plural expression."""
    return _RAKU[rule]
