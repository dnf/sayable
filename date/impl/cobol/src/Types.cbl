*> Types.cbl - WORKING-STORAGE copybook for sayable-date COBOL
*> Included via COPY in the main test program

*> Constants
 01 PT-VERSION              PIC X(10) VALUE "0.5.0".
 01 PT-NORMAL               PIC 9 VALUE 0.
 01 PT-SHORT                PIC 9 VALUE 1.
 01 PT-COMPACT              PIC 9 VALUE 2.
 01 PT-MAX-EXCEPTIONS       PIC 9(2) VALUE 31.

*> ============================================================
*> Active locale fields (WS-ACT-*)
*> Populated by GET-LOCALE -> INIT-LOCALE-XX
*> ============================================================
 01 WS-ACT-CODE             PIC X(8).

*> Months (12 entries)
 01 WS-ACT-MONTH            PIC X(64) OCCURS 12.

*> Months in date / genitive form (optional)
 01 WS-ACT-HAS-MONTHS-IN-DATE PIC 9.
 01 WS-ACT-MONTH-IN-DATE    PIC X(64) OCCURS 12.

*> Weekdays (7 entries: 1=Sunday..7=Saturday)
 01 WS-ACT-WEEKDAY          PIC X(64) OCCURS 7.

*> Day format
 01 WS-ACT-DAY-FORMAT       PIC X(64).

*> Day format exceptions (key-value pairs)
 01 WS-ACT-DAY-FMT-EXC-COUNT PIC 9(2).
 01 WS-ACT-DAY-FMT-EXC-KEY  PIC X(4) OCCURS 31.
 01 WS-ACT-DAY-FMT-EXC-VAL  PIC X(64) OCCURS 31.

*> Date patterns
 01 WS-ACT-DATE-PATTERN     PIC X(128).
 01 WS-ACT-DATE-PAT-WITH-YEAR PIC X(128).

*> Proximity strings
 01 WS-ACT-TODAY             PIC X(128).
 01 WS-ACT-TOMORROW          PIC X(128).
 01 WS-ACT-YESTERDAY         PIC X(128).
 01 WS-ACT-DAY-AFTER-TOMORROW PIC X(128).
 01 WS-ACT-DAY-BEFORE-YESTERDAY PIC X(128).
 01 WS-ACT-THIS-WEEKDAY     PIC X(128).
 01 WS-ACT-NEXT-WEEKDAY     PIC X(128).
 01 WS-ACT-LAST-WEEKDAY     PIC X(128).

*> Short compactness override
 01 WS-ACT-HAS-SHORT        PIC 9.
 01 WS-ACT-SHORT-HAS-MONTHS PIC 9.
 01 WS-ACT-SHORT-MONTH      PIC X(64) OCCURS 12.
 01 WS-ACT-SHORT-HAS-MID    PIC 9.
 01 WS-ACT-SHORT-MID        PIC X(64) OCCURS 12.
 01 WS-ACT-SHORT-HAS-WKDAYS PIC 9.
 01 WS-ACT-SHORT-WKDAY      PIC X(64) OCCURS 7.
 01 WS-ACT-SHORT-HAS-DAY-FMT PIC 9.
 01 WS-ACT-SHORT-DAY-FMT    PIC X(64).
 01 WS-ACT-SHORT-HAS-DAY-EXC PIC 9.
 01 WS-ACT-SHORT-DAY-EXC-COUNT PIC 9(2).
 01 WS-ACT-SHORT-DAY-EXC-KEY PIC X(4) OCCURS 31.
 01 WS-ACT-SHORT-DAY-EXC-VAL PIC X(64) OCCURS 31.
 01 WS-ACT-SHORT-HAS-DATE-PAT PIC 9.
 01 WS-ACT-SHORT-DATE-PAT   PIC X(128).
 01 WS-ACT-SHORT-HAS-DATE-PAT-YR PIC 9.
 01 WS-ACT-SHORT-DATE-PAT-YR PIC X(128).
 01 WS-ACT-SHORT-HAS-TODAY  PIC 9.
 01 WS-ACT-SHORT-TODAY      PIC X(128).
 01 WS-ACT-SHORT-HAS-TOMORROW PIC 9.
 01 WS-ACT-SHORT-TOMORROW   PIC X(128).
 01 WS-ACT-SHORT-HAS-YESTERDAY PIC 9.
 01 WS-ACT-SHORT-YESTERDAY  PIC X(128).

