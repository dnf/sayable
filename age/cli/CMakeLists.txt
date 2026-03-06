cmake_minimum_required(VERSION 3.16)
project(sayable_age_cli LANGUAGES C)
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_EXTENSIONS OFF)

add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/../impl/c
                 ${CMAKE_CURRENT_BINARY_DIR}/sayableage_c)

add_executable(sayable-age main.c)
target_link_libraries(sayable-age PRIVATE sayableage_c)
target_compile_options(sayable-age PRIVATE
    -Wall -Wextra -Wpedantic -Werror -Wshadow -Wconversion
)
