*> SayableDate.cbl - PROCEDURE DIVISION copybook for sayable-date
*> Contains the core formatting paragraphs.
*> Included via COPY in the main test program.
*> Requires: Types.cbl (WORKING-STORAGE) and Locales.cbl (locale data)

*> ============================================================
*> FORMAT-DATE: Format a calendar date in locale-appropriate form
*> Input:  WS-FMT-DATE, WS-FMT-COMPACTNESS
*>         WS-ACT-* must be loaded via GET-LOCALE
*> Output: WS-FORMAT-RESULT
*> ============================================================
       FORMAT-DATE.
           MOVE SPACES TO WS-FORMAT-RESULT

           IF FUNCTION TRIM(WS-FMT-DATE) = SPACES
               EXIT PARAGRAPH
           END-IF
           MOVE WS-FMT-DATE TO WS-DATE-STR
           MOVE WS-FMT-DATE-LEN TO WS-DATE-LEN
           PERFORM PARSE-DATE-INPUT
           IF WS-PARSE-OK = 0
               EXIT PARAGRAPH
           END-IF
           MOVE WS-PARSED-YEAR TO WS-DATE-YEAR
           MOVE WS-PARSED-MONTH TO WS-DATE-MONTH
           MOVE WS-PARSED-DAY TO WS-DATE-DAY

           PERFORM COPY-LOCALE-TO-EFFECTIVE
           PERFORM APPLY-COMPACTNESS-OVERRIDE

           MOVE 0 TO WS-INCLUDE-YEAR
           PERFORM FORMAT-ABSOLUTE
           .

*> ============================================================
*> FORMAT-DATE-WITH-YEAR: Format a date with year
*> ============================================================
       FORMAT-DATE-WITH-YEAR.
           MOVE SPACES TO WS-FORMAT-RESULT

           IF FUNCTION TRIM(WS-FMT-DATE) = SPACES
               EXIT PARAGRAPH
           END-IF
           MOVE WS-FMT-DATE TO WS-DATE-STR
           MOVE WS-FMT-DATE-LEN TO WS-DATE-LEN
           PERFORM PARSE-DATE-INPUT
           IF WS-PARSE-OK = 0
               EXIT PARAGRAPH
           END-IF
           MOVE WS-PARSED-YEAR TO WS-DATE-YEAR
           MOVE WS-PARSED-MONTH TO WS-DATE-MONTH
           MOVE WS-PARSED-DAY TO WS-DATE-DAY

           PERFORM COPY-LOCALE-TO-EFFECTIVE
           PERFORM APPLY-COMPACTNESS-OVERRIDE

           MOVE 1 TO WS-INCLUDE-YEAR
           PERFORM FORMAT-ABSOLUTE
           .

