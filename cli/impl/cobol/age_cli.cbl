       IDENTIFICATION DIVISION.
       PROGRAM-ID. AGE-CLI IS INITIAL.
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
       01 WS-OPT-LOCALE        PIC X(8) VALUE "en".
       01 WS-OPT-AS-OF         PIC X(256).
       01 WS-OPT-AS-OF-LEN     PIC 9(4) VALUE 0.
       01 WS-OPT-AS-OF-SET     PIC 9 VALUE 0.
       01 WS-OPT-GENDER        PIC X(1).
       01 WS-OPT-GENDER-SET    PIC 9 VALUE 0.
       01 WS-OPT-COMPACTNESS   PIC 9 VALUE 0.
       01 WS-ARG-IDX           PIC 9(4).
       01 WS-STOP-OPTS         PIC 9 VALUE 0.
       01 WS-CLI-NULL-FLAG     PIC 9 VALUE 0.
       01 WS-CLI-EMPTY-FLAG    PIC 9 VALUE 0.
       01 WS-TODAY-INT         PIC 9(8).
       01 WS-TODAY-STR         PIC X(10).
       01 WS-TODAY-YYYY        PIC 9(4).
       01 WS-TODAY-MM          PIC 9(2).
       01 WS-TODAY-DD          PIC 9(2).

      *> Locale codes printed by `sayable locales`, in order.
       01 WS-LOCALE-CODE-VALUES.
          05 FILLER            PIC X(3) VALUE "af".
          05 FILLER            PIC X(3) VALUE "ak".
          05 FILLER            PIC X(3) VALUE "am".
          05 FILLER            PIC X(3) VALUE "ar".
          05 FILLER            PIC X(3) VALUE "ay".
          05 FILLER            PIC X(3) VALUE "az".
          05 FILLER            PIC X(3) VALUE "bci".
          05 FILLER            PIC X(3) VALUE "be".
          05 FILLER            PIC X(3) VALUE "bem".
          05 FILLER            PIC X(3) VALUE "bg".
          05 FILLER            PIC X(3) VALUE "bi".
          05 FILLER            PIC X(3) VALUE "bm".
          05 FILLER            PIC X(3) VALUE "bn".
          05 FILLER            PIC X(3) VALUE "br".
          05 FILLER            PIC X(3) VALUE "bs".
          05 FILLER            PIC X(3) VALUE "ca".
          05 FILLER            PIC X(3) VALUE "cak".
          05 FILLER            PIC X(3) VALUE "ceb".
          05 FILLER            PIC X(3) VALUE "cs".
          05 FILLER            PIC X(3) VALUE "cy".
          05 FILLER            PIC X(3) VALUE "da".
          05 FILLER            PIC X(3) VALUE "de".
          05 FILLER            PIC X(3) VALUE "din".
          05 FILLER            PIC X(3) VALUE "dje".
          05 FILLER            PIC X(3) VALUE "dv".
          05 FILLER            PIC X(3) VALUE "dyu".
          05 FILLER            PIC X(3) VALUE "dz".
          05 FILLER            PIC X(3) VALUE "ee".
          05 FILLER            PIC X(3) VALUE "el".
          05 FILLER            PIC X(3) VALUE "en".
          05 FILLER            PIC X(3) VALUE "es".
          05 FILLER            PIC X(3) VALUE "et".
          05 FILLER            PIC X(3) VALUE "eu".
          05 FILLER            PIC X(3) VALUE "fa".
          05 FILLER            PIC X(3) VALUE "fan".
          05 FILLER            PIC X(3) VALUE "ff".
          05 FILLER            PIC X(3) VALUE "fi".
          05 FILLER            PIC X(3) VALUE "fil".
          05 FILLER            PIC X(3) VALUE "fj".
          05 FILLER            PIC X(3) VALUE "fon".
          05 FILLER            PIC X(3) VALUE "fr".
          05 FILLER            PIC X(3) VALUE "ga".
          05 FILLER            PIC X(3) VALUE "gd".
          05 FILLER            PIC X(3) VALUE "gl".
          05 FILLER            PIC X(3) VALUE "gn".
          05 FILLER            PIC X(3) VALUE "gu".
          05 FILLER            PIC X(3) VALUE "gv".
          05 FILLER            PIC X(3) VALUE "ha".
          05 FILLER            PIC X(3) VALUE "he".
          05 FILLER            PIC X(3) VALUE "hi".
          05 FILLER            PIC X(3) VALUE "hmn".
          05 FILLER            PIC X(3) VALUE "hr".
          05 FILLER            PIC X(3) VALUE "ht".
          05 FILLER            PIC X(3) VALUE "hu".
          05 FILLER            PIC X(3) VALUE "hy".
          05 FILLER            PIC X(3) VALUE "id".
          05 FILLER            PIC X(3) VALUE "ig".
          05 FILLER            PIC X(3) VALUE "is".
          05 FILLER            PIC X(3) VALUE "it".
          05 FILLER            PIC X(3) VALUE "ja".
          05 FILLER            PIC X(3) VALUE "jv".
          05 FILLER            PIC X(3) VALUE "ka".
          05 FILLER            PIC X(3) VALUE "kbp".
          05 FILLER            PIC X(3) VALUE "kek".
          05 FILLER            PIC X(3) VALUE "ki".
          05 FILLER            PIC X(3) VALUE "kk".
          05 FILLER            PIC X(3) VALUE "kl".
          05 FILLER            PIC X(3) VALUE "km".
          05 FILLER            PIC X(3) VALUE "kn".
          05 FILLER            PIC X(3) VALUE "ko".
          05 FILLER            PIC X(3) VALUE "kpe".
          05 FILLER            PIC X(3) VALUE "kri".
          05 FILLER            PIC X(3) VALUE "ktu".
          05 FILLER            PIC X(3) VALUE "ku".
          05 FILLER            PIC X(3) VALUE "kw".
          05 FILLER            PIC X(3) VALUE "ky".
          05 FILLER            PIC X(3) VALUE "lb".
          05 FILLER            PIC X(3) VALUE "lg".
          05 FILLER            PIC X(3) VALUE "ln".
          05 FILLER            PIC X(3) VALUE "lo".
          05 FILLER            PIC X(3) VALUE "lt".
          05 FILLER            PIC X(3) VALUE "luo".
          05 FILLER            PIC X(3) VALUE "lv".
          05 FILLER            PIC X(3) VALUE "mam".
          05 FILLER            PIC X(3) VALUE "men".
          05 FILLER            PIC X(3) VALUE "mfe".
          05 FILLER            PIC X(3) VALUE "mg".
          05 FILLER            PIC X(3) VALUE "mi".
          05 FILLER            PIC X(3) VALUE "mk".
          05 FILLER            PIC X(3) VALUE "ml".
          05 FILLER            PIC X(3) VALUE "mn".
          05 FILLER            PIC X(3) VALUE "mnk".
          05 FILLER            PIC X(3) VALUE "mos".
          05 FILLER            PIC X(3) VALUE "mr".
          05 FILLER            PIC X(3) VALUE "ms".
          05 FILLER            PIC X(3) VALUE "mt".
          05 FILLER            PIC X(3) VALUE "my".
          05 FILLER            PIC X(3) VALUE "nb".
          05 FILLER            PIC X(3) VALUE "nd".
          05 FILLER            PIC X(3) VALUE "ne".
          05 FILLER            PIC X(3) VALUE "ng".
          05 FILLER            PIC X(3) VALUE "nl".
          05 FILLER            PIC X(3) VALUE "nr".
          05 FILLER            PIC X(3) VALUE "nso".
          05 FILLER            PIC X(3) VALUE "nus".
          05 FILLER            PIC X(3) VALUE "ny".
          05 FILLER            PIC X(3) VALUE "om".
          05 FILLER            PIC X(3) VALUE "or".
          05 FILLER            PIC X(3) VALUE "pa".
          05 FILLER            PIC X(3) VALUE "pis".
          05 FILLER            PIC X(3) VALUE "pl".
          05 FILLER            PIC X(3) VALUE "pov".
          05 FILLER            PIC X(3) VALUE "ps".
          05 FILLER            PIC X(3) VALUE "pt".
          05 FILLER            PIC X(3) VALUE "qu".
          05 FILLER            PIC X(3) VALUE "quc".
          05 FILLER            PIC X(3) VALUE "ro".
          05 FILLER            PIC X(3) VALUE "ru".
          05 FILLER            PIC X(3) VALUE "rw".
          05 FILLER            PIC X(3) VALUE "sar".
          05 FILLER            PIC X(3) VALUE "sd".
          05 FILLER            PIC X(3) VALUE "sg".
          05 FILLER            PIC X(3) VALUE "shi".
          05 FILLER            PIC X(3) VALUE "shn".
          05 FILLER            PIC X(3) VALUE "si".
          05 FILLER            PIC X(3) VALUE "sk".
          05 FILLER            PIC X(3) VALUE "sl".
          05 FILLER            PIC X(3) VALUE "sn".
          05 FILLER            PIC X(3) VALUE "snk".
          05 FILLER            PIC X(3) VALUE "so".
          05 FILLER            PIC X(3) VALUE "sq".
          05 FILLER            PIC X(3) VALUE "sr".
          05 FILLER            PIC X(3) VALUE "ss".
          05 FILLER            PIC X(3) VALUE "st".
          05 FILLER            PIC X(3) VALUE "su".
          05 FILLER            PIC X(3) VALUE "suk".
          05 FILLER            PIC X(3) VALUE "sv".
          05 FILLER            PIC X(3) VALUE "sw".
          05 FILLER            PIC X(3) VALUE "ta".
          05 FILLER            PIC X(3) VALUE "te".
          05 FILLER            PIC X(3) VALUE "tem".
          05 FILLER            PIC X(3) VALUE "tet".
          05 FILLER            PIC X(3) VALUE "tg".
          05 FILLER            PIC X(3) VALUE "th".
          05 FILLER            PIC X(3) VALUE "ti".
          05 FILLER            PIC X(3) VALUE "tig".
          05 FILLER            PIC X(3) VALUE "tk".
          05 FILLER            PIC X(3) VALUE "tn".
          05 FILLER            PIC X(3) VALUE "tpi".
          05 FILLER            PIC X(3) VALUE "tr".
          05 FILLER            PIC X(3) VALUE "ts".
          05 FILLER            PIC X(3) VALUE "tum".
          05 FILLER            PIC X(3) VALUE "tzm".
          05 FILLER            PIC X(3) VALUE "uk".
          05 FILLER            PIC X(3) VALUE "umb".
          05 FILLER            PIC X(3) VALUE "ur".
          05 FILLER            PIC X(3) VALUE "uz".
          05 FILLER            PIC X(3) VALUE "ve".
          05 FILLER            PIC X(3) VALUE "vi".
          05 FILLER            PIC X(3) VALUE "vmw".
          05 FILLER            PIC X(3) VALUE "wo".
          05 FILLER            PIC X(3) VALUE "xh".
          05 FILLER            PIC X(3) VALUE "yao".
          05 FILLER            PIC X(3) VALUE "yo".
          05 FILLER            PIC X(3) VALUE "yue".
          05 FILLER            PIC X(3) VALUE "zdj".
          05 FILLER            PIC X(3) VALUE "zh".
          05 FILLER            PIC X(3) VALUE "zu".
       01 WS-LOCALE-CODE-TABLE REDEFINES WS-LOCALE-CODE-VALUES.
          05 WS-LOCALE-CODE    PIC X(3) OCCURS 168 TIMES.
       01 WS-LOCALE-COUNT      PIC 9(3) VALUE 168.
       01 WS-LOCALE-IDX        PIC 9(3).

       COPY "age/impl/cobol/src/Types.cbl".

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

      *>   First arg is the command
           MOVE REQ-ARG(1) TO WS-CMD

      *>   Parse remaining arguments
           MOVE 2 TO WS-ARG-IDX
           PERFORM UNTIL WS-ARG-IDX > WS-ARG-COUNT
               MOVE REQ-ARG(WS-ARG-IDX) TO WS-ARG-VAL

               IF WS-STOP-OPTS = 0
                   AND WS-ARG-VAL(1:2) = "--"
                   AND FUNCTION TRIM(WS-ARG-VAL) = "--"
                   MOVE 1 TO WS-STOP-OPTS
                   ADD 1 TO WS-ARG-IDX
                   CONTINUE
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
                       WHEN "-g"
                       WHEN "--gender"
                           ADD 1 TO WS-ARG-IDX
                           IF WS-ARG-IDX > WS-ARG-COUNT
                               DISPLAY "error: '--gender' requ"
                                   "ires a value" UPON SYSERR
                               MOVE 2 TO REQ-EXIT-CODE
                               GOBACK
                           END-IF
                           MOVE REQ-ARG(WS-ARG-IDX) TO WS-OPT-GENDER
                           MOVE 1 TO WS-OPT-GENDER-SET
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
                   END-IF
               END-IF
               ADD 1 TO WS-ARG-IDX
           END-PERFORM

      *>   Dispatch command
           EVALUATE FUNCTION TRIM(WS-CMD)
               WHEN "age"
                   PERFORM CMD-AGE
               WHEN "stage"
                   PERFORM CMD-STAGE
               WHEN "locales"
                   PERFORM CMD-LOCALES
               WHEN OTHER
                   DISPLAY "error: unknown command '"
                       FUNCTION TRIM(WS-CMD) "'" UPON SYSERR
                   DISPLAY "Run 'sayable help' for usage."
                       UPON SYSERR
                   MOVE 2 TO REQ-EXIT-CODE
           END-EVALUATE
           GOBACK.

       CMD-AGE.
           IF WS-POS1-SET = 0
               DISPLAY "error: age requires a date-of-birth"
                   " argument" UPON SYSERR
               DISPLAY "Run 'sayable help' for usage."
                   UPON SYSERR
               MOVE 2 TO REQ-EXIT-CODE
               EXIT PARAGRAPH
           END-IF

      *>   Check for null
           IF (WS-POS1-LEN = 4 AND WS-POS1(1:4) = "null")
               MOVE 1 TO REQ-EXIT-CODE
               EXIT PARAGRAPH
           END-IF

      *>   Check for empty string
           IF FUNCTION TRIM(WS-POS1) = SPACES
               MOVE 1 TO REQ-EXIT-CODE
               EXIT PARAGRAPH
           END-IF

      *>   Load locale
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

      *>   Set up as-of
      *>   A null or empty as-of means today, as in the reference.
           IF WS-OPT-AS-OF-SET = 1 AND WS-OPT-AS-OF-LEN > 0
               AND NOT (WS-OPT-AS-OF-LEN = 4
                   AND WS-OPT-AS-OF(1:4) = "null")
               MOVE WS-OPT-AS-OF TO WS-FMT-AS-OF
               MOVE WS-OPT-AS-OF-LEN TO WS-FMT-AS-OF-LEN
           ELSE
               ACCEPT WS-TODAY-INT FROM DATE YYYYMMDD
               DIVIDE WS-TODAY-INT BY 10000
                   GIVING WS-TODAY-YYYY
                   REMAINDER WS-TODAY-INT
               DIVIDE WS-TODAY-INT BY 100
                   GIVING WS-TODAY-MM
                   REMAINDER WS-TODAY-DD
               MOVE SPACES TO WS-TODAY-STR
               STRING
                   WS-TODAY-YYYY "-"
                   WS-TODAY-MM "-"
                   WS-TODAY-DD
                   DELIMITED BY SIZE
                   INTO WS-TODAY-STR
               END-STRING
               MOVE WS-TODAY-STR TO WS-FMT-AS-OF
           END-IF

           MOVE WS-POS1 TO WS-FMT-DOB
           MOVE WS-POS1-LEN TO WS-FMT-DOB-LEN
           MOVE WS-OPT-COMPACTNESS TO WS-FMT-COMPACTNESS
           PERFORM FORMAT-AGE

           IF FUNCTION TRIM(WS-FORMAT-RESULT) = SPACES
               MOVE 1 TO REQ-EXIT-CODE
           ELSE
               MOVE WS-FORMAT-RESULT TO WS-EMIT-TEXT
               PERFORM EMIT-LINE
               MOVE 0 TO REQ-EXIT-CODE
           END-IF
           .

       CMD-STAGE.
           IF WS-POS1-SET = 0
               DISPLAY "error: stage requires a date-of-birth"
                   " argument" UPON SYSERR
               DISPLAY "Run 'sayable help' for usage."
                   UPON SYSERR
               MOVE 2 TO REQ-EXIT-CODE
               EXIT PARAGRAPH
           END-IF

      *>   Check for null or "undefined"
           IF (WS-POS1-LEN = 4 AND WS-POS1(1:4) = "null")
               OR FUNCTION TRIM(WS-POS1) = "undefined"
               MOVE 1 TO REQ-EXIT-CODE
               EXIT PARAGRAPH
           END-IF

      *>   Check for empty string
           IF FUNCTION TRIM(WS-POS1) = SPACES
               MOVE 1 TO REQ-EXIT-CODE
               EXIT PARAGRAPH
           END-IF

      *>   Load locale
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

      *>   Set up as-of
      *>   A null or empty as-of means today, as in the reference.
           IF WS-OPT-AS-OF-SET = 1 AND WS-OPT-AS-OF-LEN > 0
               AND NOT (WS-OPT-AS-OF-LEN = 4
                   AND WS-OPT-AS-OF(1:4) = "null")
               MOVE WS-OPT-AS-OF TO WS-FMT-AS-OF
               MOVE WS-OPT-AS-OF-LEN TO WS-FMT-AS-OF-LEN
           ELSE
               ACCEPT WS-TODAY-INT FROM DATE YYYYMMDD
               DIVIDE WS-TODAY-INT BY 10000
                   GIVING WS-TODAY-YYYY
                   REMAINDER WS-TODAY-INT
               DIVIDE WS-TODAY-INT BY 100
                   GIVING WS-TODAY-MM
                   REMAINDER WS-TODAY-DD
               MOVE SPACES TO WS-TODAY-STR
               STRING
                   WS-TODAY-YYYY "-"
                   WS-TODAY-MM "-"
                   WS-TODAY-DD
                   DELIMITED BY SIZE
                   INTO WS-TODAY-STR
               END-STRING
               MOVE WS-TODAY-STR TO WS-FMT-AS-OF
           END-IF

           MOVE WS-POS1 TO WS-FMT-DOB
           MOVE WS-POS1-LEN TO WS-FMT-DOB-LEN
           MOVE WS-OPT-COMPACTNESS TO WS-FMT-COMPACTNESS
           IF WS-OPT-GENDER-SET = 1
               MOVE WS-OPT-GENDER TO WS-FMT-GENDER
           ELSE
               MOVE SPACES TO WS-FMT-GENDER
           END-IF
           PERFORM FORMAT-STAGE

           IF FUNCTION TRIM(WS-STAGE-RESULT) = SPACES
               MOVE 1 TO REQ-EXIT-CODE
           ELSE
               MOVE WS-STAGE-RESULT TO WS-EMIT-TEXT
               PERFORM EMIT-LINE
               MOVE 0 TO REQ-EXIT-CODE
           END-IF
           .

       CMD-LOCALES.
           PERFORM PRINT-LOCALE-CODES
           MOVE 0 TO REQ-EXIT-CODE
           .

       PRINT-LOCALE-CODES.
           PERFORM VARYING WS-LOCALE-IDX FROM 1 BY 1
                   UNTIL WS-LOCALE-IDX > WS-LOCALE-COUNT
               MOVE WS-LOCALE-CODE(WS-LOCALE-IDX) TO WS-EMIT-TEXT
               PERFORM EMIT-LINE
           END-PERFORM
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

       COPY "age/impl/cobol/src/SayableAge.cbl".
       COPY "age/impl/cobol/src/locales/Locales.cbl".
