*> SayableTime.cbl - PROCEDURE DIVISION copybook for sayable-time
*> Contains the core formatting paragraphs.
*> Included via COPY in the main test program.
*> Requires: Types.cbl (WORKING-STORAGE) and Locales.cbl (locale data)

*> ============================================================
*> FORMAT-TIME: Format a time as natural language clock reading
*> Input:  WS-FMT-TIME, WS-FMT-COMPACTNESS
*>         WS-ACT-* must be loaded via GET-LOCALE
*> Output: WS-FORMAT-RESULT
*> ============================================================
       FORMAT-TIME.
           MOVE SPACES TO WS-FORMAT-RESULT

           IF FUNCTION TRIM(WS-FMT-TIME) = SPACES
               EXIT PARAGRAPH
           END-IF
           MOVE WS-FMT-TIME TO WS-TIME-STR
           MOVE WS-FMT-TIME-LEN TO WS-TIME-LEN
           PERFORM PARSE-TIME-INPUT
           IF WS-PARSE-OK = 0
               EXIT PARAGRAPH
           END-IF

           IF WS-FMT-COMPACTNESS NOT = PT-NORMAL
               IF WS-FMT-COMPACTNESS = PT-SHORT
                   AND WS-ACT-HAS-SHORT = 1
                   PERFORM FORMAT-DIGITAL-SHORT
                   EXIT PARAGRAPH
               END-IF
               IF WS-FMT-COMPACTNESS = PT-COMPACT
                   AND WS-ACT-HAS-COMPACT = 1
                   PERFORM FORMAT-DIGITAL-COMPACT
                   EXIT PARAGRAPH
               END-IF
           END-IF

           PERFORM FORMAT-NATURAL
           .

*> ============================================================
*> FORMAT-NATURAL: Format time as spoken clock reading
*> ============================================================
       FORMAT-NATURAL.
           MOVE WS-PARSED-HOUR TO WS-HOUR
           MOVE WS-PARSED-MINUTE TO WS-TEMP-CALC

           *> Round to nearest 5
           ADD 2 TO WS-TEMP-CALC
           DIVIDE WS-TEMP-CALC BY 5
               GIVING WS-TEMP-CALC REMAINDER WS-TEMP-REM
           MULTIPLY 5 BY WS-TEMP-CALC
           MOVE WS-TEMP-CALC TO WS-ROUNDED-MIN

           *> Handle rounding to 60
           IF WS-ROUNDED-MIN = 60
               MOVE 0 TO WS-ROUNDED-MIN
               ADD 1 TO WS-HOUR
               IF WS-HOUR > 23
                   MOVE 0 TO WS-HOUR
               END-IF
           END-IF

           *> Special cases at :00
           IF WS-ROUNDED-MIN = 0
               IF WS-HOUR = 0
                   MOVE WS-ACT-MIDNIGHT TO WS-FORMAT-RESULT
                   EXIT PARAGRAPH
               END-IF
               IF WS-HOUR = 12
                   MOVE WS-ACT-NOON TO WS-FORMAT-RESULT
                   EXIT PARAGRAPH
               END-IF
           END-IF

           *> Calculate h12 and next_h12
           DIVIDE WS-HOUR BY 12
               GIVING WS-TEMP-CALC REMAINDER WS-H12
           COMPUTE WS-NEXT-H12 = FUNCTION MOD(WS-HOUR + 1, 12)

           *> Get hour names (1-based array)
           ADD 1 TO WS-H12
           MOVE WS-ACT-HOUR(WS-H12) TO WS-H-NAME
           SUBTRACT 1 FROM WS-H12
           ADD 1 TO WS-NEXT-H12
           MOVE WS-ACT-HOUR(WS-NEXT-H12) TO WS-NEXT-H-NAME
           SUBTRACT 1 FROM WS-NEXT-H12

           *> Get pattern for rounded minute
           DIVIDE WS-ROUNDED-MIN BY 5
               GIVING WS-PAT-IDX REMAINDER WS-TEMP-REM
           ADD 1 TO WS-PAT-IDX
           MOVE WS-ACT-PATTERN(WS-PAT-IDX) TO WS-PATTERN

           *> Replace {h} with hour name
           MOVE WS-PATTERN TO WS-REPLACE-SRC
           MOVE "{h}" TO WS-REPLACE-MARKER
           MOVE FUNCTION TRIM(WS-H-NAME) TO WS-REPLACE-REPL
           PERFORM REPLACE-FIRST
           MOVE WS-REPLACE-RESULT TO WS-PATTERN

           *> Replace {next_h} with next hour name
           MOVE WS-PATTERN TO WS-REPLACE-SRC
           MOVE "{next_h}" TO WS-REPLACE-MARKER
           MOVE FUNCTION TRIM(WS-NEXT-H-NAME) TO WS-REPLACE-REPL
           PERFORM REPLACE-FIRST
           MOVE WS-REPLACE-RESULT TO WS-FORMAT-RESULT
           .