*> ============================================================
*> FORMAT-RELATIVE: Format a date relative to as-of
*> ============================================================
       FORMAT-RELATIVE.
           MOVE SPACES TO WS-FORMAT-RESULT

           IF FUNCTION TRIM(WS-FMT-DATE) = SPACES
               EXIT PARAGRAPH
           END-IF
           IF FUNCTION TRIM(WS-FMT-AS-OF) = SPACES
               EXIT PARAGRAPH
           END-IF

           MOVE WS-FMT-DATE TO WS-DATE-STR
           MOVE WS-FMT-DATE-LEN TO WS-DATE-LEN
           PERFORM PARSE-DATE-INPUT
           IF WS-PARSE-OK = 0
               EXIT PARAGRAPH
           END-IF
           MOVE WS-PARSED-YEAR TO WS-DATE-YEAR
           MOVE WS-PARSED-MONTH TO WS-DATE-MONTH
           MOVE WS-PARSED-DAY TO WS-DATE-DAY

           MOVE WS-FMT-AS-OF TO WS-DATE-STR
           MOVE WS-FMT-AS-OF-LEN TO WS-DATE-LEN
           PERFORM PARSE-DATE-INPUT
           IF WS-PARSE-OK = 0
               EXIT PARAGRAPH
           END-IF
           MOVE WS-PARSED-YEAR TO WS-ASOF-YEAR
           MOVE WS-PARSED-MONTH TO WS-ASOF-MONTH
           MOVE WS-PARSED-DAY TO WS-ASOF-DAY

           PERFORM COPY-LOCALE-TO-EFFECTIVE
           PERFORM APPLY-COMPACTNESS-OVERRIDE

           *> Calculate Julian days and diff
           MOVE WS-DATE-YEAR TO WS-JD-CALC-YEAR
           MOVE WS-DATE-MONTH TO WS-JD-CALC-MONTH
           MOVE WS-DATE-DAY TO WS-JD-CALC-DAY
           PERFORM CALC-JULIAN-DAY
           MOVE WS-JD-CALC-RESULT TO WS-JD1

           MOVE WS-ASOF-YEAR TO WS-JD-CALC-YEAR
           MOVE WS-ASOF-MONTH TO WS-JD-CALC-MONTH
           MOVE WS-ASOF-DAY TO WS-JD-CALC-DAY
           PERFORM CALC-JULIAN-DAY
           MOVE WS-JD-CALC-RESULT TO WS-JD2

           COMPUTE WS-DIFF-DAYS = WS-JD1 - WS-JD2

           *> Today
           IF WS-DIFF-DAYS = 0
               MOVE WS-EFF-TODAY TO WS-FORMAT-RESULT
               EXIT PARAGRAPH
           END-IF

           *> Tomorrow
           IF WS-DIFF-DAYS = 1
               MOVE WS-EFF-TOMORROW TO WS-FORMAT-RESULT
               EXIT PARAGRAPH
           END-IF

           *> Yesterday
           IF WS-DIFF-DAYS = -1
               MOVE WS-EFF-YESTERDAY TO WS-FORMAT-RESULT
               EXIT PARAGRAPH
           END-IF

           *> Day after tomorrow (optional, skip in compact)
           IF WS-DIFF-DAYS = 2
               AND FUNCTION TRIM(WS-ACT-DAY-AFTER-TOMORROW)
                   NOT = SPACES
               AND WS-FMT-COMPACTNESS NOT = PT-COMPACT
               MOVE WS-ACT-DAY-AFTER-TOMORROW
                   TO WS-FORMAT-RESULT
               EXIT PARAGRAPH
           END-IF

           *> Day before yesterday (optional, skip in compact)
           IF WS-DIFF-DAYS = -2
               AND FUNCTION TRIM(WS-ACT-DAY-BEFORE-YESTERDAY)
                   NOT = SPACES
               AND WS-FMT-COMPACTNESS NOT = PT-COMPACT
               MOVE WS-ACT-DAY-BEFORE-YESTERDAY
                   TO WS-FORMAT-RESULT
               EXIT PARAGRAPH
           END-IF

           *> Compact mode: skip weekday tiers
           IF WS-FMT-COMPACTNESS = PT-COMPACT
               IF WS-DATE-YEAR NOT = WS-ASOF-YEAR
                   MOVE 1 TO WS-INCLUDE-YEAR
               ELSE
                   MOVE 0 TO WS-INCLUDE-YEAR
               END-IF
               PERFORM FORMAT-ABSOLUTE
               EXIT PARAGRAPH
           END-IF

           *> This weekday (+2 to +6)
           IF WS-DIFF-DAYS >= 2 AND WS-DIFF-DAYS <= 6
               AND FUNCTION TRIM(WS-ACT-THIS-WEEKDAY)
                   NOT = SPACES
               PERFORM CALC-WEEKDAY
               MOVE WS-EFF-WEEKDAY(WS-DOW) TO WS-WEEKDAY-NAME
               MOVE WS-ACT-THIS-WEEKDAY TO WS-REPLACE-SRC
               MOVE "{weekday}" TO WS-REPLACE-MARKER
               MOVE FUNCTION TRIM(WS-WEEKDAY-NAME)
                   TO WS-REPLACE-REPL
               PERFORM REPLACE-FIRST
               MOVE WS-REPLACE-RESULT TO WS-FORMAT-RESULT
               EXIT PARAGRAPH
           END-IF

           *> Last weekday (-2 to -6)
           IF WS-DIFF-DAYS >= -6 AND WS-DIFF-DAYS <= -2
               AND FUNCTION TRIM(WS-ACT-LAST-WEEKDAY)
                   NOT = SPACES
               PERFORM CALC-WEEKDAY
               MOVE WS-EFF-WEEKDAY(WS-DOW) TO WS-WEEKDAY-NAME
               MOVE WS-ACT-LAST-WEEKDAY TO WS-REPLACE-SRC
               MOVE "{weekday}" TO WS-REPLACE-MARKER
               MOVE FUNCTION TRIM(WS-WEEKDAY-NAME)
                   TO WS-REPLACE-REPL
               PERFORM REPLACE-FIRST
               MOVE WS-REPLACE-RESULT TO WS-FORMAT-RESULT
               EXIT PARAGRAPH
           END-IF

           *> Next weekday (+7 to +13)
           IF WS-DIFF-DAYS >= 7 AND WS-DIFF-DAYS <= 13
               AND FUNCTION TRIM(WS-ACT-NEXT-WEEKDAY)
                   NOT = SPACES
               PERFORM CALC-WEEKDAY
               MOVE WS-EFF-WEEKDAY(WS-DOW) TO WS-WEEKDAY-NAME
               MOVE WS-ACT-NEXT-WEEKDAY TO WS-REPLACE-SRC
               MOVE "{weekday}" TO WS-REPLACE-MARKER
               MOVE FUNCTION TRIM(WS-WEEKDAY-NAME)
                   TO WS-REPLACE-REPL
               PERFORM REPLACE-FIRST
               MOVE WS-REPLACE-RESULT TO WS-FORMAT-RESULT
               EXIT PARAGRAPH
           END-IF

           *> Calendar fallback
           IF WS-DATE-YEAR NOT = WS-ASOF-YEAR
               MOVE 1 TO WS-INCLUDE-YEAR
           ELSE
               MOVE 0 TO WS-INCLUDE-YEAR
           END-IF
           PERFORM FORMAT-ABSOLUTE
           .

