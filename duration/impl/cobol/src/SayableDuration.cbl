*> SayableDuration.cbl - PROCEDURE DIVISION copybook for sayable-duration
*> Contains the core formatting paragraphs.
*> Included via COPY in the main test program.
*> Requires: Types.cbl (WORKING-STORAGE) and Locales.cbl (locale data)

*> ============================================================
*> FORMAT-DURATION: Format a duration in seconds
*> Input:  WS-FMT-SECONDS, WS-FMT-COMPACTNESS
*>         WS-ACT-* must be loaded via GET-LOCALE
*> Output: WS-FORMAT-RESULT
*> ============================================================
       FORMAT-DURATION.
           MOVE SPACES TO WS-FORMAT-RESULT
           MOVE WS-FMT-SECONDS TO WS-TOTAL-SECONDS

           IF WS-TOTAL-SECONDS < 0
               EXIT PARAGRAPH
           END-IF

           PERFORM COPY-LOCALE-TO-EFFECTIVE
           PERFORM APPLY-COMPACTNESS-OVERRIDE

           PERFORM FORMAT-DURATION-SECONDS
           .

*> ============================================================
*> FORMAT-DURATION-ISO: Format duration from ISO timestamps
*> Input:  WS-FMT-START, WS-FMT-END, WS-FMT-COMPACTNESS
*> Output: WS-FORMAT-RESULT
*> ============================================================
       FORMAT-DURATION-ISO.
           MOVE SPACES TO WS-FORMAT-RESULT

           IF FUNCTION TRIM(WS-FMT-START) = SPACES
               EXIT PARAGRAPH
           END-IF
           IF FUNCTION TRIM(WS-FMT-END) = SPACES
               EXIT PARAGRAPH
           END-IF

           MOVE WS-FMT-START TO WS-ISO-STR
           MOVE WS-FMT-START-LEN TO WS-ISO-LEN
           PERFORM PARSE-ISO-DATETIME
           IF WS-ISO-PARSE-OK = 0
               EXIT PARAGRAPH
           END-IF
           MOVE WS-ISO-RESULT TO WS-ISO-EPOCH-1

           MOVE WS-FMT-END TO WS-ISO-STR
           MOVE WS-FMT-END-LEN TO WS-ISO-LEN
           PERFORM PARSE-ISO-DATETIME
           IF WS-ISO-PARSE-OK = 0
               EXIT PARAGRAPH
           END-IF
           MOVE WS-ISO-RESULT TO WS-ISO-EPOCH-2

           COMPUTE WS-TOTAL-SECONDS =
               WS-ISO-EPOCH-2 - WS-ISO-EPOCH-1
           IF WS-TOTAL-SECONDS < 0
               MULTIPLY -1 BY WS-TOTAL-SECONDS
           END-IF

           PERFORM COPY-LOCALE-TO-EFFECTIVE
           PERFORM APPLY-COMPACTNESS-OVERRIDE

           PERFORM FORMAT-DURATION-SECONDS
           .

*> ============================================================
*> FORMAT-SINCE: Format elapsed time as 'X ago'
*> Input:  WS-FMT-START (past), WS-FMT-AS-OF (now)
*> Output: WS-FORMAT-RESULT
*> ============================================================
       FORMAT-SINCE.
           MOVE SPACES TO WS-FORMAT-RESULT

           IF FUNCTION TRIM(WS-FMT-START) = SPACES
               EXIT PARAGRAPH
           END-IF
           IF FUNCTION TRIM(WS-FMT-AS-OF) = SPACES
               EXIT PARAGRAPH
           END-IF

           MOVE WS-FMT-START TO WS-ISO-STR
           MOVE WS-FMT-START-LEN TO WS-ISO-LEN
           PERFORM PARSE-ISO-DATETIME
           IF WS-ISO-PARSE-OK = 0
               EXIT PARAGRAPH
           END-IF
           MOVE WS-ISO-RESULT TO WS-ISO-EPOCH-1

           MOVE WS-FMT-AS-OF TO WS-ISO-STR
           MOVE WS-FMT-AS-OF-LEN TO WS-ISO-LEN
           PERFORM PARSE-ISO-DATETIME
           IF WS-ISO-PARSE-OK = 0
               EXIT PARAGRAPH
           END-IF
           MOVE WS-ISO-RESULT TO WS-ISO-EPOCH-2

           COMPUTE WS-TOTAL-SECONDS =
               WS-ISO-EPOCH-2 - WS-ISO-EPOCH-1
           IF WS-TOTAL-SECONDS < 0
               EXIT PARAGRAPH
           END-IF

           PERFORM COPY-LOCALE-TO-EFFECTIVE
           PERFORM APPLY-COMPACTNESS-OVERRIDE

           IF WS-TOTAL-SECONDS = 0
               MOVE WS-EFF-JUST-NOW TO WS-FORMAT-RESULT
               EXIT PARAGRAPH
           END-IF

           PERFORM FORMAT-DURATION-SECONDS
           IF WS-FORMAT-RESULT = SPACES
               EXIT PARAGRAPH
           END-IF

           *> Wrap in ago template
           MOVE WS-EFF-AGO TO WS-REPLACE-SRC
           MOVE "{0}" TO WS-REPLACE-MARKER
           MOVE FUNCTION TRIM(WS-FORMAT-RESULT)
               TO WS-REPLACE-REPL
           PERFORM REPLACE-FIRST
           MOVE WS-REPLACE-RESULT TO WS-FORMAT-RESULT
           .

*> ============================================================
*> FORMAT-UNTIL: Format time until a future event
*> Input:  WS-FMT-TARGET (future), WS-FMT-AS-OF (now)
*> Output: WS-FORMAT-RESULT
*> ============================================================
       FORMAT-UNTIL.
           MOVE SPACES TO WS-FORMAT-RESULT

           IF FUNCTION TRIM(WS-FMT-TARGET) = SPACES
               EXIT PARAGRAPH
           END-IF
           IF FUNCTION TRIM(WS-FMT-AS-OF) = SPACES
               EXIT PARAGRAPH
           END-IF

           MOVE WS-FMT-TARGET TO WS-ISO-STR
           MOVE WS-FMT-TARGET-LEN TO WS-ISO-LEN
           PERFORM PARSE-ISO-DATETIME
           IF WS-ISO-PARSE-OK = 0
               EXIT PARAGRAPH
           END-IF
           MOVE WS-ISO-RESULT TO WS-ISO-EPOCH-1

           MOVE WS-FMT-AS-OF TO WS-ISO-STR
           MOVE WS-FMT-AS-OF-LEN TO WS-ISO-LEN
           PERFORM PARSE-ISO-DATETIME
           IF WS-ISO-PARSE-OK = 0
               EXIT PARAGRAPH
           END-IF
           MOVE WS-ISO-RESULT TO WS-ISO-EPOCH-2

           COMPUTE WS-TOTAL-SECONDS =
               WS-ISO-EPOCH-1 - WS-ISO-EPOCH-2
           IF WS-TOTAL-SECONDS < 0
               EXIT PARAGRAPH
           END-IF

           PERFORM COPY-LOCALE-TO-EFFECTIVE
           PERFORM APPLY-COMPACTNESS-OVERRIDE

           IF WS-TOTAL-SECONDS = 0
               MOVE WS-EFF-JUST-NOW TO WS-FORMAT-RESULT
               EXIT PARAGRAPH
           END-IF

           PERFORM FORMAT-DURATION-SECONDS
           IF WS-FORMAT-RESULT = SPACES
               EXIT PARAGRAPH
           END-IF

           *> Wrap in inFuture template
           MOVE WS-EFF-IN-FUTURE TO WS-REPLACE-SRC
           MOVE "{0}" TO WS-REPLACE-MARKER
           MOVE FUNCTION TRIM(WS-FORMAT-RESULT)
               TO WS-REPLACE-REPL
           PERFORM REPLACE-FIRST
           MOVE WS-REPLACE-RESULT TO WS-FORMAT-RESULT
           .

