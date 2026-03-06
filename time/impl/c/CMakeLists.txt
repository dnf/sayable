cmake_minimum_required(VERSION 3.16)
project(sayabletime_c LANGUAGES C)
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_EXTENSIONS OFF)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

file(GLOB LOCALE_SOURCES src/locales/*.c)

add_library(sayabletime_c STATIC
    src/sayabletime.c
    src/locales_registry.c
    ${LOCALE_SOURCES}
)
target_include_directories(sayabletime_c PUBLIC include PRIVATE src)
target_compile_options(sayabletime_c PRIVATE
    -Wall -Wextra -Wpedantic -Werror -Wshadow -Wconversion
    -Wsign-conversion -Wmissing-prototypes -Wstrict-prototypes
    -ffreestanding
)

add_executable(test_sayabletime_c tests/test_format_time.c)
target_link_libraries(test_sayabletime_c PRIVATE sayabletime_c)
enable_testing()
add_test(NAME sayabletime_c_tests COMMAND test_sayabletime_c)