*> ============================================================
*> FORMAT-ABSOLUTE: Format a date as absolute calendar reference
*> Input:  WS-DATE-YEAR, WS-DATE-MONTH, WS-DATE-DAY,
*>         WS-INCLUDE-YEAR, WS-EFF-*
*> Output: WS-FORMAT-RESULT
*> ============================================================
       FORMAT-ABSOLUTE.
           MOVE SPACES TO WS-FORMAT-RESULT

           *> Format day number as string
           MOVE WS-DATE-DAY TO WS-NUM-TO-STR-INPUT
           PERFORM NUM-TO-STR
           MOVE WS-NUM-TO-STR-RESULT TO WS-DAY-STR

           *> Look up exception for this day
           MOVE 0 TO WS-EXC-FOUND
           PERFORM VARYING WS-I FROM 1 BY 1
               UNTIL WS-I > WS-EFF-DAY-FMT-EXC-COUNT
               OR WS-EXC-FOUND = 1
               IF FUNCTION TRIM(WS-EFF-DAY-FMT-EXC-KEY(WS-I))
                   = FUNCTION TRIM(WS-DAY-STR)
                   MOVE WS-EFF-DAY-FMT-EXC-VAL(WS-I)
                       TO WS-PATTERN
                   MOVE 1 TO WS-EXC-FOUND
               END-IF
           END-PERFORM
           IF WS-EXC-FOUND = 0
               MOVE WS-EFF-DAY-FORMAT TO WS-PATTERN
           END-IF

           *> Replace {n} in day format with day number
           MOVE WS-PATTERN TO WS-REPLACE-SRC
           MOVE "{n}" TO WS-REPLACE-MARKER
           MOVE FUNCTION TRIM(WS-DAY-STR) TO WS-REPLACE-REPL
           PERFORM REPLACE-FIRST
           MOVE WS-REPLACE-RESULT TO WS-FORMATTED-DAY

           *> Pick month name (genitive if available)
           IF WS-EFF-HAS-MID = 1
               MOVE WS-EFF-MONTH-IN-DATE(WS-DATE-MONTH)
                   TO WS-MONTH-NAME
           ELSE
               MOVE WS-EFF-MONTH(WS-DATE-MONTH)
                   TO WS-MONTH-NAME
           END-IF

           *> Select pattern
           IF WS-INCLUDE-YEAR = 1
               MOVE WS-EFF-DATE-PAT-WITH-YEAR TO WS-PATTERN
           ELSE
               MOVE WS-EFF-DATE-PATTERN TO WS-PATTERN
           END-IF

           *> Replace {month}
           MOVE WS-PATTERN TO WS-REPLACE-SRC
           MOVE "{month}" TO WS-REPLACE-MARKER
           MOVE FUNCTION TRIM(WS-MONTH-NAME) TO WS-REPLACE-REPL
           PERFORM REPLACE-FIRST
           MOVE WS-REPLACE-RESULT TO WS-PATTERN

           *> Replace {day}
           MOVE WS-PATTERN TO WS-REPLACE-SRC
           MOVE "{day}" TO WS-REPLACE-MARKER
           MOVE FUNCTION TRIM(WS-FORMATTED-DAY)
               TO WS-REPLACE-REPL
           PERFORM REPLACE-FIRST
           MOVE WS-REPLACE-RESULT TO WS-PATTERN

           *> Replace {d} (bare day number)
           MOVE WS-PATTERN TO WS-REPLACE-SRC
           MOVE "{d}" TO WS-REPLACE-MARKER
           MOVE FUNCTION TRIM(WS-DAY-STR) TO WS-REPLACE-REPL
           PERFORM REPLACE-FIRST
           MOVE WS-REPLACE-RESULT TO WS-PATTERN

           *> Replace {m} (bare month number)
           MOVE WS-DATE-MONTH TO WS-NUM-TO-STR-INPUT
           PERFORM NUM-TO-STR
           MOVE WS-PATTERN TO WS-REPLACE-SRC
           MOVE "{m}" TO WS-REPLACE-MARKER
           MOVE FUNCTION TRIM(WS-NUM-TO-STR-RESULT)
               TO WS-REPLACE-REPL
           PERFORM REPLACE-FIRST
           MOVE WS-REPLACE-RESULT TO WS-PATTERN

           *> Replace {year} and {yy} if including year
           IF WS-INCLUDE-YEAR = 1
               MOVE WS-DATE-YEAR TO WS-NUM-TO-STR-INPUT
               PERFORM NUM-TO-STR
               MOVE WS-PATTERN TO WS-REPLACE-SRC
               MOVE "{year}" TO WS-REPLACE-MARKER
               MOVE FUNCTION TRIM(WS-NUM-TO-STR-RESULT)
                   TO WS-REPLACE-REPL
               PERFORM REPLACE-FIRST
               MOVE WS-REPLACE-RESULT TO WS-PATTERN

               *> {yy} = last 2 digits, zero-padded
               COMPUTE WS-YY-DIGITS =
                   FUNCTION MOD(WS-DATE-YEAR, 100)
               MOVE WS-PATTERN TO WS-REPLACE-SRC
               MOVE "{yy}" TO WS-REPLACE-MARKER
               MOVE WS-YY-DIGITS TO WS-REPLACE-REPL
               PERFORM REPLACE-FIRST
               MOVE WS-REPLACE-RESULT TO WS-PATTERN
           END-IF

           MOVE WS-PATTERN TO WS-FORMAT-RESULT
           .

