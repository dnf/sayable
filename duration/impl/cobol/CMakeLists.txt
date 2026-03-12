cmake_minimum_required(VERSION 3.16)
project(sayableduration_cobol NONE)

find_program(COBC cobc REQUIRED)

# ---------------------------------------------------------------------------
# Suppress Clang's -Winvalid-source-encoding in the generated C code.
#
# GnuCOBOL compiles COBOL -> C -> binary. Locale strings contain raw UTF-8
# (e.g. "Stunde", "分", "heures"). GnuCOBOL emits these as raw bytes in C
# string literals, which Clang flags with -Winvalid-source-encoding. The
# strings are correct -- they round-trip through compilation and produce
# valid UTF-8 output at runtime.
#
# We append -Wno-invalid-source-encoding to cobc's COB_CFLAGS. We must
# preserve the default COB_CFLAGS (which contain platform-specific include
# paths for gmp.h and libcob headers), so we extract them at configure time.
# ---------------------------------------------------------------------------
execute_process(
    COMMAND ${COBC} --info
    OUTPUT_VARIABLE _COBC_INFO
    OUTPUT_STRIP_TRAILING_WHITESPACE
)
# Extract the COB_CFLAGS block (runs until the next COB_ variable).
string(REGEX MATCH "COB_CFLAGS[ \t]*:([^\n]*\n)([ \t]+[^\n]*\n)*" _COB_CFLAGS_RAW "${_COBC_INFO}")
# Strip the "COB_CFLAGS :" prefix, leaving just the flag values.
string(REGEX REPLACE "COB_CFLAGS[ \t]*:" "" _COB_CFLAGS_RAW "${_COB_CFLAGS_RAW}")
# Collapse whitespace/newlines into single spaces.
string(REGEX REPLACE "[ \t\n]+" " " _COB_CFLAGS_CLEAN "${_COB_CFLAGS_RAW}")
string(STRIP "${_COB_CFLAGS_CLEAN}" COB_CFLAGS_DEFAULT)
set(COB_CFLAGS_CUSTOM "${COB_CFLAGS_DEFAULT} -Wno-invalid-source-encoding")

set(COBOL_SOURCES
    ${CMAKE_SOURCE_DIR}/src/Types.cbl
    ${CMAKE_SOURCE_DIR}/src/SayableDuration.cbl
    ${CMAKE_SOURCE_DIR}/src/locales/Locales.cbl
)

set(TEST_SOURCE ${CMAKE_SOURCE_DIR}/test/TestSayableDuration.cbl)
set(TEST_EXECUTABLE ${CMAKE_BINARY_DIR}/test_sayableduration_cobol)

add_custom_command(
    OUTPUT ${TEST_EXECUTABLE}
    COMMAND ${CMAKE_COMMAND} -E env "COB_CFLAGS=${COB_CFLAGS_CUSTOM}"
        ${COBC} -free -x -Wall
        -o ${TEST_EXECUTABLE}
        ${TEST_SOURCE}
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    DEPENDS ${TEST_SOURCE} ${COBOL_SOURCES}
    COMMENT "Compiling COBOL test executable"
)

add_custom_target(cobol_test_target ALL
    DEPENDS ${TEST_EXECUTABLE}
)

