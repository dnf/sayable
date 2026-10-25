       IDENTIFICATION DIVISION.
       PROGRAM-ID. SAYABLE.
      *> Entry point: answers one request from the command line, or
      *> with `--repl` as the only argument, one tab-separated request
      *> per stdin line (see cli/SPEC.md). Component commands are
      *> CALLed so both modes share the same code.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT REQUEST-STREAM ASSIGN TO KEYBOARD
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-STREAM-STATUS.

       DATA DIVISION.
       FILE SECTION.
       FD REQUEST-STREAM
           RECORD VARYING IN SIZE FROM 1 TO 65536 CHARACTERS
               DEPENDING ON WS-LINE-LEN.
       01 REQUEST-LINE         PIC X(65536).

       WORKING-STORAGE SECTION.
       01 WS-VERSION           PIC X(5) VALUE "0.5.0".
       01 WS-MAX-ARGS          PIC 9(4) VALUE 256.
       01 WS-TAB               PIC X VALUE X"09".
       01 WS-NEWLINE           PIC X VALUE X"0A".
       01 WS-CARRIAGE-RETURN   PIC X VALUE X"0D".

       01 WS-ARGC              PIC 9(4).
       01 WS-ARG-IDX           PIC 9(4).
       01 WS-CMD               PIC X(1024).

       01 WS-STREAM-STATUS     PIC XX.
       01 WS-AT-EOF            PIC 9 VALUE 0.
       01 WS-LINE-LEN          PIC 9(5).
       01 WS-CHAR-IDX          PIC 9(5).
       01 WS-FIELD-START       PIC 9(5).
       01 WS-FIELD-LEN         PIC 9(5).
       01 WS-TOO-MANY-ARGS     PIC 9.

       01 WS-OUTPUT-LEN        PIC 9(5).

       COPY "cli/impl/cobol/request.cpy".

       PROCEDURE DIVISION.
       MAIN-PROGRAM.
           ACCEPT WS-ARGC FROM ARGUMENT-NUMBER
           IF WS-ARGC = 1
               ACCEPT WS-CMD FROM ARGUMENT-VALUE
               IF WS-CMD = "--repl"
                   PERFORM REPL
                   MOVE 0 TO RETURN-CODE
                   STOP RUN
               END-IF
           END-IF
           PERFORM LOAD-COMMAND-LINE
           PERFORM RUN-REQUEST
           PERFORM PRINT-ONE-SHOT-OUTPUT
           MOVE REQ-EXIT-CODE TO RETURN-CODE
           STOP RUN.

       LOAD-COMMAND-LINE.
           PERFORM START-REQUEST
           MOVE 0 TO WS-TOO-MANY-ARGS
           PERFORM VARYING WS-ARG-IDX FROM 1 BY 1
                   UNTIL WS-ARG-IDX > WS-ARGC
               IF WS-ARG-IDX > WS-MAX-ARGS
                   MOVE 1 TO WS-TOO-MANY-ARGS
               ELSE
                   DISPLAY WS-ARG-IDX UPON ARGUMENT-NUMBER
                   ACCEPT REQ-ARG(WS-ARG-IDX) FROM ARGUMENT-VALUE
                   MOVE WS-ARG-IDX TO REQ-ARG-COUNT
               END-IF
           END-PERFORM
           .

       START-REQUEST.
           MOVE 0 TO REQ-ARG-COUNT
           MOVE SPACES TO REQ-OUTPUT
           MOVE 1 TO REQ-OUTPUT-PTR
           MOVE 0 TO REQ-EXIT-CODE
           .

      *> Reads requests until EOF; each gets exactly one response line.
       REPL.
           OPEN INPUT REQUEST-STREAM
           PERFORM UNTIL WS-AT-EOF = 1
               READ REQUEST-STREAM
                   AT END
                       MOVE 1 TO WS-AT-EOF
                   NOT AT END
                       PERFORM SPLIT-REQUEST-LINE
                       PERFORM RUN-REQUEST
                       PERFORM PRINT-REPL-RESPONSE
               END-READ
           END-PERFORM
           CLOSE REQUEST-STREAM
           .

      *> Splits on tabs, keeping empty fields: "age<TAB>" is two
      *> arguments, the second empty.
       SPLIT-REQUEST-LINE.
           PERFORM START-REQUEST
           MOVE 0 TO WS-TOO-MANY-ARGS
           IF WS-LINE-LEN > 0
               AND REQUEST-LINE(WS-LINE-LEN:1) = WS-CARRIAGE-RETURN
               SUBTRACT 1 FROM WS-LINE-LEN
           END-IF
           MOVE 1 TO WS-FIELD-START
           PERFORM VARYING WS-CHAR-IDX FROM 1 BY 1
                   UNTIL WS-CHAR-IDX > WS-LINE-LEN
               IF REQUEST-LINE(WS-CHAR-IDX:1) = WS-TAB
                   PERFORM ADD-FIELD
                   COMPUTE WS-FIELD-START = WS-CHAR-IDX + 1
               END-IF
           END-PERFORM
           PERFORM ADD-FIELD
           .

      *> Adds REQUEST-LINE from WS-FIELD-START up to WS-CHAR-IDX
      *> (exclusive) as the next argument.
       ADD-FIELD.
           IF REQ-ARG-COUNT >= WS-MAX-ARGS
               MOVE 1 TO WS-TOO-MANY-ARGS
               EXIT PARAGRAPH
           END-IF
           ADD 1 TO REQ-ARG-COUNT
           COMPUTE WS-FIELD-LEN = WS-CHAR-IDX - WS-FIELD-START
           IF WS-FIELD-LEN = 0
               MOVE SPACES TO REQ-ARG(REQ-ARG-COUNT)
           ELSE
               MOVE REQUEST-LINE(WS-FIELD-START:WS-FIELD-LEN)
                   TO REQ-ARG(REQ-ARG-COUNT)
           END-IF
           .

       RUN-REQUEST.
           IF WS-TOO-MANY-ARGS = 1
               DISPLAY "error: too many arguments (at most "
                   WS-MAX-ARGS ")" UPON SYSERR
               MOVE 2 TO REQ-EXIT-CODE
               EXIT PARAGRAPH
           END-IF
           IF REQ-ARG-COUNT = 0
               PERFORM EMIT-HELP
               MOVE 2 TO REQ-EXIT-CODE
               EXIT PARAGRAPH
           END-IF
           MOVE REQ-ARG(1) TO WS-CMD
           EVALUATE WS-CMD
               WHEN "-h"
               WHEN "--help"
               WHEN "help"
                   PERFORM EMIT-HELP
                   MOVE 0 TO REQ-EXIT-CODE
               WHEN "-v"
               WHEN "--version"
               WHEN "version"
                   STRING "sayable " WS-VERSION WS-NEWLINE
                       DELIMITED BY SIZE
                       INTO REQ-OUTPUT WITH POINTER REQ-OUTPUT-PTR
                   END-STRING
                   MOVE 0 TO REQ-EXIT-CODE
               WHEN "age"
               WHEN "stage"
               WHEN "locales"
                   CALL "AGE-CLI" USING SAYABLE-REQUEST
               WHEN "date"
               WHEN "relative"
                   CALL "DATE-CLI" USING SAYABLE-REQUEST
               WHEN "time"
                   CALL "TIME-CLI" USING SAYABLE-REQUEST
               WHEN "duration"
               WHEN "since"
               WHEN "until"
                   CALL "DURATION-CLI" USING SAYABLE-REQUEST
               WHEN OTHER
                   DISPLAY "error: unknown command '"
                       FUNCTION TRIM(WS-CMD TRAILING) "'" UPON SYSERR
                   DISPLAY "Run 'sayable help' for usage."
                       UPON SYSERR
                   MOVE 2 TO REQ-EXIT-CODE
           END-EVALUATE
           .

       EMIT-HELP.
           STRING
               "Usage: sayable <command> [arguments] [options]"
               WS-NEWLINE WS-NEWLINE
               "Commands:" WS-NEWLINE
               "  age <dob>              Format an age" WS-NEWLINE
               "  stage <dob>            Get developmental stage"
               WS-NEWLINE
               "  date <date>            Format a calendar date"
               WS-NEWLINE
               "  relative <date>        Format a relative date"
               WS-NEWLINE
               "  time <time>            Format a clock time"
               WS-NEWLINE
               "  duration <value> [end] Format a duration"
               WS-NEWLINE
               "  since <start>          Format elapsed time"
               WS-NEWLINE
               "  until <target>         Format remaining time"
               WS-NEWLINE
               "  locales                List available locale codes"
               WS-NEWLINE
               "  version                Show version" WS-NEWLINE
               "  help                   Show this help" WS-NEWLINE
               WS-NEWLINE
               "Options:" WS-NEWLINE
               "  -l, --locale <code>    Locale code (default: en)"
               WS-NEWLINE
               "  -d, --as-of <value>    Reference date/timestamp"
               WS-NEWLINE
               "      --short            Short compactness"
               WS-NEWLINE
               "      --compact          Compact compactness"
               WS-NEWLINE
               "  -g, --gender <m|f>     Gender for stage labels"
               WS-NEWLINE
               "      --with-year        Include year (date only)"
               WS-NEWLINE
               "  -h, --help             Show this help" WS-NEWLINE
               "  -v, --version          Show version" WS-NEWLINE
               DELIMITED BY SIZE
               INTO REQ-OUTPUT WITH POINTER REQ-OUTPUT-PTR
           END-STRING
           .

      *> Response output length without the final newline.
       MEASURE-OUTPUT.
           IF REQ-OUTPUT-PTR > 1
               COMPUTE WS-OUTPUT-LEN = REQ-OUTPUT-PTR - 2
           ELSE
               MOVE 0 TO WS-OUTPUT-LEN
           END-IF
           .

       PRINT-ONE-SHOT-OUTPUT.
           PERFORM MEASURE-OUTPUT
           IF WS-OUTPUT-LEN > 0
               DISPLAY REQ-OUTPUT(1:WS-OUTPUT-LEN)
           END-IF
           .

       PRINT-REPL-RESPONSE.
           PERFORM MEASURE-OUTPUT
           IF WS-OUTPUT-LEN > 0
               INSPECT REQ-OUTPUT(1:WS-OUTPUT-LEN)
                   REPLACING ALL WS-NEWLINE BY WS-TAB
               DISPLAY REQ-EXIT-CODE WS-TAB REQ-OUTPUT(1:WS-OUTPUT-LEN)
           ELSE
               DISPLAY REQ-EXIT-CODE WS-TAB
           END-IF
      *>   DISPLAY may leave stdout buffered when it is a pipe, and a
      *>   driver waits for each response before sending the next line.
           CALL STATIC "fflush" USING BY VALUE 0
           .