*> ============================================================
*> CALC-WEEKDAY: Calculate day of week (1=Sunday..7=Saturday)
*> Uses WS-DATE-YEAR, WS-DATE-MONTH, WS-DATE-DAY
*> Output: WS-DOW
*> ============================================================
       CALC-WEEKDAY.
           MOVE WS-DATE-YEAR TO WS-JD-CALC-YEAR
           MOVE WS-DATE-MONTH TO WS-JD-CALC-MONTH
           MOVE WS-DATE-DAY TO WS-JD-CALC-DAY
           PERFORM CALC-JULIAN-DAY
           COMPUTE WS-DOW =
               FUNCTION MOD(WS-JD-CALC-RESULT + 1, 7) + 1
           .

*> ============================================================
*> COPY-LOCALE-TO-EFFECTIVE: Copy WS-ACT-* to WS-EFF-*
*> ============================================================
       COPY-LOCALE-TO-EFFECTIVE.
           PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 12
               MOVE WS-ACT-MONTH(WS-I) TO WS-EFF-MONTH(WS-I)
           END-PERFORM
           IF WS-ACT-HAS-MONTHS-IN-DATE = 1
               MOVE 1 TO WS-EFF-HAS-MID
               PERFORM VARYING WS-I FROM 1 BY 1
                   UNTIL WS-I > 12
                   MOVE WS-ACT-MONTH-IN-DATE(WS-I)
                       TO WS-EFF-MONTH-IN-DATE(WS-I)
               END-PERFORM
           ELSE
               MOVE 0 TO WS-EFF-HAS-MID
           END-IF
           PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 7
               MOVE WS-ACT-WEEKDAY(WS-I)
                   TO WS-EFF-WEEKDAY(WS-I)
           END-PERFORM
           MOVE WS-ACT-DAY-FORMAT TO WS-EFF-DAY-FORMAT
           MOVE WS-ACT-DAY-FMT-EXC-COUNT
               TO WS-EFF-DAY-FMT-EXC-COUNT
           PERFORM VARYING WS-I FROM 1 BY 1
               UNTIL WS-I > WS-ACT-DAY-FMT-EXC-COUNT
               MOVE WS-ACT-DAY-FMT-EXC-KEY(WS-I)
                   TO WS-EFF-DAY-FMT-EXC-KEY(WS-I)
               MOVE WS-ACT-DAY-FMT-EXC-VAL(WS-I)
                   TO WS-EFF-DAY-FMT-EXC-VAL(WS-I)
           END-PERFORM
           MOVE WS-ACT-DATE-PATTERN TO WS-EFF-DATE-PATTERN
           MOVE WS-ACT-DATE-PAT-WITH-YEAR
               TO WS-EFF-DATE-PAT-WITH-YEAR
           MOVE WS-ACT-TODAY TO WS-EFF-TODAY
           MOVE WS-ACT-TOMORROW TO WS-EFF-TOMORROW
           MOVE WS-ACT-YESTERDAY TO WS-EFF-YESTERDAY
           .

