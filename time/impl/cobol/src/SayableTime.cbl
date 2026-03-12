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
           ADD 1 TO WS-HOUR
           IF WS-HOUR > 23
               MOVE 0 TO WS-HOUR
           END-IF
           DIVIDE WS-HOUR BY 12
               GIVING WS-TEMP-CALC REMAINDER WS-NEXT-H12
           SUBTRACT 1 FROM WS-HOUR
           IF WS-HOUR < 0
               ADD 24 TO WS-HOUR
           END-IF

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
           MOVE WS-PARSED-MINUTE TO WS-MM-EDITED
           MOVE FUNCTION TRIM(WS-MM-EDITED) TO WS-MM-STR
           IF WS-PARSED-MINUTE < 10
               STRING "0" FUNCTION TRIM(WS-MM-STR)
                   DELIMITED BY SIZE INTO WS-MM-STR
               END-STRING
           END-IF
           MOVE WS-PATTERN TO WS-REPLACE-SRC
           MOVE "{mm}" TO WS-REPLACE-MARKER
           MOVE FUNCTION TRIM(WS-MM-STR) TO WS-REPLACE-REPL
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
           MOVE WS-PARSED-MINUTE TO WS-MM-EDITED
           MOVE FUNCTION TRIM(WS-MM-EDITED) TO WS-MM-STR
           IF WS-PARSED-MINUTE < 10
               STRING "0" FUNCTION TRIM(WS-MM-STR)
                   DELIMITED BY SIZE INTO WS-MM-STR
               END-STRING
           END-IF
           MOVE WS-PATTERN TO WS-REPLACE-SRC
           MOVE "{mm}" TO WS-REPLACE-MARKER
           MOVE FUNCTION TRIM(WS-MM-STR) TO WS-REPLACE-REPL
           PERFORM REPLACE-FIRST
           MOVE WS-REPLACE-RESULT TO WS-FORMAT-RESULT
           .

*> ============================================================
*> PARSE-TIME-INPUT: Parse HH:MM from WS-TIME-STR
*> Handles ISO datetime (strips date part)
*> Output: WS-PARSED-HOUR, WS-PARSED-MINUTE,
*>         WS-PARSE-OK (1=success, 0=failure)
*> ============================================================
       PARSE-TIME-INPUT.
           MOVE 0 TO WS-PARSE-OK

           *> Strip date part from ISO datetime (after T)
           MOVE 0 TO WS-COLON-POS
           INSPECT WS-TIME-STR
               TALLYING WS-COLON-POS
               FOR CHARACTERS BEFORE INITIAL "T"
           IF WS-COLON-POS <
               FUNCTION LENGTH(FUNCTION TRIM(WS-TIME-STR))
               ADD 1 TO WS-COLON-POS
               MOVE WS-TIME-STR(WS-COLON-POS + 1:)
                   TO WS-TIME-STR
           END-IF

           *> Need at least HH:MM (5 chars)
           IF FUNCTION LENGTH(FUNCTION TRIM(WS-TIME-STR))
               < 5
               EXIT PARAGRAPH
           END-IF

           *> Find colon position
           MOVE 0 TO WS-COLON-POS
           INSPECT WS-TIME-STR(1:FUNCTION LENGTH(
               FUNCTION TRIM(WS-TIME-STR)))
               TALLYING WS-COLON-POS
               FOR CHARACTERS BEFORE INITIAL ":"
           IF WS-COLON-POS >=
               FUNCTION LENGTH(FUNCTION TRIM(WS-TIME-STR))
               EXIT PARAGRAPH
           END-IF

           *> Extract hour and minute
           MOVE WS-TIME-STR(1:WS-COLON-POS) TO WS-PARSED-HOUR
           MOVE WS-TIME-STR(WS-COLON-POS + 2:2)
               TO WS-PARSED-MINUTE

           *> Validate
           IF WS-PARSED-HOUR > 23
               EXIT PARAGRAPH
           END-IF
           IF WS-PARSED-MINUTE > 59
               EXIT PARAGRAPH
           END-IF
           MOVE 1 TO WS-PARSE-OK
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
