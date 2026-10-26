       IDENTIFICATION DIVISION.
       PROGRAM-ID. DURATION-CLI IS INITIAL.
      *> INITIAL: every CALL starts from fresh WORKING-STORAGE, so
      *> options and locale fields never leak between REPL requests.

       DATA DIVISION.
       WORKING-STORAGE SECTION.

      *> CLI argument handling
       01 WS-ARG-COUNT         PIC 9(4).
       01 WS-EMIT-TEXT         PIC X(1024).
       01 WS-ARG-VAL           PIC X(256).
       01 WS-CMD               PIC X(20).
       01 WS-POS1              PIC X(256).
       01 WS-POS1-LEN          PIC 9(4) VALUE 0.
       01 WS-POS1-SET          PIC 9 VALUE 0.
       01 WS-POS2              PIC X(256).
       01 WS-POS2-LEN          PIC 9(4) VALUE 0.
       01 WS-POS2-SET          PIC 9 VALUE 0.
       01 WS-OPT-LOCALE        PIC X(8) VALUE "en".
       01 WS-OPT-AS-OF         PIC X(256).
       01 WS-OPT-AS-OF-LEN     PIC 9(4) VALUE 0.
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
       01 WS-DUR-MAX-DIGITS    PIC 99 VALUE 12.
       01 WS-DUR-DIGIT         PIC 9.

       COPY "duration/impl/cobol/src/Types.cbl".

       LINKAGE SECTION.
       COPY "cli/impl/cobol/request.cpy".

       PROCEDURE DIVISION USING SAYABLE-REQUEST.
       MAIN-PROGRAM.
           MOVE REQ-ARG-COUNT TO WS-ARG-COUNT
           IF WS-ARG-COUNT < 1
               DISPLAY "error: missing command" UPON SYSERR
               MOVE 2 TO REQ-EXIT-CODE
               GOBACK
           END-IF

           MOVE REQ-ARG(1) TO WS-CMD

           MOVE 2 TO WS-ARG-IDX
           PERFORM UNTIL WS-ARG-IDX > WS-ARG-COUNT
               MOVE REQ-ARG(WS-ARG-IDX) TO WS-ARG-VAL

               IF WS-STOP-OPTS = 0
                   AND FUNCTION TRIM(WS-ARG-VAL) = "--"
                   MOVE 1 TO WS-STOP-OPTS
                   ADD 1 TO WS-ARG-IDX
                   PERFORM UNTIL WS-ARG-IDX > WS-ARG-COUNT
                       MOVE REQ-ARG(WS-ARG-IDX) TO WS-ARG-VAL
                       IF WS-POS1-SET = 0
                           MOVE WS-ARG-VAL TO WS-POS1
                           MOVE FUNCTION MIN(REQ-ARG-LEN(WS-ARG-IDX), 9999)
                               TO WS-POS1-LEN
                           MOVE 1 TO WS-POS1-SET
                       ELSE
                           IF WS-POS2-SET = 0
                               MOVE WS-ARG-VAL TO WS-POS2
                               MOVE FUNCTION MIN(REQ-ARG-LEN(WS-ARG-IDX), 9999)
                                   TO WS-POS2-LEN
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
                               MOVE 2 TO REQ-EXIT-CODE
                               GOBACK
                           END-IF
                           MOVE REQ-ARG(WS-ARG-IDX) TO WS-OPT-LOCALE
                           PERFORM REJECT-UNSTORABLE-LOCALE
                       WHEN "-d"
                       WHEN "--as-of"
                           ADD 1 TO WS-ARG-IDX
                           IF WS-ARG-IDX > WS-ARG-COUNT
                               DISPLAY "error: '--as-of' requ"
                                   "ires a value" UPON SYSERR
                               MOVE 2 TO REQ-EXIT-CODE
                               GOBACK
                           END-IF
                           MOVE REQ-ARG(WS-ARG-IDX) TO WS-OPT-AS-OF
                           MOVE FUNCTION MIN(REQ-ARG-LEN(WS-ARG-IDX), 9999)
                               TO WS-OPT-AS-OF-LEN
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
                           MOVE 2 TO REQ-EXIT-CODE
                           GOBACK
                   END-EVALUATE
               ELSE
                   IF WS-POS1-SET = 0
                       MOVE WS-ARG-VAL TO WS-POS1
                       MOVE FUNCTION MIN(REQ-ARG-LEN(WS-ARG-IDX), 9999)
                           TO WS-POS1-LEN
                       MOVE 1 TO WS-POS1-SET
                   ELSE
                       IF WS-POS2-SET = 0
                           MOVE WS-ARG-VAL TO WS-POS2
                           MOVE FUNCTION MIN(REQ-ARG-LEN(WS-ARG-IDX), 9999)
                               TO WS-POS2-LEN
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
                   MOVE 2 TO REQ-EXIT-CODE
           END-EVALUATE
           GOBACK.

       CMD-DURATION.
           IF WS-POS1-SET = 0
               DISPLAY "error: duration requires a value "
                   "argument" UPON SYSERR
               DISPLAY "Run 'sayable help' for usage."
                   UPON SYSERR
               MOVE 2 TO REQ-EXIT-CODE
               EXIT PARAGRAPH
           END-IF

           IF (WS-POS1-LEN = 4 AND WS-POS1(1:4) = "null")
               MOVE 1 TO REQ-EXIT-CODE
               EXIT PARAGRAPH
           END-IF

           MOVE WS-OPT-LOCALE TO WS-LOOKUP-CODE
           PERFORM GET-LOCALE
           IF WS-LOOKUP-FOUND = 0
               DISPLAY "error: unknown locale '"
                   FUNCTION TRIM(WS-OPT-LOCALE) "'" UPON SYSERR
               DISPLAY "Run 'sayable help' for usage."
                   UPON SYSERR
               MOVE 2 TO REQ-EXIT-CODE
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
                       MOVE 2 TO REQ-EXIT-CODE
                       EXIT PARAGRAPH
                   END-IF
                   IF (WS-POS2-LEN = 4 AND WS-POS2(1:4) = "null")
                       MOVE 1 TO REQ-EXIT-CODE
                       EXIT PARAGRAPH
                   END-IF
                   MOVE WS-POS1 TO WS-FMT-START
                   MOVE WS-POS1-LEN TO WS-FMT-START-LEN
                   MOVE WS-POS2 TO WS-FMT-END
                   MOVE WS-POS2-LEN TO WS-FMT-END-LEN
                   PERFORM FORMAT-DURATION-ISO
               END-IF
           END-IF

           IF FUNCTION TRIM(WS-FORMAT-RESULT) = SPACES
               MOVE 1 TO REQ-EXIT-CODE
           ELSE
               MOVE WS-FORMAT-RESULT TO WS-EMIT-TEXT
               PERFORM EMIT-LINE
               MOVE 0 TO REQ-EXIT-CODE
           END-IF
           .

       CMD-SINCE.
           IF WS-POS1-SET = 0
               DISPLAY "error: since requires a start "
                   "timestamp argument" UPON SYSERR
               DISPLAY "Run 'sayable help' for usage."
                   UPON SYSERR
               MOVE 2 TO REQ-EXIT-CODE
               EXIT PARAGRAPH
           END-IF

           IF (WS-POS1-LEN = 4 AND WS-POS1(1:4) = "null")
               MOVE 1 TO REQ-EXIT-CODE
               EXIT PARAGRAPH
           END-IF

           IF WS-OPT-AS-OF-SET = 0
               DISPLAY "error: since requires "
                   "--as-of / -d option" UPON SYSERR
               DISPLAY "Run 'sayable help' for usage."
                   UPON SYSERR
               MOVE 2 TO REQ-EXIT-CODE
               EXIT PARAGRAPH
           END-IF

           IF (WS-OPT-AS-OF-LEN = 4 AND WS-OPT-AS-OF(1:4) = "null")
               MOVE 1 TO REQ-EXIT-CODE
               EXIT PARAGRAPH
           END-IF

           MOVE WS-OPT-LOCALE TO WS-LOOKUP-CODE
           PERFORM GET-LOCALE
           IF WS-LOOKUP-FOUND = 0
               DISPLAY "error: unknown locale '"
                   FUNCTION TRIM(WS-OPT-LOCALE) "'" UPON SYSERR
               DISPLAY "Run 'sayable help' for usage."
                   UPON SYSERR
               MOVE 2 TO REQ-EXIT-CODE
               EXIT PARAGRAPH
           END-IF

           MOVE WS-OPT-COMPACTNESS TO WS-FMT-COMPACTNESS
           MOVE WS-POS1 TO WS-FMT-START
           MOVE WS-POS1-LEN TO WS-FMT-START-LEN
           MOVE WS-OPT-AS-OF TO WS-FMT-AS-OF
           MOVE WS-OPT-AS-OF-LEN TO WS-FMT-AS-OF-LEN
           PERFORM FORMAT-SINCE

           IF FUNCTION TRIM(WS-FORMAT-RESULT) = SPACES
               MOVE 1 TO REQ-EXIT-CODE
           ELSE
               MOVE WS-FORMAT-RESULT TO WS-EMIT-TEXT
               PERFORM EMIT-LINE
               MOVE 0 TO REQ-EXIT-CODE
           END-IF
           .

       CMD-UNTIL.
           IF WS-POS1-SET = 0
               DISPLAY "error: until requires a target "
                   "timestamp argument" UPON SYSERR
               DISPLAY "Run 'sayable help' for usage."
                   UPON SYSERR
               MOVE 2 TO REQ-EXIT-CODE
               EXIT PARAGRAPH
           END-IF

           IF (WS-POS1-LEN = 4 AND WS-POS1(1:4) = "null")
               MOVE 1 TO REQ-EXIT-CODE
               EXIT PARAGRAPH
           END-IF

           IF WS-OPT-AS-OF-SET = 0
               DISPLAY "error: until requires "
                   "--as-of / -d option" UPON SYSERR
               DISPLAY "Run 'sayable help' for usage."
                   UPON SYSERR
               MOVE 2 TO REQ-EXIT-CODE
               EXIT PARAGRAPH
           END-IF

           IF (WS-OPT-AS-OF-LEN = 4 AND WS-OPT-AS-OF(1:4) = "null")
               MOVE 1 TO REQ-EXIT-CODE
               EXIT PARAGRAPH
           END-IF

           MOVE WS-OPT-LOCALE TO WS-LOOKUP-CODE
           PERFORM GET-LOCALE
           IF WS-LOOKUP-FOUND = 0
               DISPLAY "error: unknown locale '"
                   FUNCTION TRIM(WS-OPT-LOCALE) "'" UPON SYSERR
               DISPLAY "Run 'sayable help' for usage."
                   UPON SYSERR
               MOVE 2 TO REQ-EXIT-CODE
               EXIT PARAGRAPH
           END-IF

           MOVE WS-OPT-COMPACTNESS TO WS-FMT-COMPACTNESS
           MOVE WS-POS1 TO WS-FMT-TARGET
           MOVE WS-POS1-LEN TO WS-FMT-TARGET-LEN
           MOVE WS-OPT-AS-OF TO WS-FMT-AS-OF
           MOVE WS-OPT-AS-OF-LEN TO WS-FMT-AS-OF-LEN
           PERFORM FORMAT-UNTIL

           IF FUNCTION TRIM(WS-FORMAT-RESULT) = SPACES
               MOVE 1 TO REQ-EXIT-CODE
           ELSE
               MOVE WS-FORMAT-RESULT TO WS-EMIT-TEXT
               PERFORM EMIT-LINE
               MOVE 0 TO REQ-EXIT-CODE
           END-IF
           .

      *> Check if WS-POS1 is an integer (all digits)
       CHECK-IS-INTEGER.
           MOVE 0 TO WS-DUR-IS-INT
           MOVE 0 TO WS-DUR-IS-NEG
           MOVE WS-POS1-LEN TO WS-DUR-LEN

           IF WS-DUR-LEN = 0 OR WS-DUR-LEN > LENGTH OF WS-POS1
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

      *> Parse integer value from WS-POS1. More significant digits
      *> than WS-DUR-VALUE holds are far beyond the 500-year ceiling,
      *> so the value saturates instead of losing its high digits.
       PARSE-INT-VALUE.
           MOVE 0 TO WS-DUR-VALUE
           MOVE WS-POS1-LEN TO WS-DUR-LEN
           MOVE 1 TO WS-DUR-IDX

      *>   Skip minus sign and leading zeros
           IF WS-POS1(1:1) = "-"
               MOVE 2 TO WS-DUR-IDX
           END-IF
           PERFORM UNTIL WS-DUR-IDX >= WS-DUR-LEN
                   OR WS-POS1(WS-DUR-IDX:1) NOT = "0"
               ADD 1 TO WS-DUR-IDX
           END-PERFORM

           IF WS-DUR-LEN - WS-DUR-IDX + 1 > WS-DUR-MAX-DIGITS
               MOVE 999999999999 TO WS-DUR-VALUE
           ELSE
               PERFORM UNTIL WS-DUR-IDX > WS-DUR-LEN
                   MOVE WS-POS1(WS-DUR-IDX:1) TO WS-DUR-CHR
                   COMPUTE WS-DUR-DIGIT =
                       FUNCTION ORD(WS-DUR-CHR) - FUNCTION ORD("0")
                   COMPUTE WS-DUR-VALUE =
                       WS-DUR-VALUE * 10 + WS-DUR-DIGIT
                   ADD 1 TO WS-DUR-IDX
               END-PERFORM
           END-IF

           IF WS-POS1(1:1) = "-"
               MULTIPLY -1 BY WS-DUR-VALUE
           END-IF
           .

      *> A locale code longer than WS-OPT-LOCALE, or with trailing
      *> blanks, would match a real code once padded or cut; it names
      *> no locale.
       REJECT-UNSTORABLE-LOCALE.
           IF REQ-ARG-LEN(WS-ARG-IDX) > LENGTH OF WS-OPT-LOCALE
               OR REQ-ARG-LEN(WS-ARG-IDX) NOT =
                   FUNCTION STORED-CHAR-LENGTH(REQ-ARG(WS-ARG-IDX))
               MOVE "?" TO WS-OPT-LOCALE
           END-IF
           .

      *> Appends one stdout line to the response.
       EMIT-LINE.
           STRING FUNCTION TRIM(WS-EMIT-TEXT) X"0A"
               DELIMITED BY SIZE
               INTO REQ-OUTPUT WITH POINTER REQ-OUTPUT-PTR
           END-STRING
           .

       COPY "duration/impl/cobol/src/SayableDuration.cbl".
       COPY "duration/impl/cobol/src/locales/Locales.cbl".