*> ============================================================
*> APPLY-COMPACTNESS-OVERRIDE: Override effective fields
*> ============================================================
       APPLY-COMPACTNESS-OVERRIDE.
           IF WS-FMT-COMPACTNESS = PT-SHORT
               AND WS-ACT-HAS-SHORT = 1
               PERFORM APPLY-SHORT-OVERRIDE
           END-IF
           IF WS-FMT-COMPACTNESS = PT-COMPACT
               AND WS-ACT-HAS-COMPACT = 1
               PERFORM APPLY-COMPACT-OVERRIDE
           END-IF
           .

       APPLY-SHORT-OVERRIDE.
           IF WS-ACT-SHORT-HAS-MONTHS = 1
               PERFORM VARYING WS-I FROM 1 BY 1
                   UNTIL WS-I > 12
                   MOVE WS-ACT-SHORT-MONTH(WS-I)
                       TO WS-EFF-MONTH(WS-I)
               END-PERFORM
           END-IF
           IF WS-ACT-SHORT-HAS-MID = 1
               MOVE 1 TO WS-EFF-HAS-MID
               PERFORM VARYING WS-I FROM 1 BY 1
                   UNTIL WS-I > 12
                   MOVE WS-ACT-SHORT-MID(WS-I)
                       TO WS-EFF-MONTH-IN-DATE(WS-I)
               END-PERFORM
           END-IF
           IF WS-ACT-SHORT-HAS-WKDAYS = 1
               PERFORM VARYING WS-I FROM 1 BY 1
                   UNTIL WS-I > 7
                   MOVE WS-ACT-SHORT-WKDAY(WS-I)
                       TO WS-EFF-WEEKDAY(WS-I)
               END-PERFORM
           END-IF
           IF WS-ACT-SHORT-HAS-DAY-FMT = 1
               MOVE WS-ACT-SHORT-DAY-FMT
                   TO WS-EFF-DAY-FORMAT
               IF WS-ACT-SHORT-HAS-DAY-EXC = 0
                   MOVE 0 TO WS-EFF-DAY-FMT-EXC-COUNT
               END-IF
           END-IF
           IF WS-ACT-SHORT-HAS-DAY-EXC = 1
               MOVE WS-ACT-SHORT-DAY-EXC-COUNT
                   TO WS-EFF-DAY-FMT-EXC-COUNT
               PERFORM VARYING WS-I FROM 1 BY 1
                   UNTIL WS-I > WS-ACT-SHORT-DAY-EXC-COUNT
                   MOVE WS-ACT-SHORT-DAY-EXC-KEY(WS-I)
                       TO WS-EFF-DAY-FMT-EXC-KEY(WS-I)
                   MOVE WS-ACT-SHORT-DAY-EXC-VAL(WS-I)
                       TO WS-EFF-DAY-FMT-EXC-VAL(WS-I)
               END-PERFORM
           END-IF
           IF WS-ACT-SHORT-HAS-DATE-PAT = 1
               MOVE WS-ACT-SHORT-DATE-PAT
                   TO WS-EFF-DATE-PATTERN
           END-IF
           IF WS-ACT-SHORT-HAS-DATE-PAT-YR = 1
               MOVE WS-ACT-SHORT-DATE-PAT-YR
                   TO WS-EFF-DATE-PAT-WITH-YEAR
           END-IF
           IF WS-ACT-SHORT-HAS-TODAY = 1
               MOVE WS-ACT-SHORT-TODAY TO WS-EFF-TODAY
           END-IF
           IF WS-ACT-SHORT-HAS-TOMORROW = 1
               MOVE WS-ACT-SHORT-TOMORROW TO WS-EFF-TOMORROW
           END-IF
           IF WS-ACT-SHORT-HAS-YESTERDAY = 1
               MOVE WS-ACT-SHORT-YESTERDAY TO WS-EFF-YESTERDAY
           END-IF
           .

       APPLY-COMPACT-OVERRIDE.
           IF WS-ACT-COMPACT-HAS-MONTHS = 1
               PERFORM VARYING WS-I FROM 1 BY 1
                   UNTIL WS-I > 12
                   MOVE WS-ACT-COMPACT-MONTH(WS-I)
                       TO WS-EFF-MONTH(WS-I)
               END-PERFORM
           END-IF
           IF WS-ACT-COMPACT-HAS-MID = 1
               MOVE 1 TO WS-EFF-HAS-MID
               PERFORM VARYING WS-I FROM 1 BY 1
                   UNTIL WS-I > 12
                   MOVE WS-ACT-COMPACT-MID(WS-I)
                       TO WS-EFF-MONTH-IN-DATE(WS-I)
               END-PERFORM
           END-IF
           IF WS-ACT-COMPACT-HAS-WKDAYS = 1
               PERFORM VARYING WS-I FROM 1 BY 1
                   UNTIL WS-I > 7
                   MOVE WS-ACT-COMPACT-WKDAY(WS-I)
                       TO WS-EFF-WEEKDAY(WS-I)
               END-PERFORM
           END-IF
           IF WS-ACT-COMPACT-HAS-DAY-FMT = 1
               MOVE WS-ACT-COMPACT-DAY-FMT
                   TO WS-EFF-DAY-FORMAT
               IF WS-ACT-COMPACT-HAS-DAY-EXC = 0
                   MOVE 0 TO WS-EFF-DAY-FMT-EXC-COUNT
               END-IF
           END-IF
           IF WS-ACT-COMPACT-HAS-DAY-EXC = 1
               MOVE WS-ACT-COMPACT-DAY-EXC-COUNT
                   TO WS-EFF-DAY-FMT-EXC-COUNT
               PERFORM VARYING WS-I FROM 1 BY 1
                   UNTIL WS-I > WS-ACT-COMPACT-DAY-EXC-COUNT
                   MOVE WS-ACT-COMPACT-DAY-EXC-KEY(WS-I)
                       TO WS-EFF-DAY-FMT-EXC-KEY(WS-I)
                   MOVE WS-ACT-COMPACT-DAY-EXC-VAL(WS-I)
                       TO WS-EFF-DAY-FMT-EXC-VAL(WS-I)
               END-PERFORM
           END-IF
           IF WS-ACT-COMPACT-HAS-DATE-PAT = 1
               MOVE WS-ACT-COMPACT-DATE-PAT
                   TO WS-EFF-DATE-PATTERN
           END-IF
           IF WS-ACT-COMPACT-HAS-DATE-PAT-YR = 1
               MOVE WS-ACT-COMPACT-DATE-PAT-YR
                   TO WS-EFF-DATE-PAT-WITH-YEAR
           END-IF
           IF WS-ACT-COMPACT-HAS-TODAY = 1
               MOVE WS-ACT-COMPACT-TODAY TO WS-EFF-TODAY
           END-IF
           IF WS-ACT-COMPACT-HAS-TOMORROW = 1
               MOVE WS-ACT-COMPACT-TOMORROW
                   TO WS-EFF-TOMORROW
           END-IF
           IF WS-ACT-COMPACT-HAS-YESTERDAY = 1
               MOVE WS-ACT-COMPACT-YESTERDAY
                   TO WS-EFF-YESTERDAY
           END-IF
           .