enable_testing()
add_test(NAME "1.1_null-seconds" COMMAND ${TEST_EXECUTABLE} "1.1" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "1.2_negative-seconds" COMMAND ${TEST_EXECUTABLE} "1.2" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "1.3_since-null-start" COMMAND ${TEST_EXECUTABLE} "1.3" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "1.4_until-null-target" COMMAND ${TEST_EXECUTABLE} "1.4" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "1.5_since-asof-before-start" COMMAND ${TEST_EXECUTABLE} "1.5" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "1.6_until-target-in-past" COMMAND ${TEST_EXECUTABLE} "1.6" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "2.1_zero-just-now" COMMAND ${TEST_EXECUTABLE} "2.1" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "2.2_one-second" COMMAND ${TEST_EXECUTABLE} "2.2" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "2.3_45-seconds" COMMAND ${TEST_EXECUTABLE} "2.3" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "2.4_59-seconds" COMMAND ${TEST_EXECUTABLE} "2.4" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "3.1_one-minute" COMMAND ${TEST_EXECUTABLE} "3.1" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "3.2_minute-seconds" COMMAND ${TEST_EXECUTABLE} "3.2" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "3.3_four-minutes" COMMAND ${TEST_EXECUTABLE} "3.3" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "3.4_four-minutes-seconds" COMMAND ${TEST_EXECUTABLE} "3.4" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "4.1_five-minutes" COMMAND ${TEST_EXECUTABLE} "4.1" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "4.2_25-minutes" COMMAND ${TEST_EXECUTABLE} "4.2" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "4.3_59-minutes" COMMAND ${TEST_EXECUTABLE} "4.3" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "5.1_one-hour" COMMAND ${TEST_EXECUTABLE} "5.1" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "5.2_half-hour" COMMAND ${TEST_EXECUTABLE} "5.2" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "5.3_hours-minutes" COMMAND ${TEST_EXECUTABLE} "5.3" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "5.4_five-hours" COMMAND ${TEST_EXECUTABLE} "5.4" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "6.1_eight-hours" COMMAND ${TEST_EXECUTABLE} "6.1" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "6.2_23-hours" COMMAND ${TEST_EXECUTABLE} "6.2" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "7.1_one-day" COMMAND ${TEST_EXECUTABLE} "7.1" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "7.2_day-hours" COMMAND ${TEST_EXECUTABLE} "7.2" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "7.3_half-day" COMMAND ${TEST_EXECUTABLE} "7.3" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "7.4_five-days" COMMAND ${TEST_EXECUTABLE} "7.4" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "7.5_two-days" COMMAND ${TEST_EXECUTABLE} "7.5" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "8.1_one-week" COMMAND ${TEST_EXECUTABLE} "8.1" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "8.2_weeks-day" COMMAND ${TEST_EXECUTABLE} "8.2" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "8.3_four-weeks" COMMAND ${TEST_EXECUTABLE} "8.3" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "9.1_one-month" COMMAND ${TEST_EXECUTABLE} "9.1" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "9.2_three-months" COMMAND ${TEST_EXECUTABLE} "9.2" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "9.3_one-year" COMMAND ${TEST_EXECUTABLE} "9.3" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "9.4_year-months" COMMAND ${TEST_EXECUTABLE} "9.4" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "10.1_iso-half-hours" COMMAND ${TEST_EXECUTABLE} "10.1" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "10.2_iso-45-minutes" COMMAND ${TEST_EXECUTABLE} "10.2" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "11.1_since-just-now" COMMAND ${TEST_EXECUTABLE} "11.1" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "11.2_since-30-seconds" COMMAND ${TEST_EXECUTABLE} "11.2" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "11.3_since-45-minutes" COMMAND ${TEST_EXECUTABLE} "11.3" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "11.4_since-3-hours" COMMAND ${TEST_EXECUTABLE} "11.4" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "12.1_until-just-now" COMMAND ${TEST_EXECUTABLE} "12.1" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "12.2_until-20-minutes" COMMAND ${TEST_EXECUTABLE} "12.2" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "12.3_until-3-hours" COMMAND ${TEST_EXECUTABLE} "12.3" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "13.1_de-hour" COMMAND ${TEST_EXECUTABLE} "13.1" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "13.2_de-since" COMMAND ${TEST_EXECUTABLE} "13.2" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "14.1_fr-hours" COMMAND ${TEST_EXECUTABLE} "14.1" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "15.1_ja-minutes" COMMAND ${TEST_EXECUTABLE} "15.1" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "15.2_ja-since" COMMAND ${TEST_EXECUTABLE} "15.2" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "16.1_short-hour" COMMAND ${TEST_EXECUTABLE} "16.1" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "16.2_short-minute-seconds" COMMAND ${TEST_EXECUTABLE} "16.2" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "17.1_compact-hour" COMMAND ${TEST_EXECUTABLE} "17.1" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "17.2_compact-minute-seconds" COMMAND ${TEST_EXECUTABLE} "17.2" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
