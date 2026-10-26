*> SayableAge.cbl - PROCEDURE DIVISION copybook for sayable-age
*> Contains the core formatting paragraphs.
*> Included via COPY in the main test program.
*> Requires: Types.cbl (WORKING-STORAGE) and Locales.cbl (locale data)

*> ============================================================
*> FORMAT-AGE: Main entry point for age formatting
*> Input:  WS-FMT-DOB, WS-FMT-AS-OF, WS-FMT-COMPACTNESS
*>         WS-ACT-* must be loaded via GET-LOCALE
*> Output: WS-FORMAT-RESULT
*> ============================================================
       FORMAT-AGE.
           MOVE SPACES TO WS-FORMAT-RESULT

           *> Validate DOB
           IF FUNCTION TRIM(WS-FMT-DOB) = SPACES
               EXIT PARAGRAPH
           END-IF
           MOVE WS-FMT-DOB TO WS-DATE-STR
           MOVE WS-FMT-DOB-LEN TO WS-DATE-LEN
           PERFORM PARSE-DATE
           IF WS-PARSE-OK = 0
               EXIT PARAGRAPH
           END-IF
           MOVE WS-PARSED-YEAR TO WS-DOB-YEAR
           MOVE WS-PARSED-MONTH TO WS-DOB-MONTH
           MOVE WS-PARSED-DAY TO WS-DOB-DAY

           *> Validate as-of
           IF FUNCTION TRIM(WS-FMT-AS-OF) = SPACES
               PERFORM DEFAULT-AS-OF-TODAY
           END-IF
           MOVE WS-FMT-AS-OF TO WS-DATE-STR
           MOVE WS-FMT-AS-OF-LEN TO WS-DATE-LEN
           PERFORM PARSE-DATE
           IF WS-PARSE-OK = 0
               EXIT PARAGRAPH
           END-IF
           MOVE WS-PARSED-YEAR TO WS-REF-YEAR
           MOVE WS-PARSED-MONTH TO WS-REF-MONTH
           MOVE WS-PARSED-DAY TO WS-REF-DAY

           *> Calculate Julian days and diff
           MOVE WS-DOB-YEAR TO WS-JD-CALC-YEAR
           MOVE WS-DOB-MONTH TO WS-JD-CALC-MONTH
           MOVE WS-DOB-DAY TO WS-JD-CALC-DAY
           PERFORM CALC-JULIAN-DAY
           MOVE WS-JD-CALC-RESULT TO WS-JD1

           MOVE WS-REF-YEAR TO WS-JD-CALC-YEAR
           MOVE WS-REF-MONTH TO WS-JD-CALC-MONTH
           MOVE WS-REF-DAY TO WS-JD-CALC-DAY
           PERFORM CALC-JULIAN-DAY
           MOVE WS-JD-CALC-RESULT TO WS-JD2

           COMPUTE WS-DIFF-DAYS = WS-JD2 - WS-JD1
           IF WS-DIFF-DAYS < 0
               EXIT PARAGRAPH
           END-IF

           *> Calculate months
           MOVE WS-REF-YEAR TO WS-DIM-YEAR
           MOVE WS-REF-MONTH TO WS-DIM-MONTH
           PERFORM CALC-DAYS-IN-MONTH
           MOVE WS-DIM-RESULT TO WS-LAST-DAY

           IF WS-DOB-DAY < WS-LAST-DAY
               MOVE WS-DOB-DAY TO WS-CLAMPED-BDAY
           ELSE
               MOVE WS-LAST-DAY TO WS-CLAMPED-BDAY
           END-IF

           COMPUTE WS-MONTHS =
               (WS-REF-YEAR - WS-DOB-YEAR) * 12
               + (WS-REF-MONTH - WS-DOB-MONTH)
           IF WS-REF-DAY < WS-CLAMPED-BDAY
               SUBTRACT 1 FROM WS-MONTHS
           END-IF

           IF WS-MONTHS > PT-MAX-AGE-MONTHS
               EXIT PARAGRAPH
           END-IF

           *> Apply compactness overrides to effective fields
           PERFORM COPY-LOCALE-TO-EFFECTIVE
           PERFORM APPLY-COMPACTNESS-OVERRIDE

           *> Tier 1: 0 days = justBorn
           IF WS-DIFF-DAYS = 0
               MOVE WS-EFF-JUST-BORN TO WS-FORMAT-RESULT
               EXIT PARAGRAPH
           END-IF

           *> Tier 1b: 1-6 days
           IF WS-DIFF-DAYS < 7
               MOVE WS-DIFF-DAYS TO WS-RU-COUNT
               MOVE SPACES TO WS-RU-HALF
               MOVE WS-EFF-DAY-HAS-SIMPLE TO WS-AUF-HAS-SIMPLE
               MOVE WS-EFF-DAY-SIMPLE TO WS-AUF-SIMPLE
               PERFORM VARYING WS-I FROM 1 BY 1
                   UNTIL WS-I > 6
                   MOVE WS-EFF-DAY-HAS-FORM(WS-I)
                       TO WS-AUF-HAS-FORM(WS-I)
                   MOVE WS-EFF-DAY-FORM(WS-I)
                       TO WS-AUF-FORM(WS-I)
               END-PERFORM
               PERFORM RESOLVE-UNIT
               MOVE WS-RU-RESULT TO WS-FORMAT-RESULT
               EXIT PARAGRAPH
           END-IF

           *> Tier 2: weeks + days (under 3 months)
           IF WS-MONTHS < 3
               DIVIDE WS-DIFF-DAYS BY 7
                   GIVING WS-WEEKS REMAINDER WS-DAYS-REM

               *> Resolve weeks part
               MOVE WS-WEEKS TO WS-RU-COUNT
               MOVE SPACES TO WS-RU-HALF
               MOVE WS-EFF-WEEK-HAS-SIMPLE TO WS-AUF-HAS-SIMPLE
               MOVE WS-EFF-WEEK-SIMPLE TO WS-AUF-SIMPLE
               PERFORM VARYING WS-I FROM 1 BY 1
                   UNTIL WS-I > 6
                   MOVE WS-EFF-WEEK-HAS-FORM(WS-I)
                       TO WS-AUF-HAS-FORM(WS-I)
                   MOVE WS-EFF-WEEK-FORM(WS-I)
                       TO WS-AUF-FORM(WS-I)
               END-PERFORM
               PERFORM RESOLVE-UNIT
               MOVE WS-RU-RESULT TO WS-PART1

               IF WS-DAYS-REM > 0
                   *> Resolve days part
                   MOVE WS-DAYS-REM TO WS-RU-COUNT
                   MOVE SPACES TO WS-RU-HALF
                   MOVE WS-EFF-DAY-HAS-SIMPLE
                       TO WS-AUF-HAS-SIMPLE
                   MOVE WS-EFF-DAY-SIMPLE TO WS-AUF-SIMPLE
                   PERFORM VARYING WS-I FROM 1 BY 1
                       UNTIL WS-I > 6
                       MOVE WS-EFF-DAY-HAS-FORM(WS-I)
                           TO WS-AUF-HAS-FORM(WS-I)
                       MOVE WS-EFF-DAY-FORM(WS-I)
                           TO WS-AUF-FORM(WS-I)
                   END-PERFORM
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

           *> Tier 3: 3-23 months
           IF WS-MONTHS < 24
               MOVE WS-MONTHS TO WS-RU-COUNT
               MOVE SPACES TO WS-RU-HALF
               MOVE WS-EFF-MONTH-HAS-SIMPLE TO WS-AUF-HAS-SIMPLE
               MOVE WS-EFF-MONTH-SIMPLE TO WS-AUF-SIMPLE
               PERFORM VARYING WS-I FROM 1 BY 1
                   UNTIL WS-I > 6
                   MOVE WS-EFF-MONTH-HAS-FORM(WS-I)
                       TO WS-AUF-HAS-FORM(WS-I)
                   MOVE WS-EFF-MONTH-FORM(WS-I)
                       TO WS-AUF-FORM(WS-I)
               END-PERFORM
               PERFORM RESOLVE-UNIT
               MOVE WS-RU-RESULT TO WS-FORMAT-RESULT
               EXIT PARAGRAPH
           END-IF

           *> Tier 4: 24-35 months -> years + months
           IF WS-MONTHS < 36
               DIVIDE WS-MONTHS BY 12
                   GIVING WS-YEARS REMAINDER WS-REM-MONTHS

               *> Resolve years part
               MOVE WS-YEARS TO WS-RU-COUNT
               MOVE SPACES TO WS-RU-HALF
               MOVE WS-EFF-YEAR-HAS-SIMPLE TO WS-AUF-HAS-SIMPLE
               MOVE WS-EFF-YEAR-SIMPLE TO WS-AUF-SIMPLE
               PERFORM VARYING WS-I FROM 1 BY 1
                   UNTIL WS-I > 6
                   MOVE WS-EFF-YEAR-HAS-FORM(WS-I)
                       TO WS-AUF-HAS-FORM(WS-I)
                   MOVE WS-EFF-YEAR-FORM(WS-I)
                       TO WS-AUF-FORM(WS-I)
               END-PERFORM
               PERFORM RESOLVE-UNIT
               MOVE WS-RU-RESULT TO WS-PART1

               IF WS-REM-MONTHS = 0
                   MOVE WS-PART1 TO WS-FORMAT-RESULT
               ELSE
                   *> Resolve months part
                   MOVE WS-REM-MONTHS TO WS-RU-COUNT
                   MOVE SPACES TO WS-RU-HALF
                   MOVE WS-EFF-MONTH-HAS-SIMPLE
                       TO WS-AUF-HAS-SIMPLE
                   MOVE WS-EFF-MONTH-SIMPLE TO WS-AUF-SIMPLE
                   PERFORM VARYING WS-I FROM 1 BY 1
                       UNTIL WS-I > 6
                       MOVE WS-EFF-MONTH-HAS-FORM(WS-I)
                           TO WS-AUF-HAS-FORM(WS-I)
                       MOVE WS-EFF-MONTH-FORM(WS-I)
                           TO WS-AUF-FORM(WS-I)
                   END-PERFORM
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
               END-IF
               EXIT PARAGRAPH
           END-IF

           *> Tier 5: 3-6 years (36-83 months) with half
           IF WS-MONTHS < 84
               DIVIDE WS-MONTHS BY 12
                   GIVING WS-YEARS REMAINDER WS-REM-MONTHS

               MOVE WS-YEARS TO WS-RU-COUNT
               MOVE WS-EFF-YEAR-HAS-SIMPLE TO WS-AUF-HAS-SIMPLE
               MOVE WS-EFF-YEAR-SIMPLE TO WS-AUF-SIMPLE
               PERFORM VARYING WS-I FROM 1 BY 1
                   UNTIL WS-I > 6
                   MOVE WS-EFF-YEAR-HAS-FORM(WS-I)
                       TO WS-AUF-HAS-FORM(WS-I)
                   MOVE WS-EFF-YEAR-FORM(WS-I)
                       TO WS-AUF-FORM(WS-I)
               END-PERFORM

               IF WS-REM-MONTHS >= 6
                   MOVE WS-EFF-HALF TO WS-RU-HALF
               ELSE
                   MOVE SPACES TO WS-RU-HALF
               END-IF
               PERFORM RESOLVE-UNIT
               MOVE WS-RU-RESULT TO WS-FORMAT-RESULT
               EXIT PARAGRAPH
           END-IF

           *> Tier 6: 7+ years
           DIVIDE WS-MONTHS BY 12
               GIVING WS-YEARS REMAINDER WS-REM-MONTHS
           MOVE WS-YEARS TO WS-RU-COUNT
           MOVE SPACES TO WS-RU-HALF
           MOVE WS-EFF-YEAR-HAS-SIMPLE TO WS-AUF-HAS-SIMPLE
           MOVE WS-EFF-YEAR-SIMPLE TO WS-AUF-SIMPLE
           PERFORM VARYING WS-I FROM 1 BY 1
               UNTIL WS-I > 6
               MOVE WS-EFF-YEAR-HAS-FORM(WS-I)
                   TO WS-AUF-HAS-FORM(WS-I)
               MOVE WS-EFF-YEAR-FORM(WS-I)
                   TO WS-AUF-FORM(WS-I)
           END-PERFORM
           PERFORM RESOLVE-UNIT
           MOVE WS-RU-RESULT TO WS-FORMAT-RESULT
           .

