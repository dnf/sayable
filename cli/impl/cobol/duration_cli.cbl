       IDENTIFICATION DIVISION.
       PROGRAM-ID. DURATION-CLI.

       DATA DIVISION.
       WORKING-STORAGE SECTION.

      *> CLI argument handling
       01 WS-ARG-COUNT         PIC 9(4).
       01 WS-ARG-VAL           PIC X(256).
       01 WS-CMD               PIC X(20).
       01 WS-POS1              PIC X(256).
       01 WS-POS1-SET          PIC 9 VALUE 0.
       01 WS-POS2              PIC X(256).
       01 WS-POS2-SET          PIC 9 VALUE 0.
       01 WS-OPT-LOCALE        PIC X(8) VALUE "en".
       01 WS-OPT-AS-OF         PIC X(30).
       01 WS-OPT-AS-OF-SET     PIC 9 VALUE 0.
       01 WS-OPT-COMPACTNESS   PIC 9 VALUE 0.
       01 WS-ARG-IDX           PIC 9(4).
       01 WS-STOP-OPTS         PIC 9 VALUE 0.

      *> Duration value parsing
       01 WS-DUR-IS-INT        PIC 9.
       01 WS-DUR-IS-NEG        PIC 9.
       01 WS-DUR-LEN           PIC 9(4).
       01 WS-DUR-CHR           PIC X(1).
       01 WS-DUR-IDX           PIC 9(4).
       01 WS-DUR-VALUE         PIC S9(12).
       01 WS-DUR-DIGIT         PIC 9.

       COPY "duration/impl/cobol/src/Types.cbl".

       PROCEDURE DIVISION.
       MAIN-PROGRAM.
           ACCEPT WS-ARG-COUNT FROM ARGUMENT-NUMBER
           IF WS-ARG-COUNT < 1
               DISPLAY "error: missing command" UPON SYSERR
               MOVE 2 TO RETURN-CODE
               STOP RUN
           END-IF

           DISPLAY 1 UPON ARGUMENT-NUMBER
           ACCEPT WS-CMD FROM ARGUMENT-VALUE

           MOVE 2 TO WS-ARG-IDX
           PERFORM UNTIL WS-ARG-IDX > WS-ARG-COUNT
               DISPLAY WS-ARG-IDX UPON ARGUMENT-NUMBER
               ACCEPT WS-ARG-VAL FROM ARGUMENT-VALUE

               IF WS-STOP-OPTS = 0
                   AND FUNCTION TRIM(WS-ARG-VAL) = "--"
                   MOVE 1 TO WS-STOP-OPTS
                   ADD 1 TO WS-ARG-IDX
                   PERFORM UNTIL WS-ARG-IDX > WS-ARG-COUNT
                       DISPLAY WS-ARG-IDX
                           UPON ARGUMENT-NUMBER
                       ACCEPT WS-ARG-VAL FROM ARGUMENT-VALUE
                       IF WS-POS1-SET = 0
                           MOVE WS-ARG-VAL TO WS-POS1
                           MOVE 1 TO WS-POS1-SET
                       ELSE
                           IF WS-POS2-SET = 0
                               MOVE WS-ARG-VAL TO WS-POS2
                               MOVE 1 TO WS-POS2-SET
                           END-IF
                       END-IF
                       ADD 1 TO WS-ARG-IDX
                   END-PERFORM
               END-IF

               IF WS-STOP-OPTS = 0
                   AND WS-ARG-VAL(1:1) = "-"
                   AND FUNCTION LENGTH(FUNCTION TRIM(WS-ARG-VAL))
                       > 1
                   EVALUATE FUNCTION TRIM(WS-ARG-VAL)
                       WHEN "-l"
                       WHEN "--locale"
                           ADD 1 TO WS-ARG-IDX
                           IF WS-ARG-IDX > WS-ARG-COUNT
                               DISPLAY "error: '--locale' requ"
                                   "ires a value" UPON SYSERR
                               MOVE 2 TO RETURN-CODE
                               STOP RUN
                           END-IF
                           DISPLAY WS-ARG-IDX
                               UPON ARGUMENT-NUMBER
                           ACCEPT WS-OPT-LOCALE
                               FROM ARGUMENT-VALUE
                       WHEN "-d"
                       WHEN "--as-of"
                           ADD 1 TO WS-ARG-IDX
                           IF WS-ARG-IDX > WS-ARG-COUNT
                               DISPLAY "error: '--as-of' requ"
                                   "ires a value" UPON SYSERR
                               MOVE 2 TO RETURN-CODE
                               STOP RUN
                           END-IF
                           DISPLAY WS-ARG-IDX
                               UPON ARGUMENT-NUMBER
                           ACCEPT WS-OPT-AS-OF
                               FROM ARGUMENT-VALUE
                           MOVE 1 TO WS-OPT-AS-OF-SET
                       WHEN "--short"
                           MOVE 1 TO WS-OPT-COMPACTNESS
                       WHEN "--compact"
                           MOVE 2 TO WS-OPT-COMPACTNESS
                       WHEN OTHER
                           DISPLAY "error: unknown option '"
                               FUNCTION TRIM(WS-ARG-VAL)
                               "'" UPON SYSERR
                           DISPLAY
                               "Run 'sayable help' for usage."
                               UPON SYSERR
                           MOVE 2 TO RETURN-CODE
                           STOP RUN
                   END-EVALUATE
               ELSE
                   IF WS-POS1-SET = 0
                       MOVE WS-ARG-VAL TO WS-POS1
                       MOVE 1 TO WS-POS1-SET
                   ELSE
                       IF WS-POS2-SET = 0
                           MOVE WS-ARG-VAL TO WS-POS2
                           MOVE 1 TO WS-POS2-SET
                       END-IF
                   END-IF
               END-IF
               ADD 1 TO WS-ARG-IDX
           END-PERFORM

           EVALUATE FUNCTION TRIM(WS-CMD)
               WHEN "duration"
                   PERFORM CMD-DURATION
               WHEN "since"
                   PERFORM CMD-SINCE
               WHEN "until"
                   PERFORM CMD-UNTIL
               WHEN OTHER
                   DISPLAY "error: unknown command '"
                       FUNCTION TRIM(WS-CMD) "'" UPON SYSERR
                   DISPLAY "Run 'sayable help' for usage."
                       UPON SYSERR
                   MOVE 2 TO RETURN-CODE
           END-EVALUATE
           STOP RUN.

       CMD-DURATION.
           IF WS-POS1-SET = 0
               DISPLAY "error: duration requires a value "
                   "argument" UPON SYSERR
               DISPLAY "Run 'sayable help' for usage."
                   UPON SYSERR
               MOVE 2 TO RETURN-CODE
               EXIT PARAGRAPH
           END-IF

           IF FUNCTION TRIM(WS-POS1) = "null"
               MOVE 1 TO RETURN-CODE
               EXIT PARAGRAPH
           END-IF

           MOVE WS-OPT-LOCALE TO WS-LOOKUP-CODE
           PERFORM GET-LOCALE
           IF WS-LOOKUP-FOUND = 0
               DISPLAY "error: unknown locale '"
                   FUNCTION TRIM(WS-OPT-LOCALE) "'" UPON SYSERR
               DISPLAY "Run 'sayable help' for usage."
                   UPON SYSERR
               MOVE 2 TO RETURN-CODE
               EXIT PARAGRAPH
           END-IF

           MOVE WS-OPT-COMPACTNESS TO WS-FMT-COMPACTNESS

      *>   Detect integer vs timestamp
           PERFORM CHECK-IS-INTEGER

           IF WS-DUR-IS-INT = 1
      *>       Seconds mode (positive integer)
               PERFORM PARSE-INT-VALUE
               MOVE WS-DUR-VALUE TO WS-FMT-SECONDS
               PERFORM FORMAT-DURATION
           ELSE
               IF WS-DUR-IS-NEG = 1
      *>           Negative integer
                   PERFORM PARSE-INT-VALUE
                   MOVE WS-DUR-VALUE TO WS-FMT-SECONDS
                   PERFORM FORMAT-DURATION
               ELSE
      *>           Timestamp mode
                   IF WS-POS2-SET = 0
                       DISPLAY "error: duration with timesta"
                           "mps requires start and end "
                           "arguments" UPON SYSERR
                       DISPLAY "Run 'sayable help' for usage"
                           "." UPON SYSERR
                       MOVE 2 TO RETURN-CODE
                       EXIT PARAGRAPH
                   END-IF
                   IF FUNCTION TRIM(WS-POS2) = "null"
                       MOVE 1 TO RETURN-CODE
                       EXIT PARAGRAPH
                   END-IF
                   MOVE WS-POS1 TO WS-FMT-START
                   MOVE WS-POS2 TO WS-FMT-END
                   PERFORM FORMAT-DURATION-ISO
               END-IF
           END-IF

           IF FUNCTION TRIM(WS-FORMAT-RESULT) = SPACES
               MOVE 1 TO RETURN-CODE
           ELSE
               DISPLAY FUNCTION TRIM(WS-FORMAT-RESULT)
               MOVE 0 TO RETURN-CODE
           END-IF
           .

       CMD-SINCE.
           IF WS-POS1-SET = 0
               DISPLAY "error: since requires a start "
                   "timestamp argument" UPON SYSERR
               DISPLAY "Run 'sayable help' for usage."
                   UPON SYSERR
               MOVE 2 TO RETURN-CODE
               EXIT PARAGRAPH
           END-IF

           IF FUNCTION TRIM(WS-POS1) = "null"
               MOVE 1 TO RETURN-CODE
               EXIT PARAGRAPH
           END-IF

           IF WS-OPT-AS-OF-SET = 0
               DISPLAY "error: since requires "
                   "--as-of / -d option" UPON SYSERR
               DISPLAY "Run 'sayable help' for usage."
                   UPON SYSERR
               MOVE 2 TO RETURN-CODE
               EXIT PARAGRAPH
           END-IF

           IF FUNCTION TRIM(WS-OPT-AS-OF) = "null"
               MOVE 1 TO RETURN-CODE
               EXIT PARAGRAPH
           END-IF

           MOVE WS-OPT-LOCALE TO WS-LOOKUP-CODE
           PERFORM GET-LOCALE
           IF WS-LOOKUP-FOUND = 0
               DISPLAY "error: unknown locale '"
                   FUNCTION TRIM(WS-OPT-LOCALE) "'" UPON SYSERR
               DISPLAY "Run 'sayable help' for usage."
                   UPON SYSERR
               MOVE 2 TO RETURN-CODE
               EXIT PARAGRAPH
           END-IF

           MOVE WS-OPT-COMPACTNESS TO WS-FMT-COMPACTNESS
           MOVE WS-POS1 TO WS-FMT-START
           MOVE WS-OPT-AS-OF TO WS-FMT-AS-OF
           PERFORM FORMAT-SINCE

           IF FUNCTION TRIM(WS-FORMAT-RESULT) = SPACES
               MOVE 1 TO RETURN-CODE
           ELSE
               DISPLAY FUNCTION TRIM(WS-FORMAT-RESULT)
               MOVE 0 TO RETURN-CODE
           END-IF
           .

       CMD-UNTIL.
           IF WS-POS1-SET = 0
               DISPLAY "error: until requires a target "
                   "timestamp argument" UPON SYSERR
               DISPLAY "Run 'sayable help' for usage."
                   UPON SYSERR
               MOVE 2 TO RETURN-CODE
               EXIT PARAGRAPH
           END-IF

           IF FUNCTION TRIM(WS-POS1) = "null"
               MOVE 1 TO RETURN-CODE
               EXIT PARAGRAPH
           END-IF

           IF WS-OPT-AS-OF-SET = 0
               DISPLAY "error: until requires "
                   "--as-of / -d option" UPON SYSERR
               DISPLAY "Run 'sayable help' for usage."
                   UPON SYSERR
               MOVE 2 TO RETURN-CODE
               EXIT PARAGRAPH
           END-IF

           IF FUNCTION TRIM(WS-OPT-AS-OF) = "null"
               MOVE 1 TO RETURN-CODE
               EXIT PARAGRAPH
           END-IF

           MOVE WS-OPT-LOCALE TO WS-LOOKUP-CODE
           PERFORM GET-LOCALE
           IF WS-LOOKUP-FOUND = 0
               DISPLAY "error: unknown locale '"
                   FUNCTION TRIM(WS-OPT-LOCALE) "'" UPON SYSERR
               DISPLAY "Run 'sayable help' for usage."
                   UPON SYSERR
               MOVE 2 TO RETURN-CODE
               EXIT PARAGRAPH
           END-IF

           MOVE WS-OPT-COMPACTNESS TO WS-FMT-COMPACTNESS
           MOVE WS-POS1 TO WS-FMT-TARGET
           MOVE WS-OPT-AS-OF TO WS-FMT-AS-OF
           PERFORM FORMAT-UNTIL

           IF FUNCTION TRIM(WS-FORMAT-RESULT) = SPACES
               MOVE 1 TO RETURN-CODE
           ELSE
               DISPLAY FUNCTION TRIM(WS-FORMAT-RESULT)
               MOVE 0 TO RETURN-CODE
           END-IF
           .

      *> Check if WS-POS1 is an integer (all digits)
       CHECK-IS-INTEGER.
           MOVE 0 TO WS-DUR-IS-INT
           MOVE 0 TO WS-DUR-IS-NEG
           MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-POS1))
               TO WS-DUR-LEN

           IF WS-DUR-LEN = 0
               EXIT PARAGRAPH
           END-IF

           MOVE 1 TO WS-DUR-IDX

      *>   Check for leading minus sign
           MOVE WS-POS1(1:1) TO WS-DUR-CHR
           IF WS-DUR-CHR = "-"
               IF WS-DUR-LEN < 2
                   EXIT PARAGRAPH
               END-IF
               MOVE 2 TO WS-DUR-IDX
               MOVE 1 TO WS-DUR-IS-NEG
           END-IF

      *>   Check remaining chars are digits
           PERFORM UNTIL WS-DUR-IDX > WS-DUR-LEN
               MOVE WS-POS1(WS-DUR-IDX:1) TO WS-DUR-CHR
               IF WS-DUR-CHR < "0" OR WS-DUR-CHR > "9"
                   MOVE 0 TO WS-DUR-IS-NEG
                   EXIT PARAGRAPH
               END-IF
               ADD 1 TO WS-DUR-IDX
           END-PERFORM

           IF WS-DUR-IS-NEG = 0
               MOVE 1 TO WS-DUR-IS-INT
           END-IF
           .

      *> Parse integer value from WS-POS1
       PARSE-INT-VALUE.
           MOVE 0 TO WS-DUR-VALUE
           MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-POS1))
               TO WS-DUR-LEN
           MOVE 1 TO WS-DUR-IDX

      *>   Skip minus sign
           IF WS-POS1(1:1) = "-"
               MOVE 2 TO WS-DUR-IDX
           END-IF

           PERFORM UNTIL WS-DUR-IDX > WS-DUR-LEN
               MOVE WS-POS1(WS-DUR-IDX:1) TO WS-DUR-CHR
               COMPUTE WS-DUR-DIGIT =
                   FUNCTION ORD(WS-DUR-CHR) - FUNCTION ORD("0")
               COMPUTE WS-DUR-VALUE =
                   WS-DUR-VALUE * 10 + WS-DUR-DIGIT
               ADD 1 TO WS-DUR-IDX
           END-PERFORM

           IF WS-POS1(1:1) = "-"
               MULTIPLY -1 BY WS-DUR-VALUE
           END-IF
           .

       COPY "duration/impl/cobol/src/SayableDuration.cbl".
       COPY "duration/impl/cobol/src/locales/Locales.cbl".
