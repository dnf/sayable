"""OCaml plural rule definitions for all 23 patterns."""

from __future__ import annotations

_ML = {
    "other_only": "fun _ -> Other",
    "one_other": "fun n -> if n = 1 then One else Other",
    "one_other_zero_one": "fun n -> if n = 0 || n = 1 then One else Other",
    "cs_sk": "fun n -> if n = 1 then One else if n >= 2 && n <= 4 then Few else Other",
    "lt": "fun n -> let mod10 = n mod 10 in let mod100 = n mod 100 in if mod10 = 1 && mod100 <> 11 then One else if mod10 >= 2 && mod10 <= 9 && (mod100 < 12 || mod100 > 19) then Few else Other",
    "ro": "fun n -> if n = 1 then One else if n = 0 || (n mod 100 >= 1 && n mod 100 <= 19) then Few else Other",
    "slavic_bcs": "fun n -> let mod10 = n mod 10 in let mod100 = n mod 100 in if mod10 = 1 && mod100 <> 11 then One else if mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14) then Few else Other",
    "pl": "fun n -> if n = 1 then One else let mod10 = n mod 10 in let mod100 = n mod 100 in if mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14) then Few else Many",
    "ru_uk": "fun n -> let mod10 = n mod 10 in let mod100 = n mod 100 in if mod10 = 1 && mod100 <> 11 then One else if mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14) then Few else Many",
    "sl": "fun n -> let mod100 = n mod 100 in if mod100 = 1 then One else if mod100 = 2 then Two else if mod100 = 3 || mod100 = 4 then Few else Other",
    "ar": "fun n -> if n = 0 then Zero else if n = 1 then One else if n = 2 then Two else let mod100 = n mod 100 in if mod100 >= 3 && mod100 <= 10 then Few else if mod100 >= 11 && mod100 <= 99 then Many else Other",
    "lv": "fun n -> let mod10 = n mod 10 in let mod100 = n mod 100 in if mod10 = 0 || (mod100 >= 11 && mod100 <= 19) then Zero else if mod10 = 1 && mod100 <> 11 then One else Other",
    "he": "fun n -> if n = 1 then One else if n = 2 then Two else Other",
    "mk": "fun n -> let mod10 = n mod 10 in let mod100 = n mod 100 in if mod10 = 1 && mod100 <> 11 then One else Other",
    "cy": "fun n -> if n = 0 then Zero else if n = 1 then One else if n = 2 then Two else if n = 3 then Few else if n = 6 then Many else Other",
    "gv": "fun n -> let mod10 = n mod 10 in let mod100 = n mod 100 in if mod10 = 1 then One else if mod10 = 2 then Two else if mod100 = 0 || mod100 = 20 || mod100 = 40 || mod100 = 60 || mod100 = 80 then Few else Other",
    "gd": "fun n -> if n = 1 || n = 11 then One else if n = 2 || n = 12 then Two else if (n >= 3 && n <= 10) || (n >= 13 && n <= 19) then Few else Other",
    "ga": "fun n -> if n = 1 then One else if n = 2 then Two else if n >= 3 && n <= 6 then Few else if n >= 7 && n <= 10 then Many else Other",
    "mt": "fun n -> if n = 1 then One else if n = 2 then Two else let mod100 = n mod 100 in if n = 0 || (mod100 >= 3 && mod100 <= 10) then Few else if mod100 >= 11 && mod100 <= 19 then Many else Other",
    "br": "fun n -> let mod10 = n mod 10 in let mod100 = n mod 100 in if mod10 = 1 && mod100 <> 11 && mod100 <> 71 && mod100 <> 91 then One else if mod10 = 2 && mod100 <> 12 && mod100 <> 72 && mod100 <> 92 then Two else if (mod10 = 3 || mod10 = 4 || mod10 = 9) && (mod100 < 10 || mod100 > 19) && (mod100 < 70 || mod100 > 79) && (mod100 < 90 || mod100 > 99) then Few else if n <> 0 && n mod 1000000 = 0 then Many else Other",
    "kw": "fun n -> if n = 0 then Zero else if n = 1 then One else let mod100 = n mod 100 in if mod100 = 2 || mod100 = 22 || mod100 = 42 || mod100 = 62 || mod100 = 82 then Two else if mod100 = 3 || mod100 = 23 || mod100 = 43 || mod100 = 63 || mod100 = 83 then Few else if n <> 1 && (mod100 = 1 || mod100 = 21 || mod100 = 41 || mod100 = 61 || mod100 = 81) then Many else Other",
    "shi": "fun n -> if n = 0 || n = 1 then One else if n >= 2 && n <= 10 then Few else Other",
    "tzm": "fun n -> if n = 0 || n = 1 || (n >= 11 && n <= 99) then One else Other",
}


def get_ml_plural(rule: str) -> str:
    """Return the OCaml expression for the given plural rule name."""
    return _ML[rule]