*> ============================================================
*> FORMAT-STAGE: Determine life stage
*> Input:  WS-FMT-DOB, WS-FMT-AS-OF, WS-FMT-GENDER
*>         WS-ACT-* must be loaded via GET-LOCALE
*> Output: WS-STAGE-RESULT
*> ============================================================
       FORMAT-STAGE.
           MOVE SPACES TO WS-STAGE-RESULT

           *> Validate DOB
           IF FUNCTION TRIM(WS-FMT-DOB) = SPACES
               EXIT PARAGRAPH
           END-IF
           MOVE WS-FMT-DOB TO WS-DATE-STR
           MOVE WS-FMT-DOB-LEN TO WS-DATE-LEN
           PERFORM PARSE-DATE
           IF WS-PARSE-OK = 0
               EXIT PARAGRAPH
           END-IF
           MOVE WS-PARSED-YEAR TO WS-DOB-YEAR
           MOVE WS-PARSED-MONTH TO WS-DOB-MONTH
           MOVE WS-PARSED-DAY TO WS-DOB-DAY

           *> Validate as-of
           IF FUNCTION TRIM(WS-FMT-AS-OF) = SPACES
               PERFORM DEFAULT-AS-OF-TODAY
           END-IF
           MOVE WS-FMT-AS-OF TO WS-DATE-STR
           MOVE WS-FMT-AS-OF-LEN TO WS-DATE-LEN
           PERFORM PARSE-DATE
           IF WS-PARSE-OK = 0
               EXIT PARAGRAPH
           END-IF
           MOVE WS-PARSED-YEAR TO WS-REF-YEAR
           MOVE WS-PARSED-MONTH TO WS-REF-MONTH
           MOVE WS-PARSED-DAY TO WS-REF-DAY

           *> Calculate diff
           MOVE WS-DOB-YEAR TO WS-JD-CALC-YEAR
           MOVE WS-DOB-MONTH TO WS-JD-CALC-MONTH
           MOVE WS-DOB-DAY TO WS-JD-CALC-DAY
           PERFORM CALC-JULIAN-DAY
           MOVE WS-JD-CALC-RESULT TO WS-JD1

           MOVE WS-REF-YEAR TO WS-JD-CALC-YEAR
           MOVE WS-REF-MONTH TO WS-JD-CALC-MONTH
           MOVE WS-REF-DAY TO WS-JD-CALC-DAY
           PERFORM CALC-JULIAN-DAY
           MOVE WS-JD-CALC-RESULT TO WS-JD2

           COMPUTE WS-DIFF-DAYS = WS-JD2 - WS-JD1
           IF WS-DIFF-DAYS < 0
               EXIT PARAGRAPH
           END-IF

           *> Calculate months
           MOVE WS-REF-YEAR TO WS-DIM-YEAR
           MOVE WS-REF-MONTH TO WS-DIM-MONTH
           PERFORM CALC-DAYS-IN-MONTH
           MOVE WS-DIM-RESULT TO WS-LAST-DAY

           IF WS-DOB-DAY < WS-LAST-DAY
               MOVE WS-DOB-DAY TO WS-CLAMPED-BDAY
           ELSE
               MOVE WS-LAST-DAY TO WS-CLAMPED-BDAY
           END-IF

           COMPUTE WS-MONTHS =
               (WS-REF-YEAR - WS-DOB-YEAR) * 12
               + (WS-REF-MONTH - WS-DOB-MONTH)
           IF WS-REF-DAY < WS-CLAMPED-BDAY
               SUBTRACT 1 FROM WS-MONTHS
           END-IF

           IF WS-MONTHS > PT-MAX-AGE-MONTHS
               EXIT PARAGRAPH
           END-IF

           *> Determine stage and select label+f-label
           EVALUATE TRUE
               WHEN WS-MONTHS < 2
                   MOVE WS-ACT-NEWBORN-LABEL TO WS-PART1
                   MOVE WS-ACT-NEWBORN-F-LABEL TO WS-PART2
               WHEN WS-MONTHS < 12
                   MOVE WS-ACT-INFANT-LABEL TO WS-PART1
                   MOVE WS-ACT-INFANT-F-LABEL TO WS-PART2
               WHEN WS-MONTHS < 36
                   MOVE WS-ACT-TODDLER-LABEL TO WS-PART1
                   MOVE WS-ACT-TODDLER-F-LABEL TO WS-PART2
               WHEN WS-MONTHS < 156
                   MOVE WS-ACT-CHILD-LABEL TO WS-PART1
                   MOVE WS-ACT-CHILD-F-LABEL TO WS-PART2
               WHEN WS-MONTHS < 216
                   MOVE WS-ACT-TEENAGER-LABEL TO WS-PART1
                   MOVE WS-ACT-TEENAGER-F-LABEL TO WS-PART2
               WHEN OTHER
                   MOVE WS-ACT-ADULT-LABEL TO WS-PART1
                   MOVE WS-ACT-ADULT-F-LABEL TO WS-PART2
           END-EVALUATE

           *> Apply gender
           IF WS-FMT-GENDER = "f"
               AND FUNCTION TRIM(WS-PART2) NOT = SPACES
               MOVE WS-PART2 TO WS-STAGE-RESULT
           ELSE
               MOVE WS-PART1 TO WS-STAGE-RESULT
           END-IF
           .

