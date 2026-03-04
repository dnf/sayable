"""Perl plural rule definitions for all 23 patterns."""

from __future__ import annotations

_PL = {
    "other_only": "sub { 'other' }",
    "one_other": "sub { my ($n) = @_; $n == 1 ? 'one' : 'other' }",
    "one_other_zero_one": """\
sub {
        my ($n) = @_;
        ($n == 0 || $n == 1) ? 'one' : 'other'
      }""",
    "cs_sk": """\
sub {
        my ($n) = @_;
        if ($n == 1) { 'one' }
        elsif ($n >= 2 && $n <= 4) { 'few' }
        else { 'other' }
      }""",
    "lt": """\
sub {
        my ($n) = @_;
        my $mod10 = $n % 10;
        my $mod100 = $n % 100;
        if ($mod10 == 1 && $mod100 != 11) { 'one' }
        elsif ($mod10 >= 2 && $mod10 <= 9 && ($mod100 < 12 || $mod100 > 19)) { 'few' }
        else { 'other' }
      }""",
    "ro": """\
sub {
        my ($n) = @_;
        if ($n == 1) { 'one' }
        elsif ($n == 0 || ($n % 100 >= 1 && $n % 100 <= 19)) { 'few' }
        else { 'other' }
      }""",
    "slavic_bcs": """\
sub {
        my ($n) = @_;
        my $mod10 = $n % 10;
        my $mod100 = $n % 100;
        if ($mod10 == 1 && $mod100 != 11) { 'one' }
        elsif ($mod10 >= 2 && $mod10 <= 4 && ($mod100 < 12 || $mod100 > 14)) { 'few' }
        else { 'other' }
      }""",
    "pl": """\
sub {
        my ($n) = @_;
        if ($n == 1) { 'one' }
        else {
          my $mod10 = $n % 10;
          my $mod100 = $n % 100;
          if ($mod10 >= 2 && $mod10 <= 4 && ($mod100 < 12 || $mod100 > 14)) { 'few' }
          else { 'many' }
        }
      }""",
    "ru_uk": """\
sub {
        my ($n) = @_;
        my $mod10 = $n % 10;
        my $mod100 = $n % 100;
        if ($mod10 == 1 && $mod100 != 11) { 'one' }
        elsif ($mod10 >= 2 && $mod10 <= 4 && ($mod100 < 12 || $mod100 > 14)) { 'few' }
        else { 'many' }
      }""",
    "sl": """\
sub {
        my ($n) = @_;
        my $mod100 = $n % 100;
        if ($mod100 == 1) { 'one' }
        elsif ($mod100 == 2) { 'two' }
        elsif ($mod100 == 3 || $mod100 == 4) { 'few' }
        else { 'other' }
      }""",
    "ar": """\
sub {
        my ($n) = @_;
        if ($n == 0) { 'zero' }
        elsif ($n == 1) { 'one' }
        elsif ($n == 2) { 'two' }
        else {
          my $mod100 = $n % 100;
          if ($mod100 >= 3 && $mod100 <= 10) { 'few' }
          elsif ($mod100 >= 11 && $mod100 <= 99) { 'many' }
          else { 'other' }
        }
      }""",
    "lv": """\
sub {
        my ($n) = @_;
        my $mod10 = $n % 10;
        my $mod100 = $n % 100;
        if ($mod10 == 0 || ($mod100 >= 11 && $mod100 <= 19)) { 'zero' }
        elsif ($mod10 == 1 && $mod100 != 11) { 'one' }
        else { 'other' }
      }""",
    "he": """\
sub {
        my ($n) = @_;
        if ($n == 1) { 'one' }
        elsif ($n == 2) { 'two' }
        else { 'other' }
      }""",
    "mk": """\
sub {
        my ($n) = @_;
        my $mod10 = $n % 10;
        my $mod100 = $n % 100;
        if ($mod10 == 1 && $mod100 != 11) { 'one' }
        else { 'other' }
      }""",
    "cy": """\
sub {
        my ($n) = @_;
        if ($n == 0) { 'zero' }
        elsif ($n == 1) { 'one' }
        elsif ($n == 2) { 'two' }
        elsif ($n == 3) { 'few' }
        elsif ($n == 6) { 'many' }
        else { 'other' }
      }""",
    "gv": """\
sub {
        my ($n) = @_;
        my $mod10 = $n % 10;
        my $mod100 = $n % 100;
        if ($mod10 == 1) { 'one' }
        elsif ($mod10 == 2) { 'two' }
        elsif (grep { $mod100 == $_ } (0, 20, 40, 60, 80)) { 'few' }
        else { 'other' }
      }""",
    "gd": """\
sub {
        my ($n) = @_;
        if ($n == 1 || $n == 11) { 'one' }
        elsif ($n == 2 || $n == 12) { 'two' }
        elsif (($n >= 3 && $n <= 10) || ($n >= 13 && $n <= 19)) { 'few' }
        else { 'other' }
      }""",
    "ga": """\
sub {
        my ($n) = @_;
        if ($n == 1) { 'one' }
        elsif ($n == 2) { 'two' }
        elsif ($n >= 3 && $n <= 6) { 'few' }
        elsif ($n >= 7 && $n <= 10) { 'many' }
        else { 'other' }
      }""",
    "mt": """\
sub {
        my ($n) = @_;
        if ($n == 1) { 'one' }
        elsif ($n == 2) { 'two' }
        else {
          my $mod100 = $n % 100;
          if ($n == 0 || ($mod100 >= 3 && $mod100 <= 10)) { 'few' }
          elsif ($mod100 >= 11 && $mod100 <= 19) { 'many' }
          else { 'other' }
        }
      }""",
    "br": """\
sub {
        my ($n) = @_;
        my $mod10 = $n % 10;
        my $mod100 = $n % 100;
        if ($mod10 == 1 && $mod100 != 11 && $mod100 != 71 && $mod100 != 91) { 'one' }
        elsif ($mod10 == 2 && $mod100 != 12 && $mod100 != 72 && $mod100 != 92) { 'two' }
        elsif (grep { $mod10 == $_ } (3, 4, 9)) {
          if (!(($mod100 >= 10 && $mod100 <= 19) || ($mod100 >= 70 && $mod100 <= 79) || ($mod100 >= 90 && $mod100 <= 99))) { 'few' }
          else { 'other' }
        }
        elsif ($n != 0 && $n % 1000000 == 0) { 'many' }
        else { 'other' }
      }""",
    "kw": """\
sub {
        my ($n) = @_;
        if ($n == 0) { 'zero' }
        elsif ($n == 1) { 'one' }
        else {
          my $mod100 = $n % 100;
          if (grep { $mod100 == $_ } (2, 22, 42, 62, 82)) { 'two' }
          elsif (grep { $mod100 == $_ } (3, 23, 43, 63, 83)) { 'few' }
          elsif ($n != 1 && grep { $mod100 == $_ } (1, 21, 41, 61, 81)) { 'many' }
          else { 'other' }
        }
      }""",
    "shi": """\
sub {
        my ($n) = @_;
        if ($n == 0 || $n == 1) { 'one' }
        elsif ($n >= 2 && $n <= 10) { 'few' }
        else { 'other' }
      }""",
    "tzm": """\
sub {
        my ($n) = @_;
        if ($n == 0 || $n == 1 || ($n >= 11 && $n <= 99)) { 'one' }
        else { 'other' }
      }""",
}


def get_pl_plural(rule: str) -> str:
    return _PL[rule]
