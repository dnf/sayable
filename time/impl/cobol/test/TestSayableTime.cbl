IDENTIFICATION DIVISION.
PROGRAM-ID. TEST-SAYABLE-TIME.

DATA DIVISION.
WORKING-STORAGE SECTION.

*> Command-line argument handling
 01 WS-ARG-COUNT            PIC 9(4).
 01 WS-RUN-ID               PIC X(20).

*> Test counters
 01 WS-TESTS-PASSED         PIC 9(4) VALUE 0.
 01 WS-TESTS-FAILED         PIC 9(4) VALUE 0.

*> Test working variables
 01 WS-TEST-NAME            PIC X(60).
 01 WS-TEST-EXPECTED        PIC X(256).
 01 WS-TEST-GOT-LEN         PIC 9(4).

COPY "src/Types.cbl".

PROCEDURE DIVISION.
MAIN-PROGRAM.
    ACCEPT WS-ARG-COUNT FROM ARGUMENT-NUMBER
    IF WS-ARG-COUNT > 0
        DISPLAY 1 UPON ARGUMENT-NUMBER
        ACCEPT WS-RUN-ID FROM ARGUMENT-VALUE
    ELSE
        MOVE SPACES TO WS-RUN-ID
    END-IF

    IF WS-RUN-ID = SPACES
        PERFORM RUN-ALL-TESTS
    ELSE
        PERFORM DISPATCH-TEST
    END-IF

    DISPLAY " "
    DISPLAY "=== Results ==="
    DISPLAY "Passed: " FUNCTION TRIM(WS-TESTS-PASSED)
    DISPLAY "Failed: " FUNCTION TRIM(WS-TESTS-FAILED)

    IF WS-TESTS-FAILED > 0
        MOVE 1 TO RETURN-CODE
    END-IF
    STOP RUN.