*> ============================================================
*> COPY-LOCALE-TO-EFFECTIVE: Copy WS-ACT-* to WS-EFF-*
*> ============================================================
       COPY-LOCALE-TO-EFFECTIVE.
           MOVE WS-ACT-DAY-HAS-SIMPLE TO WS-EFF-DAY-HAS-SIMPLE
           MOVE WS-ACT-DAY-SIMPLE TO WS-EFF-DAY-SIMPLE
           PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
               MOVE WS-ACT-DAY-HAS-FORM(WS-I)
                   TO WS-EFF-DAY-HAS-FORM(WS-I)
               MOVE WS-ACT-DAY-FORM(WS-I)
                   TO WS-EFF-DAY-FORM(WS-I)
           END-PERFORM
           MOVE WS-ACT-WEEK-HAS-SIMPLE TO WS-EFF-WEEK-HAS-SIMPLE
           MOVE WS-ACT-WEEK-SIMPLE TO WS-EFF-WEEK-SIMPLE
           PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
               MOVE WS-ACT-WEEK-HAS-FORM(WS-I)
                   TO WS-EFF-WEEK-HAS-FORM(WS-I)
               MOVE WS-ACT-WEEK-FORM(WS-I)
                   TO WS-EFF-WEEK-FORM(WS-I)
           END-PERFORM
           MOVE WS-ACT-MONTH-HAS-SIMPLE
               TO WS-EFF-MONTH-HAS-SIMPLE
           MOVE WS-ACT-MONTH-SIMPLE TO WS-EFF-MONTH-SIMPLE
           PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
               MOVE WS-ACT-MONTH-HAS-FORM(WS-I)
                   TO WS-EFF-MONTH-HAS-FORM(WS-I)
               MOVE WS-ACT-MONTH-FORM(WS-I)
                   TO WS-EFF-MONTH-FORM(WS-I)
           END-PERFORM
           MOVE WS-ACT-YEAR-HAS-SIMPLE TO WS-EFF-YEAR-HAS-SIMPLE
           MOVE WS-ACT-YEAR-SIMPLE TO WS-EFF-YEAR-SIMPLE
           PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
               MOVE WS-ACT-YEAR-HAS-FORM(WS-I)
                   TO WS-EFF-YEAR-HAS-FORM(WS-I)
               MOVE WS-ACT-YEAR-FORM(WS-I)
                   TO WS-EFF-YEAR-FORM(WS-I)
           END-PERFORM
           MOVE WS-ACT-HALF TO WS-EFF-HALF
           MOVE WS-ACT-DELIMITER TO WS-EFF-DELIMITER
           MOVE WS-ACT-DELIM-LEN TO WS-EFF-DELIM-LEN
           MOVE WS-ACT-JUST-BORN TO WS-EFF-JUST-BORN
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
           IF WS-ACT-SHORT-HAS-HALF = 1
               MOVE WS-ACT-SHORT-HALF TO WS-EFF-HALF
           END-IF
           IF WS-ACT-SHORT-HAS-DELIM = 1
               MOVE WS-ACT-SHORT-DELIM TO WS-EFF-DELIMITER
               MOVE WS-ACT-SHORT-DELIM-LEN TO WS-EFF-DELIM-LEN
           END-IF
           IF WS-ACT-SHORT-HAS-JUST-BORN = 1
               MOVE WS-ACT-SHORT-JUST-BORN TO WS-EFF-JUST-BORN
           END-IF
           .

       APPLY-COMPACT-OVERRIDE.
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
           IF WS-ACT-COMPACT-HAS-HALF = 1
               MOVE WS-ACT-COMPACT-HALF TO WS-EFF-HALF
           END-IF
           IF WS-ACT-COMPACT-HAS-DELIM = 1
               MOVE WS-ACT-COMPACT-DELIM TO WS-EFF-DELIMITER
               MOVE WS-ACT-COMPACT-DELIM-LEN TO WS-EFF-DELIM-LEN
           END-IF
           IF WS-ACT-COMPACT-HAS-JUST-BORN = 1
               MOVE WS-ACT-COMPACT-JUST-BORN TO WS-EFF-JUST-BORN
           END-IF
           .

