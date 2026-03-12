       IDENTIFICATION DIVISION.
       PROGRAM-ID. AGE-CLI.

       DATA DIVISION.
       WORKING-STORAGE SECTION.

      *> CLI argument handling
       01 WS-ARG-COUNT         PIC 9(4).
       01 WS-ARG-VAL           PIC X(256).
       01 WS-CMD               PIC X(20).
       01 WS-POS1              PIC X(256).
       01 WS-POS1-SET          PIC 9 VALUE 0.
       01 WS-OPT-LOCALE        PIC X(8) VALUE "en".
       01 WS-OPT-AS-OF         PIC X(30).
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

       COPY "age/impl/cobol/src/Types.cbl".

       PROCEDURE DIVISION.
       MAIN-PROGRAM.
           ACCEPT WS-ARG-COUNT FROM ARGUMENT-NUMBER
           IF WS-ARG-COUNT < 1
               DISPLAY "error: missing command" UPON SYSERR
               MOVE 2 TO RETURN-CODE
               STOP RUN
           END-IF

      *>   First arg is the command
           DISPLAY 1 UPON ARGUMENT-NUMBER
           ACCEPT WS-CMD FROM ARGUMENT-VALUE

      *>   Parse remaining arguments
           MOVE 2 TO WS-ARG-IDX
           PERFORM UNTIL WS-ARG-IDX > WS-ARG-COUNT
               DISPLAY WS-ARG-IDX UPON ARGUMENT-NUMBER
               ACCEPT WS-ARG-VAL FROM ARGUMENT-VALUE

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
                       WHEN "-g"
                       WHEN "--gender"
                           ADD 1 TO WS-ARG-IDX
                           IF WS-ARG-IDX > WS-ARG-COUNT
                               DISPLAY "error: '--gender' requ"
                                   "ires a value" UPON SYSERR
                               MOVE 2 TO RETURN-CODE
                               STOP RUN
                           END-IF
                           DISPLAY WS-ARG-IDX
                               UPON ARGUMENT-NUMBER
                           ACCEPT WS-OPT-GENDER
                               FROM ARGUMENT-VALUE
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
                           MOVE 2 TO RETURN-CODE
                           STOP RUN
                   END-EVALUATE
               ELSE
                   IF WS-POS1-SET = 0
                       MOVE WS-ARG-VAL TO WS-POS1
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
                   MOVE 2 TO RETURN-CODE
           END-EVALUATE
           STOP RUN.

       CMD-AGE.
           IF WS-POS1-SET = 0
               DISPLAY "error: age requires a date-of-birth"
                   " argument" UPON SYSERR
               DISPLAY "Run 'sayable help' for usage."
                   UPON SYSERR
               MOVE 2 TO RETURN-CODE
               EXIT PARAGRAPH
           END-IF

      *>   Check for null
           IF FUNCTION TRIM(WS-POS1) = "null"
               MOVE 1 TO RETURN-CODE
               EXIT PARAGRAPH
           END-IF

      *>   Check for empty string
           IF FUNCTION TRIM(WS-POS1) = SPACES
               MOVE 1 TO RETURN-CODE
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
               MOVE 2 TO RETURN-CODE
               EXIT PARAGRAPH
           END-IF

      *>   Set up as-of
           IF WS-OPT-AS-OF-SET = 1
               IF FUNCTION TRIM(WS-OPT-AS-OF) = "null"
                   MOVE 1 TO RETURN-CODE
                   EXIT PARAGRAPH
               END-IF
               MOVE WS-OPT-AS-OF TO WS-FMT-AS-OF
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
           MOVE WS-OPT-COMPACTNESS TO WS-FMT-COMPACTNESS
           PERFORM FORMAT-AGE

           IF FUNCTION TRIM(WS-FORMAT-RESULT) = SPACES
               MOVE 1 TO RETURN-CODE
           ELSE
               DISPLAY FUNCTION TRIM(WS-FORMAT-RESULT)
               MOVE 0 TO RETURN-CODE
           END-IF
           .

       CMD-STAGE.
           IF WS-POS1-SET = 0
               DISPLAY "error: stage requires a date-of-birth"
                   " argument" UPON SYSERR
               DISPLAY "Run 'sayable help' for usage."
                   UPON SYSERR
               MOVE 2 TO RETURN-CODE
               EXIT PARAGRAPH
           END-IF

      *>   Check for null or "undefined"
           IF FUNCTION TRIM(WS-POS1) = "null"
               OR FUNCTION TRIM(WS-POS1) = "undefined"
               MOVE 1 TO RETURN-CODE
               EXIT PARAGRAPH
           END-IF

      *>   Check for empty string
           IF FUNCTION TRIM(WS-POS1) = SPACES
               MOVE 1 TO RETURN-CODE
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
               MOVE 2 TO RETURN-CODE
               EXIT PARAGRAPH
           END-IF

      *>   Set up as-of
           IF WS-OPT-AS-OF-SET = 1
               IF FUNCTION TRIM(WS-OPT-AS-OF) = "null"
                   MOVE 1 TO RETURN-CODE
                   EXIT PARAGRAPH
               END-IF
               MOVE WS-OPT-AS-OF TO WS-FMT-AS-OF
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
           MOVE WS-OPT-COMPACTNESS TO WS-FMT-COMPACTNESS
           IF WS-OPT-GENDER-SET = 1
               MOVE WS-OPT-GENDER TO WS-FMT-GENDER
           ELSE
               MOVE SPACES TO WS-FMT-GENDER
           END-IF
           PERFORM FORMAT-STAGE

           IF FUNCTION TRIM(WS-STAGE-RESULT) = SPACES
               MOVE 1 TO RETURN-CODE
           ELSE
               DISPLAY FUNCTION TRIM(WS-STAGE-RESULT)
               MOVE 0 TO RETURN-CODE
           END-IF
           .

       CMD-LOCALES.
           PERFORM PRINT-LOCALE-CODES
           MOVE 0 TO RETURN-CODE
           .

       PRINT-LOCALE-CODES.
           DISPLAY "af"
           DISPLAY "ak"
           DISPLAY "am"
           DISPLAY "ar"
           DISPLAY "az"
           DISPLAY "bci"
           DISPLAY "be"
           DISPLAY "bem"
           DISPLAY "bg"
           DISPLAY "bi"
           DISPLAY "bm"
           DISPLAY "bn"
           DISPLAY "br"
           DISPLAY "bs"
           DISPLAY "ca"
           DISPLAY "ceb"
           DISPLAY "cs"
           DISPLAY "cy"
           DISPLAY "da"
           DISPLAY "de"
           DISPLAY "din"
           DISPLAY "dje"
           DISPLAY "dyu"
           DISPLAY "ee"
           DISPLAY "el"
           DISPLAY "en"
           DISPLAY "es"
           DISPLAY "et"
           DISPLAY "eu"
           DISPLAY "fa"
           DISPLAY "fan"
           DISPLAY "ff"
           DISPLAY "fi"
           DISPLAY "fil"
           DISPLAY "fon"
           DISPLAY "fr"
           DISPLAY "ga"
           DISPLAY "gd"
           DISPLAY "gl"
           DISPLAY "gn"
           DISPLAY "gu"
           DISPLAY "gv"
           DISPLAY "ha"
           DISPLAY "he"
           DISPLAY "hi"
           DISPLAY "hr"
           DISPLAY "ht"
           DISPLAY "hu"
           DISPLAY "hy"
           DISPLAY "id"
           DISPLAY "ig"
           DISPLAY "is"
           DISPLAY "it"
           DISPLAY "ja"
           DISPLAY "jv"
           DISPLAY "ka"
           DISPLAY "kbp"
           DISPLAY "kk"
           DISPLAY "km"
           DISPLAY "kn"
           DISPLAY "ko"
           DISPLAY "kpe"
           DISPLAY "ktu"
           DISPLAY "ku"
           DISPLAY "kw"
           DISPLAY "ky"
           DISPLAY "lg"
           DISPLAY "ln"
           DISPLAY "lo"
           DISPLAY "lt"
           DISPLAY "lv"
           DISPLAY "men"
           DISPLAY "mfe"
           DISPLAY "mg"
           DISPLAY "mi"
           DISPLAY "mk"
           DISPLAY "ml"
           DISPLAY "mn"
           DISPLAY "mnk"
           DISPLAY "mos"
           DISPLAY "mr"
           DISPLAY "ms"
           DISPLAY "mt"
           DISPLAY "my"
           DISPLAY "nb"
           DISPLAY "nd"
           DISPLAY "ne"
           DISPLAY "ng"
           DISPLAY "nl"
           DISPLAY "nso"
           DISPLAY "nus"
           DISPLAY "ny"
           DISPLAY "om"
           DISPLAY "or"
           DISPLAY "pa"
           DISPLAY "pl"
           DISPLAY "pov"
           DISPLAY "ps"
           DISPLAY "pt"
           DISPLAY "qu"
           DISPLAY "ro"
           DISPLAY "ru"
           DISPLAY "rw"
           DISPLAY "sar"
           DISPLAY "sd"
           DISPLAY "sg"
           DISPLAY "shi"
           DISPLAY "si"
           DISPLAY "sk"
           DISPLAY "sl"
           DISPLAY "sn"
           DISPLAY "snk"
           DISPLAY "so"
           DISPLAY "sq"
           DISPLAY "sr"
           DISPLAY "ss"
           DISPLAY "st"
           DISPLAY "su"
           DISPLAY "suk"
           DISPLAY "sv"
           DISPLAY "sw"
           DISPLAY "ta"
           DISPLAY "te"
           DISPLAY "tem"
           DISPLAY "tg"
           DISPLAY "th"
           DISPLAY "ti"
           DISPLAY "tig"
           DISPLAY "tk"
           DISPLAY "tn"
           DISPLAY "tr"
           DISPLAY "ts"
           DISPLAY "tzm"
           DISPLAY "uk"
           DISPLAY "umb"
           DISPLAY "ur"
           DISPLAY "uz"
           DISPLAY "vi"
           DISPLAY "vmw"
           DISPLAY "wo"
           DISPLAY "xh"
           DISPLAY "yo"
           DISPLAY "yue"
           DISPLAY "zdj"
           DISPLAY "zh"
           DISPLAY "zu"
           .

       COPY "age/impl/cobol/src/SayableAge.cbl".
       COPY "age/impl/cobol/src/locales/Locales.cbl".