*> Compact compactness override
 01 WS-ACT-HAS-COMPACT      PIC 9.
 01 WS-ACT-COMPACT-HAS-MONTHS PIC 9.
 01 WS-ACT-COMPACT-MONTH    PIC X(64) OCCURS 12.
 01 WS-ACT-COMPACT-HAS-MID  PIC 9.
 01 WS-ACT-COMPACT-MID      PIC X(64) OCCURS 12.
 01 WS-ACT-COMPACT-HAS-WKDAYS PIC 9.
 01 WS-ACT-COMPACT-WKDAY    PIC X(64) OCCURS 7.
 01 WS-ACT-COMPACT-HAS-DAY-FMT PIC 9.
 01 WS-ACT-COMPACT-DAY-FMT  PIC X(64).
 01 WS-ACT-COMPACT-HAS-DAY-EXC PIC 9.
 01 WS-ACT-COMPACT-DAY-EXC-COUNT PIC 9(2).
 01 WS-ACT-COMPACT-DAY-EXC-KEY PIC X(4) OCCURS 31.
 01 WS-ACT-COMPACT-DAY-EXC-VAL PIC X(64) OCCURS 31.
 01 WS-ACT-COMPACT-HAS-DATE-PAT PIC 9.
 01 WS-ACT-COMPACT-DATE-PAT PIC X(128).
 01 WS-ACT-COMPACT-HAS-DATE-PAT-YR PIC 9.
 01 WS-ACT-COMPACT-DATE-PAT-YR PIC X(128).
 01 WS-ACT-COMPACT-HAS-TODAY PIC 9.
 01 WS-ACT-COMPACT-TODAY    PIC X(128).
 01 WS-ACT-COMPACT-HAS-TOMORROW PIC 9.
 01 WS-ACT-COMPACT-TOMORROW PIC X(128).
 01 WS-ACT-COMPACT-HAS-YESTERDAY PIC 9.
 01 WS-ACT-COMPACT-YESTERDAY PIC X(128).

*> ============================================================
*> Effective locale fields (after compactness override applied)
*> ============================================================
 01 WS-EFF-MONTH            PIC X(64) OCCURS 12.
 01 WS-EFF-MONTH-IN-DATE    PIC X(64) OCCURS 12.
 01 WS-EFF-HAS-MID          PIC 9.
 01 WS-EFF-WEEKDAY          PIC X(64) OCCURS 7.
 01 WS-EFF-DAY-FORMAT       PIC X(64).
 01 WS-EFF-DAY-FMT-EXC-COUNT PIC 9(2).
 01 WS-EFF-DAY-FMT-EXC-KEY  PIC X(4) OCCURS 31.
 01 WS-EFF-DAY-FMT-EXC-VAL  PIC X(64) OCCURS 31.
 01 WS-EFF-DATE-PATTERN     PIC X(128).
 01 WS-EFF-DATE-PAT-WITH-YEAR PIC X(128).
 01 WS-EFF-TODAY             PIC X(128).
 01 WS-EFF-TOMORROW          PIC X(128).
 01 WS-EFF-YESTERDAY         PIC X(128).

*> ============================================================
*> Working variables for the formatter
*> ============================================================
 01 WS-FORMAT-RESULT         PIC X(256).

*> Date fields
 01 WS-DATE-YEAR             PIC 9(4).
 01 WS-DATE-MONTH            PIC 9(2).
 01 WS-DATE-DAY              PIC 9(2).
 01 WS-ASOF-YEAR             PIC 9(4).
 01 WS-ASOF-MONTH            PIC 9(2).
 01 WS-ASOF-DAY              PIC 9(2).

*> Julian day calculation variables
 01 WS-JD-CALC-YEAR          PIC 9(4).
 01 WS-JD-CALC-MONTH         PIC 9(2).
 01 WS-JD-CALC-DAY           PIC 9(2).
 01 WS-JD-CALC-RESULT        PIC S9(12).
 01 WS-JD-A                  PIC S9(8).
 01 WS-JD-Y                  PIC S9(8).
 01 WS-JD-M                  PIC S9(8).
 01 WS-JD1                   PIC S9(12).
 01 WS-JD2                   PIC S9(12).
 01 WS-JD-T1                 PIC S9(12).
 01 WS-JD-T2                 PIC S9(12).
 01 WS-JD-T3                 PIC S9(12).
 01 WS-JD-T4                 PIC S9(12).
 01 WS-JD-T5                 PIC S9(12).
 01 WS-JD-T6                 PIC S9(12).

*> Diff and DOW
 01 WS-DIFF-DAYS             PIC S9(8).
 01 WS-DOW                   PIC 9.
 01 WS-INCLUDE-YEAR          PIC 9.

*> Date parsing variables
 01 WS-DATE-STR              PIC X(256).
 01 WS-DATE-LEN              PIC 9(4).
 01 WS-PARSED-MONTH-DAYS     PIC 9(2).
 01 WS-PARSED-YEAR           PIC 9(4).
 01 WS-PARSED-MONTH          PIC 9(2).
 01 WS-PARSED-DAY            PIC 9(2).
 01 WS-PARSE-OK              PIC 9.

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

*> Lookup variables
 01 WS-LOOKUP-CODE           PIC X(8).
 01 WS-LOOKUP-FOUND          PIC 9.

*> Format arguments
 01 WS-FMT-COMPACTNESS       PIC 9.
*> An input's -LEN is its exact length, trailing blanks included, for
*> callers that know it (the CLI); 0 means the length without them.
 01 WS-FMT-DATE              PIC X(256).
 01 WS-FMT-DATE-LEN          PIC 9(4) VALUE 0.
 01 WS-FMT-AS-OF             PIC X(256).
 01 WS-FMT-AS-OF-LEN         PIC 9(4) VALUE 0.

*> Working temporaries for formatting
 01 WS-DAY-STR               PIC X(12).
 01 WS-FORMATTED-DAY         PIC X(64).
 01 WS-MONTH-NAME            PIC X(64).
 01 WS-PATTERN               PIC X(128).
 01 WS-YEAR-STR              PIC X(12).
 01 WS-YY-DIGITS             PIC 99.
 01 WS-WEEKDAY-NAME          PIC X(64).
 01 WS-EXC-FOUND             PIC 9.

*> Loop index
 01 WS-I                     PIC 9(3).