*> ============================================================
*> RESOLVE-UNIT: Resolve a count+unit into a string
*> Input:  WS-RU-COUNT, WS-RU-HALF, WS-AUF-* (unit forms)
*> Output: WS-RU-RESULT
*> ============================================================
       RESOLVE-UNIT.
           MOVE SPACES TO WS-RU-RESULT

           *> Convert count to string
           MOVE WS-RU-COUNT TO WS-NUM-TO-STR-INPUT
           PERFORM NUM-TO-STR
           MOVE WS-NUM-TO-STR-RESULT TO WS-RU-BASE-N

           *> Apply {n}-style half marker to the number
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

           *> Select template
           MOVE SPACES TO WS-RU-TMPL
           IF WS-AUF-HAS-SIMPLE = 1
               MOVE WS-AUF-SIMPLE TO WS-RU-TMPL
           ELSE
               MOVE WS-RU-COUNT TO WS-PLURAL-N
               PERFORM APPLY-PLURAL-RULE
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

           *> Replace {n} in template with n-str
           MOVE WS-RU-TMPL TO WS-REPLACE-SRC
           MOVE "{n}" TO WS-REPLACE-MARKER
           MOVE FUNCTION TRIM(WS-RU-N-STR) TO WS-REPLACE-REPL
           PERFORM REPLACE-FIRST
           MOVE WS-REPLACE-RESULT TO WS-RU-RESULT

           *> Apply {0}-style half marker (wraps the whole result)
           IF FUNCTION TRIM(WS-RU-HALF) NOT = SPACES
               MOVE WS-RU-HALF TO WS-REPLACE-SRC
               MOVE "{0}" TO WS-REPLACE-MARKER
               MOVE FUNCTION TRIM(WS-RU-RESULT) TO WS-REPLACE-REPL
               PERFORM REPLACE-FIRST
               IF WS-REPLACE-POS > 0
                   MOVE WS-REPLACE-RESULT TO WS-RU-RESULT
               END-IF
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

           *> WS-REPLACE-POS is now chars before marker
           *> If it equals src-len, marker was not found
           IF WS-REPLACE-POS >= WS-REPLACE-SRC-LEN
               MOVE 0 TO WS-REPLACE-POS
               MOVE WS-REPLACE-SRC TO WS-REPLACE-RESULT
               EXIT PARAGRAPH
           END-IF

           *> Build result: before + replacement + after
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

           *> Set pos to 1-based position for caller
           ADD 1 TO WS-REPLACE-POS
           .

