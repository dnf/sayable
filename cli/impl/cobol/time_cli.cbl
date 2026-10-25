       IDENTIFICATION DIVISION.
       PROGRAM-ID. TIME-CLI IS INITIAL.
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
       01 WS-POS1-SET          PIC 9 VALUE 0.
       01 WS-OPT-LOCALE        PIC X(8) VALUE "en".
       01 WS-OPT-COMPACTNESS   PIC 9 VALUE 0.
       01 WS-ARG-IDX           PIC 9(4).
       01 WS-STOP-OPTS         PIC 9 VALUE 0.

       COPY "time/impl/cobol/src/Types.cbl".

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
                       MOVE 1 TO WS-POS1-SET
                   END-IF
               END-IF
               ADD 1 TO WS-ARG-IDX
           END-PERFORM

           EVALUATE FUNCTION TRIM(WS-CMD)
               WHEN "time"
                   PERFORM CMD-TIME
               WHEN OTHER
                   DISPLAY "error: unknown command '"
                       FUNCTION TRIM(WS-CMD) "'" UPON SYSERR
                   DISPLAY "Run 'sayable help' for usage."
                       UPON SYSERR
                   MOVE 2 TO REQ-EXIT-CODE
           END-EVALUATE
           GOBACK.

       CMD-TIME.
           IF WS-POS1-SET = 0
               DISPLAY "error: time requires a time argument"
                   UPON SYSERR
               DISPLAY "Run 'sayable help' for usage."
                   UPON SYSERR
               MOVE 2 TO REQ-EXIT-CODE
               EXIT PARAGRAPH
           END-IF

           IF FUNCTION TRIM(WS-POS1) = "null"
               MOVE 1 TO REQ-EXIT-CODE
               EXIT PARAGRAPH
           END-IF

           IF FUNCTION TRIM(WS-POS1) = SPACES
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

           MOVE WS-POS1 TO WS-FMT-TIME
           MOVE WS-OPT-COMPACTNESS TO WS-FMT-COMPACTNESS
           PERFORM FORMAT-TIME

           IF FUNCTION TRIM(WS-FORMAT-RESULT) = SPACES
               MOVE 1 TO REQ-EXIT-CODE
           ELSE
               MOVE WS-FORMAT-RESULT TO WS-EMIT-TEXT
               PERFORM EMIT-LINE
               MOVE 0 TO REQ-EXIT-CODE
           END-IF
           .

      *> Appends one stdout line to the response.
       EMIT-LINE.
           STRING FUNCTION TRIM(WS-EMIT-TEXT) X"0A"
               DELIMITED BY SIZE
               INTO REQ-OUTPUT WITH POINTER REQ-OUTPUT-PTR
           END-STRING
           .

       COPY "time/impl/cobol/src/SayableTime.cbl".
       COPY "time/impl/cobol/src/locales/Locales.cbl".