*> ============================================================
*> FORMAT-DIGITAL-SHORT: Format as digital clock (short)
*> ============================================================
       FORMAT-DIGITAL-SHORT.
           MOVE WS-ACT-SHORT-FORMAT TO WS-PATTERN

           IF WS-ACT-SHORT-USE24H = 1
               MOVE WS-PARSED-HOUR TO WS-NUM-TO-STR-INPUT
               PERFORM NUM-TO-STR
               MOVE WS-PATTERN TO WS-REPLACE-SRC
               MOVE "{h}" TO WS-REPLACE-MARKER
               MOVE FUNCTION TRIM(WS-NUM-TO-STR-RESULT)
                   TO WS-REPLACE-REPL
               PERFORM REPLACE-FIRST
               MOVE WS-REPLACE-RESULT TO WS-PATTERN
           ELSE
               DIVIDE WS-PARSED-HOUR BY 12
                   GIVING WS-TEMP-CALC REMAINDER WS-H12
               IF WS-H12 = 0
                   MOVE 12 TO WS-H12
               END-IF
               MOVE WS-H12 TO WS-NUM-TO-STR-INPUT
               PERFORM NUM-TO-STR
               MOVE WS-PATTERN TO WS-REPLACE-SRC
               MOVE "{h}" TO WS-REPLACE-MARKER
               MOVE FUNCTION TRIM(WS-NUM-TO-STR-RESULT)
                   TO WS-REPLACE-REPL
               PERFORM REPLACE-FIRST
               MOVE WS-REPLACE-RESULT TO WS-PATTERN

               IF WS-PARSED-HOUR < 12
                   MOVE WS-ACT-SHORT-AM TO WS-AMPM-STR
               ELSE
                   MOVE WS-ACT-SHORT-PM TO WS-AMPM-STR
               END-IF
               MOVE WS-PATTERN TO WS-REPLACE-SRC
               MOVE "{ampm}" TO WS-REPLACE-MARKER
               MOVE FUNCTION TRIM(WS-AMPM-STR)
                   TO WS-REPLACE-REPL
               PERFORM REPLACE-FIRST
               MOVE WS-REPLACE-RESULT TO WS-PATTERN
           END-IF

           *> Replace {mm} with zero-padded minutes
           MOVE WS-PARSED-MINUTE TO WS-MM-DIGITS
           MOVE WS-PATTERN TO WS-REPLACE-SRC
           MOVE "{mm}" TO WS-REPLACE-MARKER
           MOVE WS-MM-DIGITS TO WS-REPLACE-REPL
           PERFORM REPLACE-FIRST
           MOVE WS-REPLACE-RESULT TO WS-FORMAT-RESULT
           .

*> ============================================================
*> FORMAT-DIGITAL-COMPACT: Format as digital clock (compact)
*> ============================================================
       FORMAT-DIGITAL-COMPACT.
           MOVE WS-ACT-COMPACT-FORMAT TO WS-PATTERN

           IF WS-ACT-COMPACT-USE24H = 1
               MOVE WS-PARSED-HOUR TO WS-NUM-TO-STR-INPUT
               PERFORM NUM-TO-STR
               MOVE WS-PATTERN TO WS-REPLACE-SRC
               MOVE "{h}" TO WS-REPLACE-MARKER
               MOVE FUNCTION TRIM(WS-NUM-TO-STR-RESULT)
                   TO WS-REPLACE-REPL
               PERFORM REPLACE-FIRST
               MOVE WS-REPLACE-RESULT TO WS-PATTERN
           ELSE
               DIVIDE WS-PARSED-HOUR BY 12
                   GIVING WS-TEMP-CALC REMAINDER WS-H12
               IF WS-H12 = 0
                   MOVE 12 TO WS-H12
               END-IF
               MOVE WS-H12 TO WS-NUM-TO-STR-INPUT
               PERFORM NUM-TO-STR
               MOVE WS-PATTERN TO WS-REPLACE-SRC
               MOVE "{h}" TO WS-REPLACE-MARKER
               MOVE FUNCTION TRIM(WS-NUM-TO-STR-RESULT)
                   TO WS-REPLACE-REPL
               PERFORM REPLACE-FIRST
               MOVE WS-REPLACE-RESULT TO WS-PATTERN

               IF WS-PARSED-HOUR < 12
                   MOVE WS-ACT-COMPACT-AM TO WS-AMPM-STR
               ELSE
                   MOVE WS-ACT-COMPACT-PM TO WS-AMPM-STR
               END-IF
               MOVE WS-PATTERN TO WS-REPLACE-SRC
               MOVE "{ampm}" TO WS-REPLACE-MARKER
               MOVE FUNCTION TRIM(WS-AMPM-STR)
                   TO WS-REPLACE-REPL
               PERFORM REPLACE-FIRST
               MOVE WS-REPLACE-RESULT TO WS-PATTERN
           END-IF

           *> Replace {mm} with zero-padded minutes
           MOVE WS-PARSED-MINUTE TO WS-MM-DIGITS
           MOVE WS-PATTERN TO WS-REPLACE-SRC
           MOVE "{mm}" TO WS-REPLACE-MARKER
           MOVE WS-MM-DIGITS TO WS-REPLACE-REPL
           PERFORM REPLACE-FIRST
           MOVE WS-REPLACE-RESULT TO WS-FORMAT-RESULT
           .