*> ============================================================
*> FORMAT-DURATION-SECONDS: Apply duration tiers
*> Input:  WS-TOTAL-SECONDS, WS-EFF-* fields
*> Output: WS-FORMAT-RESULT
*> ============================================================
       FORMAT-DURATION-SECONDS.
           MOVE SPACES TO WS-FORMAT-RESULT

           *> Beyond the 500-year ceiling there is no value
           DIVIDE WS-TOTAL-SECONDS BY 86400 GIVING WS-TOTAL-DAYS
           PERFORM CALC-APPROXIMATE-MONTHS
           IF WS-TOTAL-MONTHS > PT-MAX-DURATION-MONTHS
               EXIT PARAGRAPH
           END-IF

           *> 0 seconds
           IF WS-TOTAL-SECONDS = 0
               MOVE WS-EFF-JUST-NOW TO WS-FORMAT-RESULT
               EXIT PARAGRAPH
           END-IF

           *> 1-59 seconds
           IF WS-TOTAL-SECONDS < 60
               MOVE WS-TOTAL-SECONDS TO WS-RU-COUNT
               MOVE SPACES TO WS-RU-HALF
               PERFORM LOAD-AUF-SECOND
               PERFORM RESOLVE-UNIT
               MOVE WS-RU-RESULT TO WS-FORMAT-RESULT
               EXIT PARAGRAPH
           END-IF

           DIVIDE WS-TOTAL-SECONDS BY 60
               GIVING WS-TOTAL-MINUTES
               REMAINDER WS-REM-SECONDS

           *> 1-4 minutes: minutes + seconds
           IF WS-TOTAL-MINUTES < 5
               MOVE WS-TOTAL-MINUTES TO WS-RU-COUNT
               MOVE SPACES TO WS-RU-HALF
               PERFORM LOAD-AUF-MINUTE
               PERFORM RESOLVE-UNIT
               MOVE WS-RU-RESULT TO WS-PART1

               IF WS-REM-SECONDS > 0
                   MOVE WS-REM-SECONDS TO WS-RU-COUNT
                   MOVE SPACES TO WS-RU-HALF
                   PERFORM LOAD-AUF-SECOND
                   PERFORM RESOLVE-UNIT
                   MOVE WS-RU-RESULT TO WS-PART2
                   MOVE SPACES TO WS-FORMAT-RESULT
                   STRING
                       FUNCTION TRIM(WS-PART1)
                       WS-EFF-DELIMITER(1:WS-EFF-DELIM-LEN)
                       FUNCTION TRIM(WS-PART2)
                       DELIMITED BY SIZE
                       INTO WS-FORMAT-RESULT
                   END-STRING
               ELSE
                   MOVE WS-PART1 TO WS-FORMAT-RESULT
               END-IF
               EXIT PARAGRAPH
           END-IF

           *> 5-59 minutes
           IF WS-TOTAL-MINUTES < 60
               MOVE WS-TOTAL-MINUTES TO WS-RU-COUNT
               MOVE SPACES TO WS-RU-HALF
               PERFORM LOAD-AUF-MINUTE
               PERFORM RESOLVE-UNIT
               MOVE WS-RU-RESULT TO WS-FORMAT-RESULT
               EXIT PARAGRAPH
           END-IF

           DIVIDE WS-TOTAL-SECONDS BY 3600
               GIVING WS-TOTAL-HOURS
           COMPUTE WS-REM-MINUTES =
               (WS-TOTAL-SECONDS - WS-TOTAL-HOURS * 3600) / 60

           *> 1-5 hours: hours + minutes (with half marker)
           IF WS-TOTAL-HOURS <= 5
               IF WS-REM-MINUTES = 30
                   MOVE WS-TOTAL-HOURS TO WS-RU-COUNT
                   MOVE WS-EFF-HALF TO WS-RU-HALF
                   PERFORM LOAD-AUF-HOUR
                   PERFORM RESOLVE-UNIT
                   MOVE WS-RU-RESULT TO WS-FORMAT-RESULT
                   EXIT PARAGRAPH
               END-IF
               MOVE WS-TOTAL-HOURS TO WS-RU-COUNT
               MOVE SPACES TO WS-RU-HALF
               PERFORM LOAD-AUF-HOUR
               PERFORM RESOLVE-UNIT
               MOVE WS-RU-RESULT TO WS-PART1
               IF WS-REM-MINUTES > 0
                   MOVE WS-REM-MINUTES TO WS-RU-COUNT
                   MOVE SPACES TO WS-RU-HALF
                   PERFORM LOAD-AUF-MINUTE
                   PERFORM RESOLVE-UNIT
                   MOVE WS-RU-RESULT TO WS-PART2
                   MOVE SPACES TO WS-FORMAT-RESULT
                   STRING
                       FUNCTION TRIM(WS-PART1)
                       WS-EFF-DELIMITER(1:WS-EFF-DELIM-LEN)
                       FUNCTION TRIM(WS-PART2)
                       DELIMITED BY SIZE
                       INTO WS-FORMAT-RESULT
                   END-STRING
               ELSE
                   MOVE WS-PART1 TO WS-FORMAT-RESULT
               END-IF
               EXIT PARAGRAPH
           END-IF

           *> 6-23 hours
           IF WS-TOTAL-HOURS < 24
               MOVE WS-TOTAL-HOURS TO WS-RU-COUNT
               MOVE SPACES TO WS-RU-HALF
               PERFORM LOAD-AUF-HOUR
               PERFORM RESOLVE-UNIT
               MOVE WS-RU-RESULT TO WS-FORMAT-RESULT
               EXIT PARAGRAPH
           END-IF

           DIVIDE WS-TOTAL-SECONDS BY 86400
               GIVING WS-TOTAL-DAYS
           COMPUTE WS-REM-HOURS =
               (WS-TOTAL-SECONDS - WS-TOTAL-DAYS * 86400)
               / 3600

           *> 1-2 days: days + hours (with half marker)
           IF WS-TOTAL-DAYS <= 2
               IF WS-REM-HOURS = 12
                   MOVE WS-TOTAL-DAYS TO WS-RU-COUNT
                   MOVE WS-EFF-HALF TO WS-RU-HALF
                   PERFORM LOAD-AUF-DAY
                   PERFORM RESOLVE-UNIT
                   MOVE WS-RU-RESULT TO WS-FORMAT-RESULT
                   EXIT PARAGRAPH
               END-IF
               MOVE WS-TOTAL-DAYS TO WS-RU-COUNT
               MOVE SPACES TO WS-RU-HALF
               PERFORM LOAD-AUF-DAY
               PERFORM RESOLVE-UNIT
               MOVE WS-RU-RESULT TO WS-PART1
               IF WS-REM-HOURS > 0
                   MOVE WS-REM-HOURS TO WS-RU-COUNT
                   MOVE SPACES TO WS-RU-HALF
                   PERFORM LOAD-AUF-HOUR
                   PERFORM RESOLVE-UNIT
                   MOVE WS-RU-RESULT TO WS-PART2
                   MOVE SPACES TO WS-FORMAT-RESULT
                   STRING
                       FUNCTION TRIM(WS-PART1)
                       WS-EFF-DELIMITER(1:WS-EFF-DELIM-LEN)
                       FUNCTION TRIM(WS-PART2)
                       DELIMITED BY SIZE
                       INTO WS-FORMAT-RESULT
                   END-STRING
               ELSE
                   MOVE WS-PART1 TO WS-FORMAT-RESULT
               END-IF
               EXIT PARAGRAPH
           END-IF

           *> 3-6 days
           IF WS-TOTAL-DAYS < 7
               MOVE WS-TOTAL-DAYS TO WS-RU-COUNT
               MOVE SPACES TO WS-RU-HALF
               PERFORM LOAD-AUF-DAY
               PERFORM RESOLVE-UNIT
               MOVE WS-RU-RESULT TO WS-FORMAT-RESULT
               EXIT PARAGRAPH
           END-IF

           DIVIDE WS-TOTAL-DAYS BY 7
               GIVING WS-TOTAL-WEEKS
               REMAINDER WS-REM-DAYS

           *> 1-4 weeks (under 30 days)
           IF WS-TOTAL-DAYS < 30
               MOVE WS-TOTAL-WEEKS TO WS-RU-COUNT
               MOVE SPACES TO WS-RU-HALF
               PERFORM LOAD-AUF-WEEK
               PERFORM RESOLVE-UNIT
               MOVE WS-RU-RESULT TO WS-PART1
               IF WS-REM-DAYS > 0
                   MOVE WS-REM-DAYS TO WS-RU-COUNT
                   MOVE SPACES TO WS-RU-HALF
                   PERFORM LOAD-AUF-DAY
                   PERFORM RESOLVE-UNIT
                   MOVE WS-RU-RESULT TO WS-PART2
                   MOVE SPACES TO WS-FORMAT-RESULT
                   STRING
                       FUNCTION TRIM(WS-PART1)
                       WS-EFF-DELIMITER(1:WS-EFF-DELIM-LEN)
                       FUNCTION TRIM(WS-PART2)
                       DELIMITED BY SIZE
                       INTO WS-FORMAT-RESULT
                   END-STRING
               ELSE
                   MOVE WS-PART1 TO WS-FORMAT-RESULT
               END-IF
               EXIT PARAGRAPH
           END-IF

           PERFORM CALC-APPROXIMATE-MONTHS

           *> 1-11 months
           IF WS-TOTAL-MONTHS < 12
               IF WS-TOTAL-MONTHS = 0
                   MOVE 1 TO WS-TOTAL-MONTHS
               END-IF
               MOVE WS-TOTAL-MONTHS TO WS-RU-COUNT
               MOVE SPACES TO WS-RU-HALF
               PERFORM LOAD-AUF-MONTH
               PERFORM RESOLVE-UNIT
               MOVE WS-RU-RESULT TO WS-FORMAT-RESULT
               EXIT PARAGRAPH
           END-IF

           *> 12+ months: years + months
           DIVIDE WS-TOTAL-MONTHS BY 12
               GIVING WS-TOTAL-YEARS
               REMAINDER WS-REM-MONTHS
           MOVE WS-TOTAL-YEARS TO WS-RU-COUNT
           MOVE SPACES TO WS-RU-HALF
           PERFORM LOAD-AUF-YEAR
           PERFORM RESOLVE-UNIT
           MOVE WS-RU-RESULT TO WS-PART1
           IF WS-REM-MONTHS > 0
               MOVE WS-REM-MONTHS TO WS-RU-COUNT
               MOVE SPACES TO WS-RU-HALF
               PERFORM LOAD-AUF-MONTH
               PERFORM RESOLVE-UNIT
               MOVE WS-RU-RESULT TO WS-PART2
               MOVE SPACES TO WS-FORMAT-RESULT
               STRING
                   FUNCTION TRIM(WS-PART1)
                   WS-EFF-DELIMITER(1:WS-EFF-DELIM-LEN)
                   FUNCTION TRIM(WS-PART2)
                   DELIMITED BY SIZE
                   INTO WS-FORMAT-RESULT
               END-STRING
           ELSE
               MOVE WS-PART1 TO WS-FORMAT-RESULT
           END-IF
           .

