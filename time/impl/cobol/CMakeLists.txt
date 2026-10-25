cmake_minimum_required(VERSION 3.16)
project(sayabletime_cobol NONE)

find_program(COBC cobc REQUIRED)

# ---------------------------------------------------------------------------
# Suppress Clang's -Winvalid-source-encoding in the generated C code.
#
# GnuCOBOL compiles COBOL -> C -> binary. Locale strings contain raw UTF-8
# (e.g. "三時半", "halb vier"). GnuCOBOL emits these as raw bytes in C string
# literals, which Clang flags with -Winvalid-source-encoding. The strings
# are correct -- they round-trip through compilation and produce valid UTF-8
# output at runtime. Even COBOL hex literals (X"E4B889E69982E58D8A") produce
# the same C output, so there is no way to avoid this at the COBOL source level.
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
    ${CMAKE_SOURCE_DIR}/src/SayableTime.cbl
    ${CMAKE_SOURCE_DIR}/src/locales/Locales.cbl
)

set(TEST_SOURCE ${CMAKE_SOURCE_DIR}/test/TestSayableTime.cbl)
set(TEST_EXECUTABLE ${CMAKE_BINARY_DIR}/test_sayabletime_cobol)

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
add_test(NAME "1.1_null-input" COMMAND ${TEST_EXECUTABLE} "1.1" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "1.2_empty-input" COMMAND ${TEST_EXECUTABLE} "1.2" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "1.3_invalid-input" COMMAND ${TEST_EXECUTABLE} "1.3" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "1.4_invalid-hour" COMMAND ${TEST_EXECUTABLE} "1.4" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "2.1_midnight" COMMAND ${TEST_EXECUTABLE} "2.1" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "2.2_noon" COMMAND ${TEST_EXECUTABLE} "2.2" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "2.3_three-oclock" COMMAND ${TEST_EXECUTABLE} "2.3" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "2.4_quarter-past" COMMAND ${TEST_EXECUTABLE} "2.4" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "2.5_half-past" COMMAND ${TEST_EXECUTABLE} "2.5" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "2.6_quarter-to" COMMAND ${TEST_EXECUTABLE} "2.6" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "2.7_five-past" COMMAND ${TEST_EXECUTABLE} "2.7" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "2.8_five-to" COMMAND ${TEST_EXECUTABLE} "2.8" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "2.9_round-to-midnight" COMMAND ${TEST_EXECUTABLE} "2.9" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "2.10_round-to-20" COMMAND ${TEST_EXECUTABLE} "2.10" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "2.11_iso-datetime" COMMAND ${TEST_EXECUTABLE} "2.11" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "3.1_short-pm" COMMAND ${TEST_EXECUTABLE} "3.1" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "3.2_short-am" COMMAND ${TEST_EXECUTABLE} "3.2" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "3.3_short-midnight" COMMAND ${TEST_EXECUTABLE} "3.3" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "3.4_short-noon" COMMAND ${TEST_EXECUTABLE} "3.4" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "4.1_compact-pm" COMMAND ${TEST_EXECUTABLE} "4.1" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "4.2_compact-am" COMMAND ${TEST_EXECUTABLE} "4.2" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "5.1_de-halb-vier" COMMAND ${TEST_EXECUTABLE} "5.1" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "6.1_fr-quart" COMMAND ${TEST_EXECUTABLE} "6.1" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "7.1_ja-half-hour" COMMAND ${TEST_EXECUTABLE} "7.1" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "9.1_digital-modes-keep-the-exact-minute" COMMAND ${TEST_EXECUTABLE} "9.1" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "9.2_digital-modes-keep-the-exact-minute" COMMAND ${TEST_EXECUTABLE} "9.2" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "10.1_one-digit-hour" COMMAND ${TEST_EXECUTABLE} "10.1" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "10.2_two-digit-hour" COMMAND ${TEST_EXECUTABLE} "10.2" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "10.3_leading-whitespace" COMMAND ${TEST_EXECUTABLE} "10.3" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "10.4_trailing-whitespace" COMMAND ${TEST_EXECUTABLE} "10.4" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "10.5_minutes-need-two-digits" COMMAND ${TEST_EXECUTABLE} "10.5" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "10.6_hour-out-of-range" COMMAND ${TEST_EXECUTABLE} "10.6" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "10.7_seconds-are-allowed-and-ignored" COMMAND ${TEST_EXECUTABLE} "10.7" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "10.8_iso-datetime-with-zone-suffix-ignored" COMMAND ${TEST_EXECUTABLE} "10.8" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "10.9_iso-datetime-with-an-impossible-date" COMMAND ${TEST_EXECUTABLE} "10.9" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