*> ============================================================
*> PARSE-TIME-INPUT: Parse a clock time, alone or after the T of an
*> ISO datetime whose date part is a real calendar day
*> Input:  WS-TIME-STR, WS-TIME-LEN (0 = length without trailing blanks)
*> Output: WS-PARSED-HOUR, WS-PARSED-MINUTE,
*>         WS-PARSE-OK (1=success, 0=failure)
*> ============================================================
       PARSE-TIME-INPUT.
           MOVE 0 TO WS-PARSE-OK
           IF WS-TIME-LEN = 0
               MOVE FUNCTION STORED-CHAR-LENGTH(WS-TIME-STR)
                   TO WS-TIME-LEN
           END-IF
           IF WS-TIME-LEN = 0 OR WS-TIME-LEN > 256
               EXIT PARAGRAPH
           END-IF
           MOVE 0 TO WS-T-POS
           INSPECT WS-TIME-STR(1:WS-TIME-LEN)
               TALLYING WS-T-POS
               FOR CHARACTERS BEFORE INITIAL "T"
           IF WS-T-POS < WS-TIME-LEN
               IF WS-T-POS NOT = 10
                   EXIT PARAGRAPH
               END-IF
               PERFORM CHECK-REAL-DATE
               IF WS-PARSE-OK = 0
                   EXIT PARAGRAPH
               END-IF
               MOVE 0 TO WS-PARSE-OK
               COMPUTE WS-CLOCK-START = WS-T-POS + 2
           ELSE
               MOVE 1 TO WS-CLOCK-START
           END-IF
           PERFORM PARSE-CLOCK
           .

*> ============================================================
*> CHECK-REAL-DATE: WS-TIME-STR(1:10) is YYYY-MM-DD naming a real
*> calendar day
*> Output: WS-PARSE-OK (1=real date, 0=not)
*> ============================================================
       CHECK-REAL-DATE.
           MOVE 0 TO WS-PARSE-OK
           IF WS-TIME-STR(5:1) NOT = "-"
               OR WS-TIME-STR(8:1) NOT = "-"
               OR WS-TIME-STR(1:4) IS NOT NUMERIC
               OR WS-TIME-STR(6:2) IS NOT NUMERIC
               OR WS-TIME-STR(9:2) IS NOT NUMERIC
               EXIT PARAGRAPH
           END-IF
           MOVE WS-TIME-STR(1:4) TO WS-DATE-YEAR
           MOVE WS-TIME-STR(6:2) TO WS-DATE-MONTH
           MOVE WS-TIME-STR(9:2) TO WS-DATE-DAY
           IF WS-DATE-MONTH < 1 OR WS-DATE-MONTH > 12
               EXIT PARAGRAPH
           END-IF
           EVALUATE WS-DATE-MONTH
               WHEN 4 WHEN 6 WHEN 9 WHEN 11
                   MOVE 30 TO WS-MONTH-DAY-COUNT
               WHEN 2
                   IF (FUNCTION MOD(WS-DATE-YEAR, 4) = 0
                       AND FUNCTION MOD(WS-DATE-YEAR, 100) NOT = 0)
                       OR FUNCTION MOD(WS-DATE-YEAR, 400) = 0
                       MOVE 29 TO WS-MONTH-DAY-COUNT
                   ELSE
                       MOVE 28 TO WS-MONTH-DAY-COUNT
                   END-IF
               WHEN OTHER
                   MOVE 31 TO WS-MONTH-DAY-COUNT
           END-EVALUATE
           IF WS-DATE-DAY >= 1 AND WS-DATE-DAY <= WS-MONTH-DAY-COUNT
               MOVE 1 TO WS-PARSE-OK
           END-IF
           .