*> ============================================================
*> LOAD-AUF-* paragraphs: Load unit forms into WS-AUF-*
*> ============================================================
       LOAD-AUF-SECOND.
           MOVE WS-EFF-SECOND-HAS-SIMPLE TO WS-AUF-HAS-SIMPLE
           MOVE WS-EFF-SECOND-SIMPLE TO WS-AUF-SIMPLE
           PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
               MOVE WS-EFF-SECOND-HAS-FORM(WS-I)
                   TO WS-AUF-HAS-FORM(WS-I)
               MOVE WS-EFF-SECOND-FORM(WS-I)
                   TO WS-AUF-FORM(WS-I)
           END-PERFORM
           .
       LOAD-AUF-MINUTE.
           MOVE WS-EFF-MINUTE-HAS-SIMPLE TO WS-AUF-HAS-SIMPLE
           MOVE WS-EFF-MINUTE-SIMPLE TO WS-AUF-SIMPLE
           PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
               MOVE WS-EFF-MINUTE-HAS-FORM(WS-I)
                   TO WS-AUF-HAS-FORM(WS-I)
               MOVE WS-EFF-MINUTE-FORM(WS-I)
                   TO WS-AUF-FORM(WS-I)
           END-PERFORM
           .
       LOAD-AUF-HOUR.
           MOVE WS-EFF-HOUR-HAS-SIMPLE TO WS-AUF-HAS-SIMPLE
           MOVE WS-EFF-HOUR-SIMPLE TO WS-AUF-SIMPLE
           PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
               MOVE WS-EFF-HOUR-HAS-FORM(WS-I)
                   TO WS-AUF-HAS-FORM(WS-I)
               MOVE WS-EFF-HOUR-FORM(WS-I)
                   TO WS-AUF-FORM(WS-I)
           END-PERFORM
           .
       LOAD-AUF-DAY.
           MOVE WS-EFF-DAY-HAS-SIMPLE TO WS-AUF-HAS-SIMPLE
           MOVE WS-EFF-DAY-SIMPLE TO WS-AUF-SIMPLE
           PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
               MOVE WS-EFF-DAY-HAS-FORM(WS-I)
                   TO WS-AUF-HAS-FORM(WS-I)
               MOVE WS-EFF-DAY-FORM(WS-I)
                   TO WS-AUF-FORM(WS-I)
           END-PERFORM
           .
       LOAD-AUF-WEEK.
           MOVE WS-EFF-WEEK-HAS-SIMPLE TO WS-AUF-HAS-SIMPLE
           MOVE WS-EFF-WEEK-SIMPLE TO WS-AUF-SIMPLE
           PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
               MOVE WS-EFF-WEEK-HAS-FORM(WS-I)
                   TO WS-AUF-HAS-FORM(WS-I)
               MOVE WS-EFF-WEEK-FORM(WS-I)
                   TO WS-AUF-FORM(WS-I)
           END-PERFORM
           .
       LOAD-AUF-MONTH.
           MOVE WS-EFF-MONTH-HAS-SIMPLE TO WS-AUF-HAS-SIMPLE
           MOVE WS-EFF-MONTH-SIMPLE TO WS-AUF-SIMPLE
           PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
               MOVE WS-EFF-MONTH-HAS-FORM(WS-I)
                   TO WS-AUF-HAS-FORM(WS-I)
               MOVE WS-EFF-MONTH-FORM(WS-I)
                   TO WS-AUF-FORM(WS-I)
           END-PERFORM
           .
       LOAD-AUF-YEAR.
           MOVE WS-EFF-YEAR-HAS-SIMPLE TO WS-AUF-HAS-SIMPLE
           MOVE WS-EFF-YEAR-SIMPLE TO WS-AUF-SIMPLE
           PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
               MOVE WS-EFF-YEAR-HAS-FORM(WS-I)
                   TO WS-AUF-HAS-FORM(WS-I)
               MOVE WS-EFF-YEAR-FORM(WS-I)
                   TO WS-AUF-FORM(WS-I)
           END-PERFORM
           .

