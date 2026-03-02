cmake_minimum_required(VERSION 3.16)
project(parenttime_c LANGUAGES C)
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_EXTENSIONS OFF)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

file(GLOB LOCALE_SOURCES src/locales/*.c)

add_library(parenttime_c STATIC
    src/parenttime.c
    src/locales_registry.c
    ${LOCALE_SOURCES}
)
target_include_directories(parenttime_c PUBLIC include PRIVATE src)
target_compile_options(parenttime_c PRIVATE
    -Wall -Wextra -Wpedantic -Werror -Wshadow -Wconversion
    -Wsign-conversion -Wmissing-prototypes -Wstrict-prototypes
    -ffreestanding
)

add_executable(test_parenttime_c tests/test_format_age.c)
target_link_libraries(test_parenttime_c PRIVATE parenttime_c)
enable_testing()
add_test(NAME parenttime_c_tests COMMAND test_parenttime_c)
