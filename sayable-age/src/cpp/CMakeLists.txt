cmake_minimum_required(VERSION 3.14)
project(sayable-age
    VERSION 0.5.0
    DESCRIPTION "Human-friendly age formatting — how parents actually talk about little ones"
    HOMEPAGE_URL "https://github.com/dnf/sayable"
    LANGUAGES CXX
)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

add_library(sayableage
    src/sayableage.cpp
    src/locales/locales_a_e.cpp
    src/locales/locales_f_k.cpp
    src/locales/locales_l_r.cpp
    src/locales/locales_s_z.cpp
    src/locales/locales_registry.cpp
)
target_include_directories(sayableage PUBLIC include)

# Strict compiler warnings
target_compile_options(sayableage PRIVATE
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

# Installation
include(GNUInstallDirs)

install(TARGETS sayableage
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
)

install(DIRECTORY include/ DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})

# Tests
enable_testing()
add_executable(test_sayableage tests/test_format_age.cpp)
target_link_libraries(test_sayableage sayableage)
target_compile_options(test_sayableage PRIVATE
    -Wall
    -Wextra
    -Wpedantic
    -Werror
    -Wshadow
    -Wconversion
    -Wsign-conversion
)
add_test(NAME sayableage_tests COMMAND test_sayableage)