*> ============================================================
*> COPY-LOCALE-TO-EFFECTIVE and APPLY-COMPACTNESS-OVERRIDE
*> (same pattern as age, but with 7 units + ago/inFuture)
*> ============================================================
       COPY-LOCALE-TO-EFFECTIVE.
           PERFORM COPY-UNIT-SECOND
           PERFORM COPY-UNIT-MINUTE
           PERFORM COPY-UNIT-HOUR
           PERFORM COPY-UNIT-DAY
           PERFORM COPY-UNIT-WEEK
           PERFORM COPY-UNIT-MONTH
           PERFORM COPY-UNIT-YEAR
           MOVE WS-ACT-HALF TO WS-EFF-HALF
           MOVE WS-ACT-DELIMITER TO WS-EFF-DELIMITER
           MOVE WS-ACT-DELIM-LEN TO WS-EFF-DELIM-LEN
           MOVE WS-ACT-JUST-NOW TO WS-EFF-JUST-NOW
           MOVE WS-ACT-AGO TO WS-EFF-AGO
           MOVE WS-ACT-IN-FUTURE TO WS-EFF-IN-FUTURE
           .

       COPY-UNIT-SECOND.
           MOVE WS-ACT-SECOND-HAS-SIMPLE
               TO WS-EFF-SECOND-HAS-SIMPLE
           MOVE WS-ACT-SECOND-SIMPLE TO WS-EFF-SECOND-SIMPLE
           PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
               MOVE WS-ACT-SECOND-HAS-FORM(WS-I)
                   TO WS-EFF-SECOND-HAS-FORM(WS-I)
               MOVE WS-ACT-SECOND-FORM(WS-I)
                   TO WS-EFF-SECOND-FORM(WS-I)
           END-PERFORM
           .
       COPY-UNIT-MINUTE.
           MOVE WS-ACT-MINUTE-HAS-SIMPLE
               TO WS-EFF-MINUTE-HAS-SIMPLE
           MOVE WS-ACT-MINUTE-SIMPLE TO WS-EFF-MINUTE-SIMPLE
           PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
               MOVE WS-ACT-MINUTE-HAS-FORM(WS-I)
                   TO WS-EFF-MINUTE-HAS-FORM(WS-I)
               MOVE WS-ACT-MINUTE-FORM(WS-I)
                   TO WS-EFF-MINUTE-FORM(WS-I)
           END-PERFORM
           .
       COPY-UNIT-HOUR.
           MOVE WS-ACT-HOUR-HAS-SIMPLE
               TO WS-EFF-HOUR-HAS-SIMPLE
           MOVE WS-ACT-HOUR-SIMPLE TO WS-EFF-HOUR-SIMPLE
           PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
               MOVE WS-ACT-HOUR-HAS-FORM(WS-I)
                   TO WS-EFF-HOUR-HAS-FORM(WS-I)
               MOVE WS-ACT-HOUR-FORM(WS-I)
                   TO WS-EFF-HOUR-FORM(WS-I)
           END-PERFORM
           .
       COPY-UNIT-DAY.
           MOVE WS-ACT-DAY-HAS-SIMPLE
               TO WS-EFF-DAY-HAS-SIMPLE
           MOVE WS-ACT-DAY-SIMPLE TO WS-EFF-DAY-SIMPLE
           PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
               MOVE WS-ACT-DAY-HAS-FORM(WS-I)
                   TO WS-EFF-DAY-HAS-FORM(WS-I)
               MOVE WS-ACT-DAY-FORM(WS-I)
                   TO WS-EFF-DAY-FORM(WS-I)
           END-PERFORM
           .
       COPY-UNIT-WEEK.
           MOVE WS-ACT-WEEK-HAS-SIMPLE
               TO WS-EFF-WEEK-HAS-SIMPLE
           MOVE WS-ACT-WEEK-SIMPLE TO WS-EFF-WEEK-SIMPLE
           PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
               MOVE WS-ACT-WEEK-HAS-FORM(WS-I)
                   TO WS-EFF-WEEK-HAS-FORM(WS-I)
               MOVE WS-ACT-WEEK-FORM(WS-I)
                   TO WS-EFF-WEEK-FORM(WS-I)
           END-PERFORM
           .
       COPY-UNIT-MONTH.
           MOVE WS-ACT-MONTH-HAS-SIMPLE
               TO WS-EFF-MONTH-HAS-SIMPLE
           MOVE WS-ACT-MONTH-SIMPLE TO WS-EFF-MONTH-SIMPLE
           PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
               MOVE WS-ACT-MONTH-HAS-FORM(WS-I)
                   TO WS-EFF-MONTH-HAS-FORM(WS-I)
               MOVE WS-ACT-MONTH-FORM(WS-I)
                   TO WS-EFF-MONTH-FORM(WS-I)
           END-PERFORM
           .
       COPY-UNIT-YEAR.
           MOVE WS-ACT-YEAR-HAS-SIMPLE
               TO WS-EFF-YEAR-HAS-SIMPLE
           MOVE WS-ACT-YEAR-SIMPLE TO WS-EFF-YEAR-SIMPLE
           PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
               MOVE WS-ACT-YEAR-HAS-FORM(WS-I)
                   TO WS-EFF-YEAR-HAS-FORM(WS-I)
               MOVE WS-ACT-YEAR-FORM(WS-I)
                   TO WS-EFF-YEAR-FORM(WS-I)
           END-PERFORM
           .

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
           PERFORM APPLY-SHORT-UNITS
           IF WS-ACT-SHORT-HAS-HALF = 1
               MOVE WS-ACT-SHORT-HALF TO WS-EFF-HALF
           END-IF
           IF WS-ACT-SHORT-HAS-DELIM = 1
               MOVE WS-ACT-SHORT-DELIM TO WS-EFF-DELIMITER
               MOVE WS-ACT-SHORT-DELIM-LEN TO WS-EFF-DELIM-LEN
           END-IF
           IF WS-ACT-SHORT-HAS-AGO = 1
               MOVE WS-ACT-SHORT-AGO TO WS-EFF-AGO
           END-IF
           IF WS-ACT-SHORT-HAS-IN-FUTURE = 1
               MOVE WS-ACT-SHORT-IN-FUTURE TO WS-EFF-IN-FUTURE
           END-IF
           .

       APPLY-SHORT-UNITS.
           IF WS-ACT-SHORT-HAS-SECOND = 1
               MOVE WS-ACT-SHORT-SECOND-HAS-SIMPLE
                   TO WS-EFF-SECOND-HAS-SIMPLE
               MOVE WS-ACT-SHORT-SECOND-SIMPLE
                   TO WS-EFF-SECOND-SIMPLE
               PERFORM VARYING WS-I FROM 1 BY 1
                   UNTIL WS-I > 6
                   MOVE WS-ACT-SHORT-SECOND-HAS-FORM(WS-I)
                       TO WS-EFF-SECOND-HAS-FORM(WS-I)
                   MOVE WS-ACT-SHORT-SECOND-FORM(WS-I)
                       TO WS-EFF-SECOND-FORM(WS-I)
               END-PERFORM
           END-IF
           IF WS-ACT-SHORT-HAS-MINUTE = 1
               MOVE WS-ACT-SHORT-MINUTE-HAS-SIMPLE
                   TO WS-EFF-MINUTE-HAS-SIMPLE
               MOVE WS-ACT-SHORT-MINUTE-SIMPLE
                   TO WS-EFF-MINUTE-SIMPLE
               PERFORM VARYING WS-I FROM 1 BY 1
                   UNTIL WS-I > 6
                   MOVE WS-ACT-SHORT-MINUTE-HAS-FORM(WS-I)
                       TO WS-EFF-MINUTE-HAS-FORM(WS-I)
                   MOVE WS-ACT-SHORT-MINUTE-FORM(WS-I)
                       TO WS-EFF-MINUTE-FORM(WS-I)
               END-PERFORM
           END-IF
           IF WS-ACT-SHORT-HAS-HOUR = 1
               MOVE WS-ACT-SHORT-HOUR-HAS-SIMPLE
                   TO WS-EFF-HOUR-HAS-SIMPLE
               MOVE WS-ACT-SHORT-HOUR-SIMPLE
                   TO WS-EFF-HOUR-SIMPLE
               PERFORM VARYING WS-I FROM 1 BY 1
                   UNTIL WS-I > 6
                   MOVE WS-ACT-SHORT-HOUR-HAS-FORM(WS-I)
                       TO WS-EFF-HOUR-HAS-FORM(WS-I)
                   MOVE WS-ACT-SHORT-HOUR-FORM(WS-I)
                       TO WS-EFF-HOUR-FORM(WS-I)
               END-PERFORM
           END-IF
           IF WS-ACT-SHORT-HAS-DAY = 1
               MOVE WS-ACT-SHORT-DAY-HAS-SIMPLE
                   TO WS-EFF-DAY-HAS-SIMPLE
               MOVE WS-ACT-SHORT-DAY-SIMPLE
                   TO WS-EFF-DAY-SIMPLE
               PERFORM VARYING WS-I FROM 1 BY 1
                   UNTIL WS-I > 6
                   MOVE WS-ACT-SHORT-DAY-HAS-FORM(WS-I)
                       TO WS-EFF-DAY-HAS-FORM(WS-I)
                   MOVE WS-ACT-SHORT-DAY-FORM(WS-I)
                       TO WS-EFF-DAY-FORM(WS-I)
               END-PERFORM
           END-IF
           IF WS-ACT-SHORT-HAS-WEEK = 1
               MOVE WS-ACT-SHORT-WEEK-HAS-SIMPLE
                   TO WS-EFF-WEEK-HAS-SIMPLE
               MOVE WS-ACT-SHORT-WEEK-SIMPLE
                   TO WS-EFF-WEEK-SIMPLE
               PERFORM VARYING WS-I FROM 1 BY 1
                   UNTIL WS-I > 6
                   MOVE WS-ACT-SHORT-WEEK-HAS-FORM(WS-I)
                       TO WS-EFF-WEEK-HAS-FORM(WS-I)
                   MOVE WS-ACT-SHORT-WEEK-FORM(WS-I)
                       TO WS-EFF-WEEK-FORM(WS-I)
               END-PERFORM
           END-IF
           IF WS-ACT-SHORT-HAS-MONTH = 1
               MOVE WS-ACT-SHORT-MONTH-HAS-SIMPLE
                   TO WS-EFF-MONTH-HAS-SIMPLE
               MOVE WS-ACT-SHORT-MONTH-SIMPLE
                   TO WS-EFF-MONTH-SIMPLE
               PERFORM VARYING WS-I FROM 1 BY 1
                   UNTIL WS-I > 6
                   MOVE WS-ACT-SHORT-MONTH-HAS-FORM(WS-I)
                       TO WS-EFF-MONTH-HAS-FORM(WS-I)
                   MOVE WS-ACT-SHORT-MONTH-FORM(WS-I)
                       TO WS-EFF-MONTH-FORM(WS-I)
               END-PERFORM
           END-IF
           IF WS-ACT-SHORT-HAS-YEAR = 1
               MOVE WS-ACT-SHORT-YEAR-HAS-SIMPLE
                   TO WS-EFF-YEAR-HAS-SIMPLE
               MOVE WS-ACT-SHORT-YEAR-SIMPLE
                   TO WS-EFF-YEAR-SIMPLE
               PERFORM VARYING WS-I FROM 1 BY 1
                   UNTIL WS-I > 6
                   MOVE WS-ACT-SHORT-YEAR-HAS-FORM(WS-I)
                       TO WS-EFF-YEAR-HAS-FORM(WS-I)
                   MOVE WS-ACT-SHORT-YEAR-FORM(WS-I)
                       TO WS-EFF-YEAR-FORM(WS-I)
               END-PERFORM
           END-IF
           .

       APPLY-COMPACT-OVERRIDE.
           PERFORM APPLY-COMPACT-UNITS
           IF WS-ACT-COMPACT-HAS-HALF = 1
               MOVE WS-ACT-COMPACT-HALF TO WS-EFF-HALF
           END-IF
           IF WS-ACT-COMPACT-HAS-DELIM = 1
               MOVE WS-ACT-COMPACT-DELIM TO WS-EFF-DELIMITER
               MOVE WS-ACT-COMPACT-DELIM-LEN
                   TO WS-EFF-DELIM-LEN
           END-IF
           IF WS-ACT-COMPACT-HAS-AGO = 1
               MOVE WS-ACT-COMPACT-AGO TO WS-EFF-AGO
           END-IF
           IF WS-ACT-COMPACT-HAS-IN-FUTURE = 1
               MOVE WS-ACT-COMPACT-IN-FUTURE
                   TO WS-EFF-IN-FUTURE
           END-IF
           .

       APPLY-COMPACT-UNITS.
           IF WS-ACT-COMPACT-HAS-SECOND = 1
               MOVE WS-ACT-COMPACT-SECOND-HAS-SIMPLE
                   TO WS-EFF-SECOND-HAS-SIMPLE
               MOVE WS-ACT-COMPACT-SECOND-SIMPLE
                   TO WS-EFF-SECOND-SIMPLE
               PERFORM VARYING WS-I FROM 1 BY 1
                   UNTIL WS-I > 6
                   MOVE WS-ACT-COMPACT-SECOND-HAS-FORM(WS-I)
                       TO WS-EFF-SECOND-HAS-FORM(WS-I)
                   MOVE WS-ACT-COMPACT-SECOND-FORM(WS-I)
                       TO WS-EFF-SECOND-FORM(WS-I)
               END-PERFORM
           END-IF
           IF WS-ACT-COMPACT-HAS-MINUTE = 1
               MOVE WS-ACT-COMPACT-MINUTE-HAS-SIMPLE
                   TO WS-EFF-MINUTE-HAS-SIMPLE
               MOVE WS-ACT-COMPACT-MINUTE-SIMPLE
                   TO WS-EFF-MINUTE-SIMPLE
               PERFORM VARYING WS-I FROM 1 BY 1
                   UNTIL WS-I > 6
                   MOVE WS-ACT-COMPACT-MINUTE-HAS-FORM(WS-I)
                       TO WS-EFF-MINUTE-HAS-FORM(WS-I)
                   MOVE WS-ACT-COMPACT-MINUTE-FORM(WS-I)
                       TO WS-EFF-MINUTE-FORM(WS-I)
               END-PERFORM
           END-IF
           IF WS-ACT-COMPACT-HAS-HOUR = 1
               MOVE WS-ACT-COMPACT-HOUR-HAS-SIMPLE
                   TO WS-EFF-HOUR-HAS-SIMPLE
               MOVE WS-ACT-COMPACT-HOUR-SIMPLE
                   TO WS-EFF-HOUR-SIMPLE
               PERFORM VARYING WS-I FROM 1 BY 1
                   UNTIL WS-I > 6
                   MOVE WS-ACT-COMPACT-HOUR-HAS-FORM(WS-I)
                       TO WS-EFF-HOUR-HAS-FORM(WS-I)
                   MOVE WS-ACT-COMPACT-HOUR-FORM(WS-I)
                       TO WS-EFF-HOUR-FORM(WS-I)
               END-PERFORM
           END-IF
           IF WS-ACT-COMPACT-HAS-DAY = 1
               MOVE WS-ACT-COMPACT-DAY-HAS-SIMPLE
                   TO WS-EFF-DAY-HAS-SIMPLE
               MOVE WS-ACT-COMPACT-DAY-SIMPLE
                   TO WS-EFF-DAY-SIMPLE
               PERFORM VARYING WS-I FROM 1 BY 1
                   UNTIL WS-I > 6
                   MOVE WS-ACT-COMPACT-DAY-HAS-FORM(WS-I)
                       TO WS-EFF-DAY-HAS-FORM(WS-I)
                   MOVE WS-ACT-COMPACT-DAY-FORM(WS-I)
                       TO WS-EFF-DAY-FORM(WS-I)
               END-PERFORM
           END-IF
           IF WS-ACT-COMPACT-HAS-WEEK = 1
               MOVE WS-ACT-COMPACT-WEEK-HAS-SIMPLE
                   TO WS-EFF-WEEK-HAS-SIMPLE
               MOVE WS-ACT-COMPACT-WEEK-SIMPLE
                   TO WS-EFF-WEEK-SIMPLE
               PERFORM VARYING WS-I FROM 1 BY 1
                   UNTIL WS-I > 6
                   MOVE WS-ACT-COMPACT-WEEK-HAS-FORM(WS-I)
                       TO WS-EFF-WEEK-HAS-FORM(WS-I)
                   MOVE WS-ACT-COMPACT-WEEK-FORM(WS-I)
                       TO WS-EFF-WEEK-FORM(WS-I)
               END-PERFORM
           END-IF
           IF WS-ACT-COMPACT-HAS-MONTH = 1
               MOVE WS-ACT-COMPACT-MONTH-HAS-SIMPLE
                   TO WS-EFF-MONTH-HAS-SIMPLE
               MOVE WS-ACT-COMPACT-MONTH-SIMPLE
                   TO WS-EFF-MONTH-SIMPLE
               PERFORM VARYING WS-I FROM 1 BY 1
                   UNTIL WS-I > 6
                   MOVE WS-ACT-COMPACT-MONTH-HAS-FORM(WS-I)
                       TO WS-EFF-MONTH-HAS-FORM(WS-I)
                   MOVE WS-ACT-COMPACT-MONTH-FORM(WS-I)
                       TO WS-EFF-MONTH-FORM(WS-I)
               END-PERFORM
           END-IF
           IF WS-ACT-COMPACT-HAS-YEAR = 1
               MOVE WS-ACT-COMPACT-YEAR-HAS-SIMPLE
                   TO WS-EFF-YEAR-HAS-SIMPLE
               MOVE WS-ACT-COMPACT-YEAR-SIMPLE
                   TO WS-EFF-YEAR-SIMPLE
               PERFORM VARYING WS-I FROM 1 BY 1
                   UNTIL WS-I > 6
                   MOVE WS-ACT-COMPACT-YEAR-HAS-FORM(WS-I)
                       TO WS-EFF-YEAR-HAS-FORM(WS-I)
                   MOVE WS-ACT-COMPACT-YEAR-FORM(WS-I)
                       TO WS-EFF-YEAR-FORM(WS-I)
               END-PERFORM
           END-IF
           .