*> ============================================================
*> Assert helpers
*> ============================================================
ASSERT-EQ.
    IF FUNCTION TRIM(WS-FORMAT-RESULT) =
       FUNCTION TRIM(WS-TEST-EXPECTED)
        ADD 1 TO WS-TESTS-PASSED
    ELSE
        ADD 1 TO WS-TESTS-FAILED
        DISPLAY "FAIL [" FUNCTION TRIM(WS-TEST-NAME)
            "]: got """ FUNCTION TRIM(WS-FORMAT-RESULT)
            """, expected """ FUNCTION TRIM(WS-TEST-EXPECTED)
            """"
    END-IF
    .

ASSERT-NULL.
    IF FUNCTION TRIM(WS-FORMAT-RESULT) = SPACES
        ADD 1 TO WS-TESTS-PASSED
    ELSE
        ADD 1 TO WS-TESTS-FAILED
        DISPLAY "FAIL [" FUNCTION TRIM(WS-TEST-NAME)
            "]: expected empty, got """
            FUNCTION TRIM(WS-FORMAT-RESULT) """"
    END-IF
    .
*> ============================================================
*> Test dispatch — routes a test ID to its paragraph
*> ============================================================
DISPATCH-TEST.
    EVALUATE WS-RUN-ID
        WHEN "1.1"
            PERFORM RUN-1-1
        WHEN "1.2"
            PERFORM RUN-1-2
        WHEN "1.3"
            PERFORM RUN-1-3
        WHEN "1.4"
            PERFORM RUN-1-4
        WHEN "2.1"
            PERFORM RUN-2-1
        WHEN "2.2"
            PERFORM RUN-2-2
        WHEN "2.3"
            PERFORM RUN-2-3
        WHEN "2.4"
            PERFORM RUN-2-4
        WHEN "2.5"
            PERFORM RUN-2-5
        WHEN "2.6"
            PERFORM RUN-2-6
        WHEN "2.7"
            PERFORM RUN-2-7
        WHEN "2.8"
            PERFORM RUN-2-8
        WHEN "2.9"
            PERFORM RUN-2-9
        WHEN "2.10"
            PERFORM RUN-2-10
        WHEN "2.11"
            PERFORM RUN-2-11
        WHEN "3.1"
            PERFORM RUN-3-1
        WHEN "3.2"
            PERFORM RUN-3-2
        WHEN "3.3"
            PERFORM RUN-3-3
        WHEN "3.4"
            PERFORM RUN-3-4
        WHEN "4.1"
            PERFORM RUN-4-1
        WHEN "4.2"
            PERFORM RUN-4-2
        WHEN "5.1"
            PERFORM RUN-5-1
        WHEN "6.1"
            PERFORM RUN-6-1
        WHEN "7.1"
            PERFORM RUN-7-1
        WHEN "8.1"
            PERFORM RUN-8-1
        WHEN "8.2"
            PERFORM RUN-8-2
        WHEN OTHER
            DISPLAY "Unknown test: " FUNCTION TRIM(WS-RUN-ID)
            MOVE 1 TO WS-TESTS-FAILED
    END-EVALUATE
    .
*> ============================================================
*> Run all tests (when no argument is given)
*> ============================================================
RUN-ALL-TESTS.
    PERFORM RUN-1-1
    PERFORM RUN-1-2
    PERFORM RUN-1-3
    PERFORM RUN-1-4
    PERFORM RUN-2-1
    PERFORM RUN-2-2
    PERFORM RUN-2-3
    PERFORM RUN-2-4
    PERFORM RUN-2-5
    PERFORM RUN-2-6
    PERFORM RUN-2-7
    PERFORM RUN-2-8
    PERFORM RUN-2-9
    PERFORM RUN-2-10
    PERFORM RUN-2-11
    PERFORM RUN-3-1
    PERFORM RUN-3-2
    PERFORM RUN-3-3
    PERFORM RUN-3-4
    PERFORM RUN-4-1
    PERFORM RUN-4-2
    PERFORM RUN-5-1
    PERFORM RUN-6-1
    PERFORM RUN-7-1
    PERFORM RUN-8-1
    PERFORM RUN-8-2
    .
*> ============================================================
*> Individual test paragraphs
*> ============================================================

*> Test 1.1: format_time(null) -> null
RUN-1-1.
    MOVE "en" TO WS-LOOKUP-CODE
    PERFORM GET-LOCALE
    MOVE PT-NORMAL TO WS-FMT-COMPACTNESS
    MOVE SPACES TO WS-FMT-TIME
    PERFORM FORMAT-TIME
    MOVE "1.1" TO WS-TEST-NAME
    PERFORM ASSERT-NULL
    .

*> Test 1.2: format_time("") -> null
RUN-1-2.
    MOVE "en" TO WS-LOOKUP-CODE
    PERFORM GET-LOCALE
    MOVE PT-NORMAL TO WS-FMT-COMPACTNESS
    MOVE SPACES TO WS-FMT-TIME
    PERFORM FORMAT-TIME
    MOVE "1.2" TO WS-TEST-NAME
    PERFORM ASSERT-NULL
    .

*> Test 1.3: format_time("invalid") -> null
RUN-1-3.
    MOVE "en" TO WS-LOOKUP-CODE
    PERFORM GET-LOCALE
    MOVE PT-NORMAL TO WS-FMT-COMPACTNESS
    MOVE "invalid" TO WS-FMT-TIME
    PERFORM FORMAT-TIME
    MOVE "1.3" TO WS-TEST-NAME
    PERFORM ASSERT-NULL
    .

*> Test 1.4: format_time("25:00") -> null
RUN-1-4.
    MOVE "en" TO WS-LOOKUP-CODE
    PERFORM GET-LOCALE
    MOVE PT-NORMAL TO WS-FMT-COMPACTNESS
    MOVE "25:00" TO WS-FMT-TIME
    PERFORM FORMAT-TIME
    MOVE "1.4" TO WS-TEST-NAME
    PERFORM ASSERT-NULL
    .

*> Test 2.1: format_time("00:00") -> "midnight"
RUN-2-1.
    MOVE "en" TO WS-LOOKUP-CODE
    PERFORM GET-LOCALE
    MOVE PT-NORMAL TO WS-FMT-COMPACTNESS
    MOVE "00:00" TO WS-FMT-TIME
    PERFORM FORMAT-TIME
    MOVE "2.1" TO WS-TEST-NAME
    MOVE "midnight" TO WS-TEST-EXPECTED
    PERFORM ASSERT-EQ
    .

*> Test 2.2: format_time("12:00") -> "noon"
RUN-2-2.
    MOVE "en" TO WS-LOOKUP-CODE
    PERFORM GET-LOCALE
    MOVE PT-NORMAL TO WS-FMT-COMPACTNESS
    MOVE "12:00" TO WS-FMT-TIME
    PERFORM FORMAT-TIME
    MOVE "2.2" TO WS-TEST-NAME
    MOVE "noon" TO WS-TEST-EXPECTED
    PERFORM ASSERT-EQ
    .

*> Test 2.3: format_time("15:00") -> "three o'clock"
RUN-2-3.
    MOVE "en" TO WS-LOOKUP-CODE
    PERFORM GET-LOCALE
    MOVE PT-NORMAL TO WS-FMT-COMPACTNESS
    MOVE "15:00" TO WS-FMT-TIME
    PERFORM FORMAT-TIME
    MOVE "2.3" TO WS-TEST-NAME
    MOVE "three o'clock" TO WS-TEST-EXPECTED
    PERFORM ASSERT-EQ
    .

*> Test 2.4: format_time("14:15") -> "a quarter past two"
RUN-2-4.
    MOVE "en" TO WS-LOOKUP-CODE
    PERFORM GET-LOCALE
    MOVE PT-NORMAL TO WS-FMT-COMPACTNESS
    MOVE "14:15" TO WS-FMT-TIME
    PERFORM FORMAT-TIME
    MOVE "2.4" TO WS-TEST-NAME
    MOVE "a quarter past two" TO WS-TEST-EXPECTED
    PERFORM ASSERT-EQ
    .

*> Test 2.5: format_time("09:30") -> "half past nine"
RUN-2-5.
    MOVE "en" TO WS-LOOKUP-CODE
    PERFORM GET-LOCALE
    MOVE PT-NORMAL TO WS-FMT-COMPACTNESS
    MOVE "09:30" TO WS-FMT-TIME
    PERFORM FORMAT-TIME
    MOVE "2.5" TO WS-TEST-NAME
    MOVE "half past nine" TO WS-TEST-EXPECTED
    PERFORM ASSERT-EQ
    .

*> Test 2.6: format_time("10:45") -> "a quarter to eleven"
RUN-2-6.
    MOVE "en" TO WS-LOOKUP-CODE
    PERFORM GET-LOCALE
    MOVE PT-NORMAL TO WS-FMT-COMPACTNESS
    MOVE "10:45" TO WS-FMT-TIME
    PERFORM FORMAT-TIME
    MOVE "2.6" TO WS-TEST-NAME
    MOVE "a quarter to eleven" TO WS-TEST-EXPECTED
    PERFORM ASSERT-EQ
    .

*> Test 2.7: format_time("08:05") -> "five past eight"
RUN-2-7.
    MOVE "en" TO WS-LOOKUP-CODE
    PERFORM GET-LOCALE
    MOVE PT-NORMAL TO WS-FMT-COMPACTNESS
    MOVE "08:05" TO WS-FMT-TIME
    PERFORM FORMAT-TIME
    MOVE "2.7" TO WS-TEST-NAME
    MOVE "five past eight" TO WS-TEST-EXPECTED
    PERFORM ASSERT-EQ
    .

*> Test 2.8: format_time("16:55") -> "five to five"
RUN-2-8.
    MOVE "en" TO WS-LOOKUP-CODE
    PERFORM GET-LOCALE
    MOVE PT-NORMAL TO WS-FMT-COMPACTNESS
    MOVE "16:55" TO WS-FMT-TIME
    PERFORM FORMAT-TIME
    MOVE "2.8" TO WS-TEST-NAME
    MOVE "five to five" TO WS-TEST-EXPECTED
    PERFORM ASSERT-EQ
    .

*> Test 2.9: format_time("23:58") -> "midnight" (rounds to 0:00)
RUN-2-9.
    MOVE "en" TO WS-LOOKUP-CODE
    PERFORM GET-LOCALE
    MOVE PT-NORMAL TO WS-FMT-COMPACTNESS
    MOVE "23:58" TO WS-FMT-TIME
    PERFORM FORMAT-TIME
    MOVE "2.9" TO WS-TEST-NAME
    MOVE "midnight" TO WS-TEST-EXPECTED
    PERFORM ASSERT-EQ
    .

*> Test 2.10: format_time("07:22") -> "twenty past seven" (22 rounds to 20)
RUN-2-10.
    MOVE "en" TO WS-LOOKUP-CODE
    PERFORM GET-LOCALE
    MOVE PT-NORMAL TO WS-FMT-COMPACTNESS
    MOVE "07:22" TO WS-FMT-TIME
    PERFORM FORMAT-TIME
    MOVE "2.10" TO WS-TEST-NAME
    MOVE "twenty past seven" TO WS-TEST-EXPECTED
    PERFORM ASSERT-EQ
    .

*> Test 2.11: format_time("2025-01-15T14:15:00") -> "a quarter past two"
RUN-2-11.
    MOVE "en" TO WS-LOOKUP-CODE
    PERFORM GET-LOCALE
    MOVE PT-NORMAL TO WS-FMT-COMPACTNESS
    MOVE "2025-01-15T14:15:00" TO WS-FMT-TIME
    PERFORM FORMAT-TIME
    MOVE "2.11" TO WS-TEST-NAME
    MOVE "a quarter past two" TO WS-TEST-EXPECTED
    PERFORM ASSERT-EQ
    .

*> Test 3.1: format_time("14:15", short) -> "2:15 PM"
RUN-3-1.
    MOVE "en" TO WS-LOOKUP-CODE
    PERFORM GET-LOCALE
    MOVE PT-SHORT TO WS-FMT-COMPACTNESS
    MOVE "14:15" TO WS-FMT-TIME
    PERFORM FORMAT-TIME
    MOVE "3.1" TO WS-TEST-NAME
    MOVE "2:15 PM" TO WS-TEST-EXPECTED
    PERFORM ASSERT-EQ
    .

*> Test 3.2: format_time("09:30", short) -> "9:30 AM"
RUN-3-2.
    MOVE "en" TO WS-LOOKUP-CODE
    PERFORM GET-LOCALE
    MOVE PT-SHORT TO WS-FMT-COMPACTNESS
    MOVE "09:30" TO WS-FMT-TIME
    PERFORM FORMAT-TIME
    MOVE "3.2" TO WS-TEST-NAME
    MOVE "9:30 AM" TO WS-TEST-EXPECTED
    PERFORM ASSERT-EQ
    .

*> Test 3.3: format_time("00:00", short) -> "12:00 AM"
RUN-3-3.
    MOVE "en" TO WS-LOOKUP-CODE
    PERFORM GET-LOCALE
    MOVE PT-SHORT TO WS-FMT-COMPACTNESS
    MOVE "00:00" TO WS-FMT-TIME
    PERFORM FORMAT-TIME
    MOVE "3.3" TO WS-TEST-NAME
    MOVE "12:00 AM" TO WS-TEST-EXPECTED
    PERFORM ASSERT-EQ
    .

*> Test 3.4: format_time("12:00", short) -> "12:00 PM"
RUN-3-4.
    MOVE "en" TO WS-LOOKUP-CODE
    PERFORM GET-LOCALE
    MOVE PT-SHORT TO WS-FMT-COMPACTNESS
    MOVE "12:00" TO WS-FMT-TIME
    PERFORM FORMAT-TIME
    MOVE "3.4" TO WS-TEST-NAME
    MOVE "12:00 PM" TO WS-TEST-EXPECTED
    PERFORM ASSERT-EQ
    .

*> Test 4.1: format_time("14:15", compact) -> "2:15p"
RUN-4-1.
    MOVE "en" TO WS-LOOKUP-CODE
    PERFORM GET-LOCALE
    MOVE PT-COMPACT TO WS-FMT-COMPACTNESS
    MOVE "14:15" TO WS-FMT-TIME
    PERFORM FORMAT-TIME
    MOVE "4.1" TO WS-TEST-NAME
    MOVE "2:15p" TO WS-TEST-EXPECTED
    PERFORM ASSERT-EQ
    .

*> Test 4.2: format_time("09:30", compact) -> "9:30a"
RUN-4-2.
    MOVE "en" TO WS-LOOKUP-CODE
    PERFORM GET-LOCALE
    MOVE PT-COMPACT TO WS-FMT-COMPACTNESS
    MOVE "09:30" TO WS-FMT-TIME
    PERFORM FORMAT-TIME
    MOVE "4.2" TO WS-TEST-NAME
    MOVE "9:30a" TO WS-TEST-EXPECTED
    PERFORM ASSERT-EQ
    .

*> Test 5.1: German "15:30" -> "halb vier"
RUN-5-1.
    MOVE "de" TO WS-LOOKUP-CODE
    PERFORM GET-LOCALE
    MOVE PT-NORMAL TO WS-FMT-COMPACTNESS
    MOVE "15:30" TO WS-FMT-TIME
    PERFORM FORMAT-TIME
    MOVE "5.1" TO WS-TEST-NAME
    MOVE "halb vier" TO WS-TEST-EXPECTED
    PERFORM ASSERT-EQ
    .

*> Test 6.1: French "15:15" -> "trois heures et quart"
RUN-6-1.
    MOVE "fr" TO WS-LOOKUP-CODE
    PERFORM GET-LOCALE
    MOVE PT-NORMAL TO WS-FMT-COMPACTNESS
    MOVE "15:15" TO WS-FMT-TIME
    PERFORM FORMAT-TIME
    MOVE "6.1" TO WS-TEST-NAME
    MOVE "trois heures et quart" TO WS-TEST-EXPECTED
    PERFORM ASSERT-EQ
    .

*> Test 7.1: Japanese "15:30" -> special chars
RUN-7-1.
    MOVE "ja" TO WS-LOOKUP-CODE
    PERFORM GET-LOCALE
    MOVE PT-NORMAL TO WS-FMT-COMPACTNESS
    MOVE "15:30" TO WS-FMT-TIME
    PERFORM FORMAT-TIME
    MOVE "7.1" TO WS-TEST-NAME
    MOVE X"E4B889E69982E58D8A" TO WS-TEST-EXPECTED
    PERFORM ASSERT-EQ
    .

*> Test 8.1: Finnish "14:15" short -> "14.15" (dot separator)
RUN-8-1.
    MOVE "fi" TO WS-LOOKUP-CODE
    PERFORM GET-LOCALE
    MOVE PT-SHORT TO WS-FMT-COMPACTNESS
    MOVE "14:15" TO WS-FMT-TIME
    PERFORM FORMAT-TIME
    MOVE "8.1" TO WS-TEST-NAME
    MOVE "14.15" TO WS-TEST-EXPECTED
    PERFORM ASSERT-EQ
    .

*> Test 8.2: Finnish "00:00" short -> "0.00" (midnight dot)
RUN-8-2.
    MOVE "fi" TO WS-LOOKUP-CODE
    PERFORM GET-LOCALE
    MOVE PT-SHORT TO WS-FMT-COMPACTNESS
    MOVE "00:00" TO WS-FMT-TIME
    PERFORM FORMAT-TIME
    MOVE "8.2" TO WS-TEST-NAME
    MOVE "0.00" TO WS-TEST-EXPECTED
    PERFORM ASSERT-EQ
    .

COPY "src/SayableTime.cbl".
COPY "src/locales/Locales.cbl".