*> ============================================================
*> PARSE-DATE: Parse exactly YYYY-MM-DD naming a real calendar day
*> Input:  WS-DATE-STR, WS-DATE-LEN (0 = length without trailing blanks)
*> Output: WS-PARSED-YEAR, WS-PARSED-MONTH, WS-PARSED-DAY,
*>         WS-PARSE-OK (1=success, 0=failure)
*> ============================================================
       PARSE-DATE.
           MOVE 0 TO WS-PARSE-OK
           IF WS-DATE-LEN = 0
               MOVE FUNCTION STORED-CHAR-LENGTH(WS-DATE-STR)
                   TO WS-DATE-LEN
           END-IF
           IF WS-DATE-LEN NOT = 10
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
           MOVE WS-PARSED-YEAR TO WS-DIM-YEAR
           MOVE WS-PARSED-MONTH TO WS-DIM-MONTH
           PERFORM CALC-DAYS-IN-MONTH
           IF WS-PARSED-DAY < 1 OR WS-PARSED-DAY > WS-DIM-RESULT
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
*> CALC-DAYS-IN-MONTH: Get days in a given month/year
*> Input:  WS-DIM-YEAR, WS-DIM-MONTH
*> Output: WS-DIM-RESULT
*> ============================================================
       CALC-DAYS-IN-MONTH.
           MOVE WS-MONTH-DAYS(WS-DIM-MONTH) TO WS-DIM-RESULT
           IF WS-DIM-MONTH = 2
               PERFORM CHECK-LEAP-YEAR
               IF WS-IS-LEAP = 1
                   MOVE 29 TO WS-DIM-RESULT
               END-IF
           END-IF
           .