*> ============================================================
*> RESOLVE-UNIT: Resolve a count+unit into a string
*> (Same as age implementation)
*> ============================================================
       RESOLVE-UNIT.
           MOVE SPACES TO WS-RU-RESULT

           MOVE WS-RU-COUNT TO WS-NUM-TO-STR-INPUT
           PERFORM NUM-TO-STR
           MOVE WS-NUM-TO-STR-RESULT TO WS-RU-BASE-N

           IF FUNCTION TRIM(WS-RU-HALF) NOT = SPACES
               MOVE WS-RU-HALF TO WS-REPLACE-SRC
               MOVE "{n}" TO WS-REPLACE-MARKER
               MOVE FUNCTION TRIM(WS-RU-BASE-N)
                   TO WS-REPLACE-REPL
               PERFORM REPLACE-FIRST
               IF WS-REPLACE-POS > 0
                   MOVE WS-REPLACE-RESULT TO WS-RU-N-STR
               ELSE
                   MOVE WS-RU-BASE-N TO WS-RU-N-STR
               END-IF
           ELSE
               MOVE WS-RU-BASE-N TO WS-RU-N-STR
           END-IF

           MOVE SPACES TO WS-RU-TMPL
           IF WS-AUF-HAS-SIMPLE = 1
               MOVE WS-AUF-SIMPLE TO WS-RU-TMPL
           ELSE
               MOVE WS-RU-COUNT TO WS-PLURAL-N
               IF FUNCTION TRIM(WS-RU-HALF) NOT = SPACES
                   MOVE PT-OTHER TO WS-PLURAL-CAT
               ELSE
                   PERFORM APPLY-PLURAL-RULE
               END-IF
               IF WS-AUF-HAS-FORM(WS-PLURAL-CAT) = 1
                   MOVE WS-AUF-FORM(WS-PLURAL-CAT)
                       TO WS-RU-TMPL
               ELSE
                   IF WS-AUF-HAS-FORM(PT-OTHER) = 1
                       MOVE WS-AUF-FORM(PT-OTHER) TO WS-RU-TMPL
                   END-IF
               END-IF
           END-IF

           IF FUNCTION TRIM(WS-RU-TMPL) = SPACES
               EXIT PARAGRAPH
           END-IF

           MOVE WS-RU-TMPL TO WS-REPLACE-SRC
           MOVE "{n}" TO WS-REPLACE-MARKER
           MOVE FUNCTION TRIM(WS-RU-N-STR) TO WS-REPLACE-REPL
           PERFORM REPLACE-FIRST
           MOVE WS-REPLACE-RESULT TO WS-RU-RESULT

           IF FUNCTION TRIM(WS-RU-HALF) NOT = SPACES
               MOVE WS-RU-HALF TO WS-REPLACE-SRC
               MOVE "{0}" TO WS-REPLACE-MARKER
               MOVE FUNCTION TRIM(WS-RU-RESULT)
                   TO WS-REPLACE-REPL
               PERFORM REPLACE-FIRST
               IF WS-REPLACE-POS > 0
                   MOVE WS-REPLACE-RESULT TO WS-RU-RESULT
               END-IF
           END-IF
           .