*> ============================================================
*> PARSE-CLOCK: H:MM or HH:MM from WS-CLOCK-START to WS-TIME-LEN,
*> then optional :SS with optional .fraction, then an optional zone
*> suffix (Z or +HH:MM / -HH:MM, validated but never applied)
*> Output: WS-PARSED-HOUR, WS-PARSED-MINUTE, WS-PARSE-OK
*> ============================================================
       PARSE-CLOCK.
           MOVE 0 TO WS-PARSE-OK
           MOVE WS-CLOCK-START TO WS-SCAN-POS
           MOVE 0 TO WS-HOUR-DIGITS
           PERFORM UNTIL WS-HOUR-DIGITS = 2
                   OR WS-SCAN-POS > WS-TIME-LEN
                   OR WS-TIME-STR(WS-SCAN-POS:1) IS NOT NUMERIC
               ADD 1 TO WS-HOUR-DIGITS
               ADD 1 TO WS-SCAN-POS
           END-PERFORM
           IF WS-HOUR-DIGITS = 0 OR WS-SCAN-POS + 2 > WS-TIME-LEN
               EXIT PARAGRAPH
           END-IF
           IF WS-TIME-STR(WS-SCAN-POS:1) NOT = ":"
               OR WS-TIME-STR(WS-SCAN-POS + 1:2) IS NOT NUMERIC
               EXIT PARAGRAPH
           END-IF
           COMPUTE WS-PARSED-HOUR = FUNCTION NUMVAL(
               WS-TIME-STR(WS-CLOCK-START:WS-HOUR-DIGITS))
           MOVE WS-TIME-STR(WS-SCAN-POS + 1:2) TO WS-PARSED-MINUTE
           ADD 3 TO WS-SCAN-POS
           MOVE 0 TO WS-PARSED-SECOND
           IF WS-SCAN-POS + 2 <= WS-TIME-LEN
               AND WS-TIME-STR(WS-SCAN-POS:1) = ":"
               AND WS-TIME-STR(WS-SCAN-POS + 1:2) IS NUMERIC
               MOVE WS-TIME-STR(WS-SCAN-POS + 1:2) TO WS-PARSED-SECOND
               ADD 3 TO WS-SCAN-POS
               IF WS-SCAN-POS + 1 <= WS-TIME-LEN
                   AND WS-TIME-STR(WS-SCAN-POS:1) = "."
                   AND WS-TIME-STR(WS-SCAN-POS + 1:1) IS NUMERIC
                   ADD 1 TO WS-SCAN-POS
                   PERFORM UNTIL WS-SCAN-POS > WS-TIME-LEN
                           OR WS-TIME-STR(WS-SCAN-POS:1) IS NOT NUMERIC
                       ADD 1 TO WS-SCAN-POS
                   END-PERFORM
               END-IF
           END-IF
           COMPUTE WS-ZONE-LEN = WS-TIME-LEN - WS-SCAN-POS + 1
           EVALUATE TRUE
               WHEN WS-ZONE-LEN = 0
                   CONTINUE
               WHEN WS-ZONE-LEN = 1 AND WS-TIME-STR(WS-SCAN-POS:1) = "Z"
                   CONTINUE
               WHEN WS-ZONE-LEN = 6
                   AND (WS-TIME-STR(WS-SCAN-POS:1) = "+"
                       OR WS-TIME-STR(WS-SCAN-POS:1) = "-")
                   AND WS-TIME-STR(WS-SCAN-POS + 1:2) IS NUMERIC
                   AND WS-TIME-STR(WS-SCAN-POS + 3:1) = ":"
                   AND WS-TIME-STR(WS-SCAN-POS + 4:2) IS NUMERIC
                   CONTINUE
               WHEN OTHER
                   EXIT PARAGRAPH
           END-EVALUATE
           IF WS-PARSED-HOUR <= 23 AND WS-PARSED-MINUTE <= 59
               AND WS-PARSED-SECOND <= 59
               MOVE 1 TO WS-PARSE-OK
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
*> NUM-TO-STR: Convert integer to trimmed string
*> Input:  WS-NUM-TO-STR-INPUT
*> Output: WS-NUM-TO-STR-RESULT
*> ============================================================
       NUM-TO-STR.
           MOVE WS-NUM-TO-STR-INPUT TO WS-NUM-TO-STR-EDITED
           MOVE FUNCTION TRIM(WS-NUM-TO-STR-EDITED)
               TO WS-NUM-TO-STR-RESULT
           .