*> ============================================================
*> REPLACE-FIRST: Replace first occurrence of marker in src
*> Input:  WS-REPLACE-SRC, WS-REPLACE-MARKER, WS-REPLACE-REPL
*> Output: WS-REPLACE-RESULT, WS-REPLACE-POS (0 if not found)
*> ============================================================
       REPLACE-FIRST.
           MOVE SPACES TO WS-REPLACE-RESULT
           MOVE 0 TO WS-REPLACE-POS

           MOVE FUNCTION LENGTH(
               FUNCTION TRIM(WS-REPLACE-SRC))
               TO WS-REPLACE-SRC-LEN
           MOVE FUNCTION LENGTH(
               FUNCTION TRIM(WS-REPLACE-MARKER))
               TO WS-REPLACE-MRK-LEN

           IF WS-REPLACE-SRC-LEN = 0
               EXIT PARAGRAPH
           END-IF

           INSPECT WS-REPLACE-SRC(1:WS-REPLACE-SRC-LEN)
               TALLYING WS-REPLACE-POS
               FOR CHARACTERS BEFORE INITIAL
               FUNCTION TRIM(WS-REPLACE-MARKER)

           IF WS-REPLACE-POS >= WS-REPLACE-SRC-LEN
               MOVE 0 TO WS-REPLACE-POS
               MOVE WS-REPLACE-SRC TO WS-REPLACE-RESULT
               EXIT PARAGRAPH
           END-IF

           IF WS-REPLACE-POS > 0
               STRING
                   WS-REPLACE-SRC(1:WS-REPLACE-POS)
                   FUNCTION TRIM(WS-REPLACE-REPL)
                   WS-REPLACE-SRC(
                       WS-REPLACE-POS + WS-REPLACE-MRK-LEN
                       + 1 : WS-REPLACE-SRC-LEN
                       - WS-REPLACE-POS - WS-REPLACE-MRK-LEN)
                   DELIMITED BY SIZE
                   INTO WS-REPLACE-RESULT
               END-STRING
           ELSE
               STRING
                   FUNCTION TRIM(WS-REPLACE-REPL)
                   WS-REPLACE-SRC(
                       WS-REPLACE-MRK-LEN + 1 :
                       WS-REPLACE-SRC-LEN - WS-REPLACE-MRK-LEN)
                   DELIMITED BY SIZE
                   INTO WS-REPLACE-RESULT
               END-STRING
           END-IF

           ADD 1 TO WS-REPLACE-POS
           .

