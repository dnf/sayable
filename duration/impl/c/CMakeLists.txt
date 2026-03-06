cmake_minimum_required(VERSION 3.16)
project(sayableduration_c LANGUAGES C)
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_EXTENSIONS OFF)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

file(GLOB LOCALE_SOURCES src/locales/*.c)

add_library(sayableduration_c STATIC
    src/sayableduration.c
    src/locales_registry.c
    ${LOCALE_SOURCES}
)
target_include_directories(sayableduration_c PUBLIC include PRIVATE src)
target_compile_options(sayableduration_c PRIVATE
    -Wall -Wextra -Wpedantic -Werror -Wshadow -Wconversion
    -Wsign-conversion -Wmissing-prototypes -Wstrict-prototypes
    -ffreestanding
)

add_executable(test_sayableduration_c tests/test_format_duration.c)
target_link_libraries(test_sayableduration_c PRIVATE sayableduration_c)
enable_testing()
add_test(NAME sayableduration_c_tests COMMAND test_sayableduration_c)
