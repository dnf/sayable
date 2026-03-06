cmake_minimum_required(VERSION 3.16)
project(sayabledate_c LANGUAGES C)
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_EXTENSIONS OFF)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

file(GLOB LOCALE_SOURCES src/locales/*.c)

add_library(sayabledate_c STATIC
    src/sayabledate.c
    src/locales_registry.c
    ${LOCALE_SOURCES}
)
target_include_directories(sayabledate_c PUBLIC include PRIVATE src)
target_compile_options(sayabledate_c PRIVATE
    -Wall -Wextra -Wpedantic -Werror -Wshadow -Wconversion
    -Wsign-conversion -Wmissing-prototypes -Wstrict-prototypes
    -ffreestanding
)

add_executable(test_sayabledate_c tests/test_format_date.c)
target_link_libraries(test_sayabledate_c PRIVATE sayabledate_c)
enable_testing()
add_test(NAME sayabledate_c_tests COMMAND test_sayabledate_c)
