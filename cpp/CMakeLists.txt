cmake_minimum_required(VERSION 3.14)
project(parent-time VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

add_library(parenttime
    src/parenttime.cpp
    src/locales_a_e.cpp
    src/locales_f_k.cpp
    src/locales_l_r.cpp
    src/locales_s_z.cpp
)
target_include_directories(parenttime PUBLIC include)

# Strict compiler warnings
target_compile_options(parenttime PRIVATE
    -Wall
    -Wextra
    -Wpedantic
    -Werror
    -Wshadow
    -Wnon-virtual-dtor
    -Woverloaded-virtual
    -Wold-style-cast
    -Wcast-align
    -Wunused
    -Wconversion
    -Wsign-conversion
    -Wnull-dereference
    -Wdouble-promotion
    -Wformat=2
    -Wimplicit-fallthrough
)

# Tests
enable_testing()
add_executable(test_parenttime tests/test_format_age.cpp)
target_link_libraries(test_parenttime parenttime)
target_compile_options(test_parenttime PRIVATE
    -Wall
    -Wextra
    -Wpedantic
    -Werror
    -Wshadow
    -Wconversion
    -Wsign-conversion
)
add_test(NAME parenttime_tests COMMAND test_parenttime)