*> ============================================================
*> CHECK-LEAP-YEAR: Check if WS-DIM-YEAR is a leap year
*> Output: WS-IS-LEAP (1=leap, 0=not)
*> ============================================================
       CHECK-LEAP-YEAR.
           MOVE 0 TO WS-IS-LEAP
           DIVIDE WS-DIM-YEAR BY 4
               GIVING WS-LEAP-REM4 REMAINDER WS-LEAP-REM4
           IF WS-LEAP-REM4 = 0
               DIVIDE WS-DIM-YEAR BY 100
                   GIVING WS-LEAP-REM100
                   REMAINDER WS-LEAP-REM100
               IF WS-LEAP-REM100 NOT = 0
                   MOVE 1 TO WS-IS-LEAP
               ELSE
                   DIVIDE WS-DIM-YEAR BY 400
                       GIVING WS-LEAP-REM400
                       REMAINDER WS-LEAP-REM400
                   IF WS-LEAP-REM400 = 0
                       MOVE 1 TO WS-IS-LEAP
                   END-IF
               END-IF
           END-IF
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

*> ============================================================
*> DEFAULT-AS-OF-TODAY: a blank as-of means today's local date
*> Output: WS-FMT-AS-OF (YYYY-MM-DD); length 0 means trimmed length
*> ============================================================
       DEFAULT-AS-OF-TODAY.
           MOVE FUNCTION CURRENT-DATE TO WS-NOW-STAMP
           MOVE SPACES TO WS-FMT-AS-OF
           STRING WS-NOW-STAMP(1:4) "-" WS-NOW-STAMP(5:2) "-"
               WS-NOW-STAMP(7:2)
               DELIMITED BY SIZE
               INTO WS-FMT-AS-OF
           END-STRING
           MOVE 0 TO WS-FMT-AS-OF-LEN
           .
