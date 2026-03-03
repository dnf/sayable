cmake_minimum_required(VERSION 3.16)
project(parent_time_cli LANGUAGES C)
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_EXTENSIONS OFF)

add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/../src/c
                 ${CMAKE_CURRENT_BINARY_DIR}/parenttime_c)

add_executable(parent-time main.c)
target_link_libraries(parent-time PRIVATE parenttime_c)
target_compile_options(parent-time PRIVATE
    -Wall -Wextra -Wpedantic -Werror -Wshadow -Wconversion
)