*> ============================================================
*> PARSE-ISO-DATETIME: YYYY-MM-DDTHH:MM (one- or two-digit hour),
*> then optional :SS with optional .fraction, then an optional zone
*> suffix (Z or +HH:MM / -HH:MM, validated but never applied)
*> Input:  WS-ISO-STR, WS-ISO-LEN (0 = length without trailing blanks)
*> Output: WS-ISO-RESULT, WS-ISO-PARSE-OK
*> ============================================================
       PARSE-ISO-DATETIME.
           MOVE 0 TO WS-ISO-PARSE-OK
           IF WS-ISO-LEN = 0
               MOVE FUNCTION STORED-CHAR-LENGTH(WS-ISO-STR)
                   TO WS-ISO-LEN
           END-IF
           IF WS-ISO-LEN < 15 OR WS-ISO-LEN > 256
               EXIT PARAGRAPH
           END-IF
           IF WS-ISO-STR(5:1) NOT = "-"
               OR WS-ISO-STR(8:1) NOT = "-"
               OR WS-ISO-STR(11:1) NOT = "T"
               OR WS-ISO-STR(1:4) IS NOT NUMERIC
               OR WS-ISO-STR(6:2) IS NOT NUMERIC
               OR WS-ISO-STR(9:2) IS NOT NUMERIC
               EXIT PARAGRAPH
           END-IF
           MOVE WS-ISO-STR(1:4) TO WS-ISO-YEAR
           MOVE WS-ISO-STR(6:2) TO WS-ISO-MONTH
           MOVE WS-ISO-STR(9:2) TO WS-ISO-DAY
           PERFORM CHECK-ISO-DATE
           IF WS-ISO-DATE-OK = 0
               EXIT PARAGRAPH
           END-IF

           MOVE 12 TO WS-ISO-SCAN-POS
           MOVE 0 TO WS-ISO-HOUR-DIGITS
           PERFORM UNTIL WS-ISO-HOUR-DIGITS = 2
                   OR WS-ISO-SCAN-POS > WS-ISO-LEN
                   OR WS-ISO-STR(WS-ISO-SCAN-POS:1) IS NOT NUMERIC
               ADD 1 TO WS-ISO-HOUR-DIGITS
               ADD 1 TO WS-ISO-SCAN-POS
           END-PERFORM
           IF WS-ISO-HOUR-DIGITS = 0
               OR WS-ISO-SCAN-POS + 2 > WS-ISO-LEN
               EXIT PARAGRAPH
           END-IF
           IF WS-ISO-STR(WS-ISO-SCAN-POS:1) NOT = ":"
               OR WS-ISO-STR(WS-ISO-SCAN-POS + 1:2) IS NOT NUMERIC
               EXIT PARAGRAPH
           END-IF
           COMPUTE WS-ISO-HOUR = FUNCTION NUMVAL(
               WS-ISO-STR(12:WS-ISO-HOUR-DIGITS))
           MOVE WS-ISO-STR(WS-ISO-SCAN-POS + 1:2) TO WS-ISO-MINUTE
           ADD 3 TO WS-ISO-SCAN-POS
           MOVE 0 TO WS-ISO-SECOND
           IF WS-ISO-SCAN-POS + 2 <= WS-ISO-LEN
               AND WS-ISO-STR(WS-ISO-SCAN-POS:1) = ":"
               AND WS-ISO-STR(WS-ISO-SCAN-POS + 1:2) IS NUMERIC
               MOVE WS-ISO-STR(WS-ISO-SCAN-POS + 1:2) TO WS-ISO-SECOND
               ADD 3 TO WS-ISO-SCAN-POS
               IF WS-ISO-SCAN-POS + 1 <= WS-ISO-LEN
                   AND WS-ISO-STR(WS-ISO-SCAN-POS:1) = "."
                   AND WS-ISO-STR(WS-ISO-SCAN-POS + 1:1) IS NUMERIC
                   ADD 1 TO WS-ISO-SCAN-POS
                   PERFORM UNTIL WS-ISO-SCAN-POS > WS-ISO-LEN
                           OR WS-ISO-STR(WS-ISO-SCAN-POS:1)
                               IS NOT NUMERIC
                       ADD 1 TO WS-ISO-SCAN-POS
                   END-PERFORM
               END-IF
           END-IF
           COMPUTE WS-ISO-ZONE-LEN = WS-ISO-LEN - WS-ISO-SCAN-POS + 1
           EVALUATE TRUE
               WHEN WS-ISO-ZONE-LEN = 0
                   CONTINUE
               WHEN WS-ISO-ZONE-LEN = 1
                   AND WS-ISO-STR(WS-ISO-SCAN-POS:1) = "Z"
                   CONTINUE
               WHEN WS-ISO-ZONE-LEN = 6
                   AND (WS-ISO-STR(WS-ISO-SCAN-POS:1) = "+"
                       OR WS-ISO-STR(WS-ISO-SCAN-POS:1) = "-")
                   AND WS-ISO-STR(WS-ISO-SCAN-POS + 1:2) IS NUMERIC
                   AND WS-ISO-STR(WS-ISO-SCAN-POS + 3:1) = ":"
                   AND WS-ISO-STR(WS-ISO-SCAN-POS + 4:2) IS NUMERIC
                   CONTINUE
               WHEN OTHER
                   EXIT PARAGRAPH
           END-EVALUATE
           IF WS-ISO-HOUR > 23 OR WS-ISO-MINUTE > 59
               OR WS-ISO-SECOND > 59
               EXIT PARAGRAPH
           END-IF

           MOVE WS-ISO-YEAR TO WS-DSE-YEAR
           MOVE WS-ISO-MONTH TO WS-DSE-MONTH
           MOVE WS-ISO-DAY TO WS-DSE-DAY
           PERFORM CALC-DAYS-SINCE-EPOCH

           COMPUTE WS-ISO-RESULT =
               WS-DSE-RESULT * 86400
               + WS-ISO-HOUR * 3600
               + WS-ISO-MINUTE * 60
               + WS-ISO-SECOND
           MOVE 1 TO WS-ISO-PARSE-OK
           .

