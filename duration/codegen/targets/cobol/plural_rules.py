"""COBOL plural rule definitions for all 23 CLDR cardinal patterns."""

from __future__ import annotations

_COBOL = {
    "other_only": """\
               MOVE 6 TO WS-PLURAL-CAT""",
    "one_other": """\
               IF WS-PLURAL-N = 1
                   MOVE 2 TO WS-PLURAL-CAT
               ELSE
                   MOVE 6 TO WS-PLURAL-CAT
               END-IF""",
    "one_other_zero_one": """\
               IF WS-PLURAL-N = 0 OR WS-PLURAL-N = 1
                   MOVE 2 TO WS-PLURAL-CAT
               ELSE
                   MOVE 6 TO WS-PLURAL-CAT
               END-IF""",
    "cs_sk": """\
               IF WS-PLURAL-N = 1
                   MOVE 2 TO WS-PLURAL-CAT
               ELSE IF WS-PLURAL-N >= 2
                   AND WS-PLURAL-N <= 4
                   MOVE 4 TO WS-PLURAL-CAT
               ELSE
                   MOVE 6 TO WS-PLURAL-CAT
               END-IF""",
    "lt": """\
               DIVIDE WS-PLURAL-N BY 10
                   GIVING WS-PLURAL-TEMP
                   REMAINDER WS-PLURAL-MOD10
               DIVIDE WS-PLURAL-N BY 100
                   GIVING WS-PLURAL-TEMP
                   REMAINDER WS-PLURAL-MOD100
               IF WS-PLURAL-MOD10 = 1
                   AND WS-PLURAL-MOD100 NOT = 11
                   MOVE 2 TO WS-PLURAL-CAT
               ELSE IF WS-PLURAL-MOD10 >= 2
                   AND WS-PLURAL-MOD10 <= 9
                   AND (WS-PLURAL-MOD100 < 12
                       OR WS-PLURAL-MOD100 > 19)
                   MOVE 4 TO WS-PLURAL-CAT
               ELSE
                   MOVE 6 TO WS-PLURAL-CAT
               END-IF""",
    "ro": """\
               IF WS-PLURAL-N = 1
                   MOVE 2 TO WS-PLURAL-CAT
               ELSE
                   DIVIDE WS-PLURAL-N BY 100
                       GIVING WS-PLURAL-TEMP
                       REMAINDER WS-PLURAL-MOD100
                   IF WS-PLURAL-N = 0
                       OR (WS-PLURAL-MOD100 >= 1
                           AND WS-PLURAL-MOD100 <= 19)
                       MOVE 4 TO WS-PLURAL-CAT
                   ELSE
                       MOVE 6 TO WS-PLURAL-CAT
                   END-IF
               END-IF""",
    "slavic_bcs": """\
               DIVIDE WS-PLURAL-N BY 10
                   GIVING WS-PLURAL-TEMP
                   REMAINDER WS-PLURAL-MOD10
               DIVIDE WS-PLURAL-N BY 100
                   GIVING WS-PLURAL-TEMP
                   REMAINDER WS-PLURAL-MOD100
               IF WS-PLURAL-MOD10 = 1
                   AND WS-PLURAL-MOD100 NOT = 11
                   MOVE 2 TO WS-PLURAL-CAT
               ELSE IF WS-PLURAL-MOD10 >= 2
                   AND WS-PLURAL-MOD10 <= 4
                   AND (WS-PLURAL-MOD100 < 12
                       OR WS-PLURAL-MOD100 > 14)
                   MOVE 4 TO WS-PLURAL-CAT
               ELSE
                   MOVE 6 TO WS-PLURAL-CAT
               END-IF""",
    "pl": """\
               DIVIDE WS-PLURAL-N BY 10
                   GIVING WS-PLURAL-TEMP
                   REMAINDER WS-PLURAL-MOD10
               DIVIDE WS-PLURAL-N BY 100
                   GIVING WS-PLURAL-TEMP
                   REMAINDER WS-PLURAL-MOD100
               IF WS-PLURAL-N = 1
                   MOVE 2 TO WS-PLURAL-CAT
               ELSE IF WS-PLURAL-MOD10 >= 2
                   AND WS-PLURAL-MOD10 <= 4
                   AND (WS-PLURAL-MOD100 < 12
                       OR WS-PLURAL-MOD100 > 14)
                   MOVE 4 TO WS-PLURAL-CAT
               ELSE
                   MOVE 5 TO WS-PLURAL-CAT
               END-IF""",
    "ru_uk": """\
               DIVIDE WS-PLURAL-N BY 10
                   GIVING WS-PLURAL-TEMP
                   REMAINDER WS-PLURAL-MOD10
               DIVIDE WS-PLURAL-N BY 100
                   GIVING WS-PLURAL-TEMP
                   REMAINDER WS-PLURAL-MOD100
               IF WS-PLURAL-MOD10 = 1
                   AND WS-PLURAL-MOD100 NOT = 11
                   MOVE 2 TO WS-PLURAL-CAT
               ELSE IF WS-PLURAL-MOD10 >= 2
                   AND WS-PLURAL-MOD10 <= 4
                   AND (WS-PLURAL-MOD100 < 12
                       OR WS-PLURAL-MOD100 > 14)
                   MOVE 4 TO WS-PLURAL-CAT
               ELSE
                   MOVE 5 TO WS-PLURAL-CAT
               END-IF""",
    "sl": """\
               DIVIDE WS-PLURAL-N BY 100
                   GIVING WS-PLURAL-TEMP
                   REMAINDER WS-PLURAL-MOD100
               IF WS-PLURAL-MOD100 = 1
                   MOVE 2 TO WS-PLURAL-CAT
               ELSE IF WS-PLURAL-MOD100 = 2
                   MOVE 3 TO WS-PLURAL-CAT
               ELSE IF WS-PLURAL-MOD100 = 3
                   OR WS-PLURAL-MOD100 = 4
                   MOVE 4 TO WS-PLURAL-CAT
               ELSE
                   MOVE 6 TO WS-PLURAL-CAT
               END-IF""",
    "ar": """\
               IF WS-PLURAL-N = 0
                   MOVE 1 TO WS-PLURAL-CAT
               ELSE IF WS-PLURAL-N = 1
                   MOVE 2 TO WS-PLURAL-CAT
               ELSE IF WS-PLURAL-N = 2
                   MOVE 3 TO WS-PLURAL-CAT
               ELSE
                   DIVIDE WS-PLURAL-N BY 100
                       GIVING WS-PLURAL-TEMP
                       REMAINDER WS-PLURAL-MOD100
                   IF WS-PLURAL-MOD100 >= 3
                       AND WS-PLURAL-MOD100 <= 10
                       MOVE 4 TO WS-PLURAL-CAT
                   ELSE IF WS-PLURAL-MOD100 >= 11
                       AND WS-PLURAL-MOD100 <= 99
                       MOVE 5 TO WS-PLURAL-CAT
                   ELSE
                       MOVE 6 TO WS-PLURAL-CAT
                   END-IF
               END-IF""",
    "lv": """\
               DIVIDE WS-PLURAL-N BY 10
                   GIVING WS-PLURAL-TEMP
                   REMAINDER WS-PLURAL-MOD10
               DIVIDE WS-PLURAL-N BY 100
                   GIVING WS-PLURAL-TEMP
                   REMAINDER WS-PLURAL-MOD100
               IF WS-PLURAL-MOD10 = 0
                   OR (WS-PLURAL-MOD100 >= 11
                       AND WS-PLURAL-MOD100 <= 19)
                   MOVE 1 TO WS-PLURAL-CAT
               ELSE IF WS-PLURAL-MOD10 = 1
                   AND WS-PLURAL-MOD100 NOT = 11
                   MOVE 2 TO WS-PLURAL-CAT
               ELSE
                   MOVE 6 TO WS-PLURAL-CAT
               END-IF""",
    "he": """\
               IF WS-PLURAL-N = 1
                   MOVE 2 TO WS-PLURAL-CAT
               ELSE IF WS-PLURAL-N = 2
                   MOVE 3 TO WS-PLURAL-CAT
               ELSE
                   MOVE 6 TO WS-PLURAL-CAT
               END-IF""",
    "mk": """\
               DIVIDE WS-PLURAL-N BY 10
                   GIVING WS-PLURAL-TEMP
                   REMAINDER WS-PLURAL-MOD10
               DIVIDE WS-PLURAL-N BY 100
                   GIVING WS-PLURAL-TEMP
                   REMAINDER WS-PLURAL-MOD100
               IF WS-PLURAL-MOD10 = 1
                   AND WS-PLURAL-MOD100 NOT = 11
                   MOVE 2 TO WS-PLURAL-CAT
               ELSE
                   MOVE 6 TO WS-PLURAL-CAT
               END-IF""",
    "cy": """\
               IF WS-PLURAL-N = 0
                   MOVE 1 TO WS-PLURAL-CAT
               ELSE IF WS-PLURAL-N = 1
                   MOVE 2 TO WS-PLURAL-CAT
               ELSE IF WS-PLURAL-N = 2
                   MOVE 3 TO WS-PLURAL-CAT
               ELSE IF WS-PLURAL-N = 3
                   MOVE 4 TO WS-PLURAL-CAT
               ELSE IF WS-PLURAL-N = 6
                   MOVE 5 TO WS-PLURAL-CAT
               ELSE
                   MOVE 6 TO WS-PLURAL-CAT
               END-IF""",
    "gv": """\
               DIVIDE WS-PLURAL-N BY 10
                   GIVING WS-PLURAL-TEMP
                   REMAINDER WS-PLURAL-MOD10
               DIVIDE WS-PLURAL-N BY 100
                   GIVING WS-PLURAL-TEMP
                   REMAINDER WS-PLURAL-MOD100
               IF WS-PLURAL-MOD10 = 1
                   MOVE 2 TO WS-PLURAL-CAT
               ELSE IF WS-PLURAL-MOD10 = 2
                   MOVE 3 TO WS-PLURAL-CAT
               ELSE IF WS-PLURAL-MOD100 = 0
                   OR WS-PLURAL-MOD100 = 20
                   OR WS-PLURAL-MOD100 = 40
                   OR WS-PLURAL-MOD100 = 60
                   OR WS-PLURAL-MOD100 = 80
                   MOVE 4 TO WS-PLURAL-CAT
               ELSE
                   MOVE 6 TO WS-PLURAL-CAT
               END-IF""",
    "gd": """\
               IF WS-PLURAL-N = 1 OR WS-PLURAL-N = 11
                   MOVE 2 TO WS-PLURAL-CAT
               ELSE IF WS-PLURAL-N = 2 OR WS-PLURAL-N = 12
                   MOVE 3 TO WS-PLURAL-CAT
               ELSE IF (WS-PLURAL-N >= 3
                   AND WS-PLURAL-N <= 10)
                   OR (WS-PLURAL-N >= 13
                   AND WS-PLURAL-N <= 19)
                   MOVE 4 TO WS-PLURAL-CAT
               ELSE
                   MOVE 6 TO WS-PLURAL-CAT
               END-IF""",
    "ga": """\
               IF WS-PLURAL-N = 1
                   MOVE 2 TO WS-PLURAL-CAT
               ELSE IF WS-PLURAL-N = 2
                   MOVE 3 TO WS-PLURAL-CAT
               ELSE IF WS-PLURAL-N >= 3
                   AND WS-PLURAL-N <= 6
                   MOVE 4 TO WS-PLURAL-CAT
               ELSE IF WS-PLURAL-N >= 7
                   AND WS-PLURAL-N <= 10
                   MOVE 5 TO WS-PLURAL-CAT
               ELSE
                   MOVE 6 TO WS-PLURAL-CAT
               END-IF""",
    "mt": """\
               IF WS-PLURAL-N = 1
                   MOVE 2 TO WS-PLURAL-CAT
               ELSE IF WS-PLURAL-N = 2
                   MOVE 3 TO WS-PLURAL-CAT
               ELSE
                   DIVIDE WS-PLURAL-N BY 100
                       GIVING WS-PLURAL-TEMP
                       REMAINDER WS-PLURAL-MOD100
                   IF WS-PLURAL-N = 0
                       OR (WS-PLURAL-MOD100 >= 3
                           AND WS-PLURAL-MOD100 <= 10)
                       MOVE 4 TO WS-PLURAL-CAT
                   ELSE IF WS-PLURAL-MOD100 >= 11
                       AND WS-PLURAL-MOD100 <= 19
                       MOVE 5 TO WS-PLURAL-CAT
                   ELSE
                       MOVE 6 TO WS-PLURAL-CAT
                   END-IF
               END-IF""",
    "br": """\
               DIVIDE WS-PLURAL-N BY 10
                   GIVING WS-PLURAL-TEMP
                   REMAINDER WS-PLURAL-MOD10
               DIVIDE WS-PLURAL-N BY 100
                   GIVING WS-PLURAL-TEMP
                   REMAINDER WS-PLURAL-MOD100
               IF WS-PLURAL-MOD10 = 1
                   AND WS-PLURAL-MOD100 NOT = 11
                   AND WS-PLURAL-MOD100 NOT = 71
                   AND WS-PLURAL-MOD100 NOT = 91
                   MOVE 2 TO WS-PLURAL-CAT
               ELSE IF WS-PLURAL-MOD10 = 2
                   AND WS-PLURAL-MOD100 NOT = 12
                   AND WS-PLURAL-MOD100 NOT = 72
                   AND WS-PLURAL-MOD100 NOT = 92
                   MOVE 3 TO WS-PLURAL-CAT
               ELSE IF (WS-PLURAL-MOD10 = 3
                   OR WS-PLURAL-MOD10 = 4
                   OR WS-PLURAL-MOD10 = 9)
                   AND NOT (WS-PLURAL-MOD100 >= 10
                       AND WS-PLURAL-MOD100 <= 19)
                   AND NOT (WS-PLURAL-MOD100 >= 70
                       AND WS-PLURAL-MOD100 <= 79)
                   AND NOT (WS-PLURAL-MOD100 >= 90
                       AND WS-PLURAL-MOD100 <= 99)
                   MOVE 4 TO WS-PLURAL-CAT
               ELSE IF WS-PLURAL-N NOT = 0
                   DIVIDE WS-PLURAL-N BY 1000000
                       GIVING WS-PLURAL-TEMP
                       REMAINDER WS-PLURAL-MOD100
                   IF WS-PLURAL-MOD100 = 0
                       MOVE 5 TO WS-PLURAL-CAT
                   ELSE
                       MOVE 6 TO WS-PLURAL-CAT
                   END-IF
               ELSE
                   MOVE 6 TO WS-PLURAL-CAT
               END-IF""",
    "kw": """\
               DIVIDE WS-PLURAL-N BY 100
                   GIVING WS-PLURAL-TEMP
                   REMAINDER WS-PLURAL-MOD100
               IF WS-PLURAL-N = 0
                   MOVE 1 TO WS-PLURAL-CAT
               ELSE IF WS-PLURAL-N = 1
                   MOVE 2 TO WS-PLURAL-CAT
               ELSE IF WS-PLURAL-MOD100 = 2
                   OR WS-PLURAL-MOD100 = 22
                   OR WS-PLURAL-MOD100 = 42
                   OR WS-PLURAL-MOD100 = 62
                   OR WS-PLURAL-MOD100 = 82
                   MOVE 3 TO WS-PLURAL-CAT
               ELSE IF WS-PLURAL-MOD100 = 3
                   OR WS-PLURAL-MOD100 = 23
                   OR WS-PLURAL-MOD100 = 43
                   OR WS-PLURAL-MOD100 = 63
                   OR WS-PLURAL-MOD100 = 83
                   MOVE 4 TO WS-PLURAL-CAT
               ELSE IF WS-PLURAL-N NOT = 1
                   AND (WS-PLURAL-MOD100 = 1
                       OR WS-PLURAL-MOD100 = 21
                       OR WS-PLURAL-MOD100 = 41
                       OR WS-PLURAL-MOD100 = 61
                       OR WS-PLURAL-MOD100 = 81)
                   MOVE 5 TO WS-PLURAL-CAT
               ELSE
                   MOVE 6 TO WS-PLURAL-CAT
               END-IF""",
    "shi": """\
               IF WS-PLURAL-N = 0 OR WS-PLURAL-N = 1
                   MOVE 2 TO WS-PLURAL-CAT
               ELSE IF WS-PLURAL-N >= 2
                   AND WS-PLURAL-N <= 10
                   MOVE 4 TO WS-PLURAL-CAT
               ELSE
                   MOVE 6 TO WS-PLURAL-CAT
               END-IF""",
    "tzm": """\
               IF WS-PLURAL-N = 0
                   OR WS-PLURAL-N = 1
                   OR (WS-PLURAL-N >= 11
                       AND WS-PLURAL-N <= 99)
                   MOVE 2 TO WS-PLURAL-CAT
               ELSE
                   MOVE 6 TO WS-PLURAL-CAT
               END-IF""",
}


def get_cobol_plural(rule: str) -> str:
    return _COBOL[rule]