*> ============================================================
*> PARSE-DATE-INPUT: Parse YYYY-MM-DD naming a real calendar day,
*> optionally followed by T and a time (only the date part is read)
*> Input:  WS-DATE-STR, WS-DATE-LEN (0 = length without trailing blanks)
*> Output: WS-PARSED-YEAR, WS-PARSED-MONTH, WS-PARSED-DAY,
*>         WS-PARSE-OK (1=success, 0=failure)
*> ============================================================
       PARSE-DATE-INPUT.
           MOVE 0 TO WS-PARSE-OK
           IF WS-DATE-LEN = 0
               MOVE FUNCTION STORED-CHAR-LENGTH(WS-DATE-STR)
                   TO WS-DATE-LEN
           END-IF
           IF WS-DATE-LEN < 10
               EXIT PARAGRAPH
           END-IF
           IF WS-DATE-LEN > 10 AND WS-DATE-STR(11:1) NOT = "T"
               EXIT PARAGRAPH
           END-IF
           IF WS-DATE-STR(5:1) NOT = "-"
               OR WS-DATE-STR(8:1) NOT = "-"
               OR WS-DATE-STR(1:4) IS NOT NUMERIC
               OR WS-DATE-STR(6:2) IS NOT NUMERIC
               OR WS-DATE-STR(9:2) IS NOT NUMERIC
               EXIT PARAGRAPH
           END-IF
           MOVE WS-DATE-STR(1:4) TO WS-PARSED-YEAR
           MOVE WS-DATE-STR(6:2) TO WS-PARSED-MONTH
           MOVE WS-DATE-STR(9:2) TO WS-PARSED-DAY
           IF WS-PARSED-MONTH < 1 OR WS-PARSED-MONTH > 12
               EXIT PARAGRAPH
           END-IF
           EVALUATE WS-PARSED-MONTH
               WHEN 4 WHEN 6 WHEN 9 WHEN 11
                   MOVE 30 TO WS-PARSED-MONTH-DAYS
               WHEN 2
                   IF (FUNCTION MOD(WS-PARSED-YEAR, 4) = 0
                       AND FUNCTION MOD(WS-PARSED-YEAR, 100) NOT = 0)
                       OR FUNCTION MOD(WS-PARSED-YEAR, 400) = 0
                       MOVE 29 TO WS-PARSED-MONTH-DAYS
                   ELSE
                       MOVE 28 TO WS-PARSED-MONTH-DAYS
                   END-IF
               WHEN OTHER
                   MOVE 31 TO WS-PARSED-MONTH-DAYS
           END-EVALUATE
           IF WS-PARSED-DAY < 1
               OR WS-PARSED-DAY > WS-PARSED-MONTH-DAYS
               EXIT PARAGRAPH
           END-IF
           MOVE 1 TO WS-PARSE-OK
           .