*> ============================================================
*> CHECK-ISO-DATE: WS-ISO-YEAR/MONTH/DAY name a real calendar day
*> Output: WS-ISO-DATE-OK (1=real date, 0=not)
*> ============================================================
       CHECK-ISO-DATE.
           MOVE 0 TO WS-ISO-DATE-OK
           IF WS-ISO-MONTH < 1 OR WS-ISO-MONTH > 12
               EXIT PARAGRAPH
           END-IF
           MOVE WS-ISO-YEAR TO WS-DIM-YEAR
           MOVE WS-ISO-MONTH TO WS-DIM-MONTH
           PERFORM CALC-DAYS-IN-MONTH
           IF WS-ISO-DAY >= 1 AND WS-ISO-DAY <= WS-DIM-RESULT
               MOVE 1 TO WS-ISO-DATE-OK
           END-IF
           .

*> ============================================================
*> CALC-APPROXIMATE-MONTHS: Months of 30.44 days (the average
*> month), rounded, in exact integer arithmetic
*> Input:  WS-TOTAL-DAYS
*> Output: WS-TOTAL-MONTHS
*> ============================================================
       CALC-APPROXIMATE-MONTHS.
           COMPUTE WS-TOTAL-MONTHS =
               (WS-TOTAL-DAYS * 100 + 1522) / 3044
           .

