*> Types.cbl - WORKING-STORAGE copybook for sayable-time COBOL
*> Included via COPY in the main test program

*> Constants
 01 PT-VERSION              PIC X(10) VALUE "0.5.0".
 01 PT-NORMAL               PIC 9 VALUE 0.
 01 PT-SHORT                PIC 9 VALUE 1.
 01 PT-COMPACT              PIC 9 VALUE 2.

*> ============================================================
*> Active locale fields (WS-ACT-*)
*> Populated by GET-LOCALE -> INIT-LOCALE-XX
*> ============================================================
 01 WS-ACT-CODE             PIC X(8).

*> Clock hours (12 entries, index 1-12 for hours 0-11)
 01 WS-ACT-HOUR             PIC X(64) OCCURS 12.

*> Midnight and noon
 01 WS-ACT-MIDNIGHT         PIC X(128).
 01 WS-ACT-NOON             PIC X(128).

*> Clock patterns (12 entries for minutes: 0,5,10,15,20,25,30,35,40,45,50,55)
 01 WS-ACT-PATTERN          PIC X(256) OCCURS 12.

*> Short compactness override
 01 WS-ACT-HAS-SHORT        PIC 9.
 01 WS-ACT-SHORT-USE24H     PIC 9.
 01 WS-ACT-SHORT-FORMAT     PIC X(64).
 01 WS-ACT-SHORT-AM         PIC X(16).
 01 WS-ACT-SHORT-PM         PIC X(16).

*> Compact compactness override
 01 WS-ACT-HAS-COMPACT      PIC 9.
 01 WS-ACT-COMPACT-USE24H   PIC 9.
 01 WS-ACT-COMPACT-FORMAT   PIC X(64).
 01 WS-ACT-COMPACT-AM       PIC X(16).
 01 WS-ACT-COMPACT-PM       PIC X(16).

*> ============================================================
*> Working variables for the formatter
*> ============================================================
 01 WS-FORMAT-RESULT         PIC X(256).

*> Time parsing variables
*> Lookahead past the input may read three characters beyond it,
*> so the buffer has room after the longest input.
 01 WS-TIME-STR              PIC X(260).
 01 WS-TIME-LEN              PIC 9(4).
 01 WS-PARSED-HOUR           PIC 9(2).
 01 WS-PARSED-MINUTE         PIC 9(2).
 01 WS-PARSED-SECOND         PIC 9(2).
 01 WS-PARSE-OK              PIC 9.
 01 WS-T-POS                 PIC 9(4).
 01 WS-CLOCK-START           PIC 9(4).
 01 WS-SCAN-POS              PIC 9(4).
 01 WS-HOUR-DIGITS           PIC 9.
 01 WS-ZONE-LEN              PIC S9(4).
 01 WS-DATE-YEAR             PIC 9(4).
 01 WS-DATE-MONTH            PIC 9(2).
 01 WS-DATE-DAY              PIC 9(2).
 01 WS-MONTH-DAY-COUNT       PIC 9(2).

*> Formatter working variables
 01 WS-ROUNDED-MIN           PIC 9(2).
 01 WS-HOUR                  PIC 9(2).
 01 WS-H12                   PIC 9(2).
 01 WS-NEXT-H12              PIC 9(2).
 01 WS-H-NAME                PIC X(64).
 01 WS-NEXT-H-NAME           PIC X(64).
 01 WS-PAT-IDX               PIC 9(2).
 01 WS-PATTERN               PIC X(256).
 01 WS-AMPM-STR              PIC X(16).
 01 WS-TEMP-CALC             PIC 9(4).
 01 WS-TEMP-REM              PIC 9(4).

*> String replacement working variables
 01 WS-REPLACE-SRC           PIC X(512).
 01 WS-REPLACE-MARKER        PIC X(20).
 01 WS-REPLACE-REPL          PIC X(256).
 01 WS-REPLACE-RESULT        PIC X(512).
 01 WS-REPLACE-POS           PIC 9(4).
 01 WS-REPLACE-SRC-LEN       PIC 9(4).
 01 WS-REPLACE-MRK-LEN       PIC 9(4).

*> Numeric to string conversion
 01 WS-NUM-TO-STR-INPUT      PIC 9(8).
 01 WS-NUM-TO-STR-RESULT     PIC X(12).
 01 WS-NUM-TO-STR-EDITED     PIC Z(7)9.

*> Minute zero-padded
 01 WS-MM-DIGITS             PIC 99.

*> Lookup variables
 01 WS-LOOKUP-CODE           PIC X(8).
 01 WS-LOOKUP-FOUND          PIC 9.

*> Format arguments
 01 WS-FMT-COMPACTNESS       PIC 9.
*> WS-FMT-TIME-LEN is the input's exact length, trailing blanks
*> included, for callers that know it (the CLI); 0 means the length
*> without them.
 01 WS-FMT-TIME              PIC X(256).
 01 WS-FMT-TIME-LEN          PIC 9(4) VALUE 0.