*> ============================================================
*> CALC-JULIAN-DAY: Calculate Julian Day Number
*> Input:  WS-JD-CALC-YEAR, WS-JD-CALC-MONTH, WS-JD-CALC-DAY
*> Output: WS-JD-CALC-RESULT
*> ============================================================
       CALC-JULIAN-DAY.
           COMPUTE WS-JD-A =
               (14 - WS-JD-CALC-MONTH) / 12
           COMPUTE WS-JD-Y =
               WS-JD-CALC-YEAR + 4800 - WS-JD-A
           COMPUTE WS-JD-M =
               WS-JD-CALC-MONTH + 12 * WS-JD-A - 3
           COMPUTE WS-JD-T1 = WS-JD-CALC-DAY
           COMPUTE WS-JD-T2 = (153 * WS-JD-M + 2) / 5
           COMPUTE WS-JD-T3 = 365 * WS-JD-Y
           COMPUTE WS-JD-T4 = WS-JD-Y / 4
           COMPUTE WS-JD-T5 = WS-JD-Y / 100
           COMPUTE WS-JD-T6 = WS-JD-Y / 400
           COMPUTE WS-JD-CALC-RESULT =
               WS-JD-T1 + WS-JD-T2 + WS-JD-T3
               + WS-JD-T4 - WS-JD-T5 + WS-JD-T6 - 32045
           .

*> ============================================================
*> NUM-TO-STR: Convert integer to trimmed string
*> Input:  WS-NUM-TO-STR-INPUT
*> Output: WS-NUM-TO-STR-RESULT
*> ============================================================
       NUM-TO-STR.
           MOVE WS-NUM-TO-STR-INPUT TO WS-NUM-TO-STR-EDITED
           MOVE FUNCTION TRIM(WS-NUM-TO-STR-EDITED)
               TO WS-NUM-TO-STR-RESULT
           .
