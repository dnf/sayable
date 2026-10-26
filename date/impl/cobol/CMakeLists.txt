cmake_minimum_required(VERSION 3.16)
project(sayabledate_cobol NONE)

find_program(COBC cobc REQUIRED)

# ---------------------------------------------------------------------------
# Suppress Clang's -Winvalid-source-encoding in the generated C code.
#
# GnuCOBOL compiles COBOL -> C -> binary. Locale strings contain raw UTF-8
# (e.g. "März", "марта", "مارس"). GnuCOBOL emits these as raw bytes in C
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
    ${CMAKE_SOURCE_DIR}/src/SayableDate.cbl
    ${CMAKE_SOURCE_DIR}/src/locales/Locales.cbl
)

set(TEST_SOURCE ${CMAKE_SOURCE_DIR}/test/TestSayableDate.cbl)
set(TEST_EXECUTABLE ${CMAKE_BINARY_DIR}/test_sayabledate_cobol)

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
add_test(NAME "1.4_relative-null-asof" COMMAND ${TEST_EXECUTABLE} "1.4" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "1.5_relative-null-date" COMMAND ${TEST_EXECUTABLE} "1.5" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "2.1_en-march-15th" COMMAND ${TEST_EXECUTABLE} "2.1" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "2.2_en-january-1st" COMMAND ${TEST_EXECUTABLE} "2.2" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "2.3_en-may-22nd" COMMAND ${TEST_EXECUTABLE} "2.3" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "2.4_en-july-3rd" COMMAND ${TEST_EXECUTABLE} "2.4" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "2.5_en-december-31st" COMMAND ${TEST_EXECUTABLE} "2.5" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "2.6_en-june-11th" COMMAND ${TEST_EXECUTABLE} "2.6" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "2.7_en-iso-datetime" COMMAND ${TEST_EXECUTABLE} "2.7" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "3.1_short-mar-15" COMMAND ${TEST_EXECUTABLE} "3.1" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "3.2_short-jan-1" COMMAND ${TEST_EXECUTABLE} "3.2" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "3.3_short-dec-25" COMMAND ${TEST_EXECUTABLE} "3.3" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "4.1_compact-3-15" COMMAND ${TEST_EXECUTABLE} "4.1" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "4.2_compact-1-1" COMMAND ${TEST_EXECUTABLE} "4.2" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "5.1_relative-today" COMMAND ${TEST_EXECUTABLE} "5.1" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "5.2_relative-tomorrow" COMMAND ${TEST_EXECUTABLE} "5.2" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "5.3_relative-yesterday" COMMAND ${TEST_EXECUTABLE} "5.3" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "5.4_relative-day-after-tomorrow" COMMAND ${TEST_EXECUTABLE} "5.4" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "5.5_relative-day-before-yesterday" COMMAND ${TEST_EXECUTABLE} "5.5" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "5.6_relative-this-weekday" COMMAND ${TEST_EXECUTABLE} "5.6" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "5.7_relative-this-thursday" COMMAND ${TEST_EXECUTABLE} "5.7" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "5.8_relative-last-weekday" COMMAND ${TEST_EXECUTABLE} "5.8" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "5.9_relative-next-saturday" COMMAND ${TEST_EXECUTABLE} "5.9" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "5.10_relative-next-thursday" COMMAND ${TEST_EXECUTABLE} "5.10" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "5.11_calendar-fallback-past" COMMAND ${TEST_EXECUTABLE} "5.11" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "5.12_calendar-fallback-future" COMMAND ${TEST_EXECUTABLE} "5.12" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "5.13_different-year-future" COMMAND ${TEST_EXECUTABLE} "5.13" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "5.14_different-year-past" COMMAND ${TEST_EXECUTABLE} "5.14" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "6.1_compact-relative-today" COMMAND ${TEST_EXECUTABLE} "6.1" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "6.2_compact-relative-tomorrow" COMMAND ${TEST_EXECUTABLE} "6.2" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "6.3_compact-skips-weekday" COMMAND ${TEST_EXECUTABLE} "6.3" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "6.4_compact-different-year" COMMAND ${TEST_EXECUTABLE} "6.4" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "7.1_de-format-date" COMMAND ${TEST_EXECUTABLE} "7.1" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "7.2_de-morgen" COMMAND ${TEST_EXECUTABLE} "7.2" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "7.3_de-uebermorgen" COMMAND ${TEST_EXECUTABLE} "7.3" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "7.4_de-diesen-mittwoch" COMMAND ${TEST_EXECUTABLE} "7.4" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "8.1_fr-1er" COMMAND ${TEST_EXECUTABLE} "8.1" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "8.2_fr-15-mars" COMMAND ${TEST_EXECUTABLE} "8.2" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "8.3_fr-demain" COMMAND ${TEST_EXECUTABLE} "8.3" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "9.1_ja-date" COMMAND ${TEST_EXECUTABLE} "9.1" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "9.2_ja-tomorrow" COMMAND ${TEST_EXECUTABLE} "9.2" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "9.3_ja-this-weekday" COMMAND ${TEST_EXECUTABLE} "9.3" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "10.1_ru-genitive-month" COMMAND ${TEST_EXECUTABLE} "10.1" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "10.2_ru-tomorrow" COMMAND ${TEST_EXECUTABLE} "10.2" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "11.1_ar-date" COMMAND ${TEST_EXECUTABLE} "11.1" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "11.2_ar-tomorrow" COMMAND ${TEST_EXECUTABLE} "11.2" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "12.1_es-date" COMMAND ${TEST_EXECUTABLE} "12.1" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "12.2_es-pasado-manana" COMMAND ${TEST_EXECUTABLE} "12.2" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "13.1_format-date-with-year-en-normal" COMMAND ${TEST_EXECUTABLE} "13.1" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "13.2_format-date-with-year-en-short" COMMAND ${TEST_EXECUTABLE} "13.2" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "13.3_format-date-with-year-en-compact" COMMAND ${TEST_EXECUTABLE} "13.3" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "13.4_two-digit-year-keeps-its-leading-zero" COMMAND ${TEST_EXECUTABLE} "13.4" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "13.5_format-date-with-year-fi-short" COMMAND ${TEST_EXECUTABLE} "13.5" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "14.1_format-date-sk-short" COMMAND ${TEST_EXECUTABLE} "14.1" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "14.2_format-date-cs-short" COMMAND ${TEST_EXECUTABLE} "14.2" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "14.3_format-date-uk-short" COMMAND ${TEST_EXECUTABLE} "14.3" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "14.4_format-relative-fi-short" COMMAND ${TEST_EXECUTABLE} "14.4" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "15.1_day-after-tomorrow" COMMAND ${TEST_EXECUTABLE} "15.1" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "15.2_day-before-yesterday" COMMAND ${TEST_EXECUTABLE} "15.2" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "15.3_day-after-tomorrow" COMMAND ${TEST_EXECUTABLE} "15.3" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "16.1_february-30-doesn-t-exist" COMMAND ${TEST_EXECUTABLE} "16.1" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "16.2_month-13" COMMAND ${TEST_EXECUTABLE} "16.2" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "16.3_unpadded-month-and-day" COMMAND ${TEST_EXECUTABLE} "16.3" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "16.4_surrounding-whitespace" COMMAND ${TEST_EXECUTABLE} "16.4" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "16.5_an-iso-datetime-only-the-date-part-is-us" COMMAND ${TEST_EXECUTABLE} "16.5" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "16.6_february-29-in-a-non-leap-year" COMMAND ${TEST_EXECUTABLE} "16.6" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_test(NAME "16.7_invalid-asof" COMMAND ${TEST_EXECUTABLE} "16.7" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