*> ============================================================
*> CALC-DAYS-SINCE-EPOCH: Days since 2000-01-01
*> Input:  WS-DSE-YEAR, WS-DSE-MONTH, WS-DSE-DAY
*> Output: WS-DSE-RESULT
*> ============================================================
       CALC-DAYS-SINCE-EPOCH.
           MOVE 0 TO WS-DSE-RESULT
           IF WS-DSE-YEAR >= 2000
               PERFORM VARYING WS-DSE-Y FROM 2000 BY 1
                   UNTIL WS-DSE-Y >= WS-DSE-YEAR
                   MOVE WS-DSE-Y TO WS-LEAP-YEAR
                   PERFORM CHECK-LEAP-YEAR
                   IF WS-IS-LEAP = 1
                       ADD 366 TO WS-DSE-RESULT
                   ELSE
                       ADD 365 TO WS-DSE-RESULT
                   END-IF
               END-PERFORM
           ELSE
               PERFORM VARYING WS-DSE-Y FROM WS-DSE-YEAR BY 1
                   UNTIL WS-DSE-Y >= 2000
                   MOVE WS-DSE-Y TO WS-LEAP-YEAR
                   PERFORM CHECK-LEAP-YEAR
                   IF WS-IS-LEAP = 1
                       SUBTRACT 366 FROM WS-DSE-RESULT
                   ELSE
                       SUBTRACT 365 FROM WS-DSE-RESULT
                   END-IF
               END-PERFORM
           END-IF
           PERFORM VARYING WS-DSE-M FROM 1 BY 1
               UNTIL WS-DSE-M >= WS-DSE-MONTH
               MOVE WS-DSE-YEAR TO WS-DIM-YEAR
               MOVE WS-DSE-M TO WS-DIM-MONTH
               PERFORM CALC-DAYS-IN-MONTH
               ADD WS-DIM-RESULT TO WS-DSE-RESULT
           END-PERFORM
           ADD WS-DSE-DAY TO WS-DSE-RESULT
           SUBTRACT 1 FROM WS-DSE-RESULT
           .

*> ============================================================
*> CALC-DAYS-IN-MONTH: Get days in a given month/year
*> Input:  WS-DIM-YEAR, WS-DIM-MONTH
*> Output: WS-DIM-RESULT
*> ============================================================
       CALC-DAYS-IN-MONTH.
           MOVE WS-MONTH-DAYS(WS-DIM-MONTH) TO WS-DIM-RESULT
           IF WS-DIM-MONTH = 2
               MOVE WS-DIM-YEAR TO WS-LEAP-YEAR
               PERFORM CHECK-LEAP-YEAR
               IF WS-IS-LEAP = 1
                   MOVE 29 TO WS-DIM-RESULT
               END-IF
           END-IF
           .

*> ============================================================
*> CHECK-LEAP-YEAR: Check if WS-LEAP-YEAR is a leap year
*> Output: WS-IS-LEAP (1=leap, 0=not)
*> ============================================================
       CHECK-LEAP-YEAR.
           MOVE 0 TO WS-IS-LEAP
           DIVIDE WS-LEAP-YEAR BY 4
               GIVING WS-LEAP-REM4 REMAINDER WS-LEAP-REM4
           IF WS-LEAP-REM4 = 0
               DIVIDE WS-LEAP-YEAR BY 100
                   GIVING WS-LEAP-REM100
                   REMAINDER WS-LEAP-REM100
               IF WS-LEAP-REM100 NOT = 0
                   MOVE 1 TO WS-IS-LEAP
               ELSE
                   DIVIDE WS-LEAP-YEAR BY 400
                       GIVING WS-LEAP-REM400
                       REMAINDER WS-LEAP-REM400
                   IF WS-LEAP-REM400 = 0
                       MOVE 1 TO WS-IS-LEAP
                   END-IF
               END-IF
           END-IF
           .

*> ============================================================
*> REPLACE-FIRST: Replace first occurrence of marker in src
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
*> ============================================================
       NUM-TO-STR.
           MOVE WS-NUM-TO-STR-INPUT TO WS-NUM-TO-STR-EDITED
           MOVE FUNCTION TRIM(WS-NUM-TO-STR-EDITED)
               TO WS-NUM-TO-STR-RESULT
           .
