cmake_minimum_required(VERSION 3.16)
project(parenttime_fortran LANGUAGES Fortran)

set(CMAKE_Fortran_MODULE_DIRECTORY ${CMAKE_BINARY_DIR}/modules)

file(GLOB LOCALE_SOURCES src/locales/*.f90)

add_library(parenttime_fortran STATIC
    src/parenttime_types.f90
    src/parenttime.f90
    ${LOCALE_SOURCES}
)
target_include_directories(parenttime_fortran PUBLIC ${CMAKE_Fortran_MODULE_DIRECTORY})

# Enable strict warnings
if(CMAKE_Fortran_COMPILER_ID MATCHES "GNU")
    target_compile_options(parenttime_fortran PRIVATE
        -Wall -Wextra -Wpedantic -Werror
        -ffree-form -std=f2008
        -fimplicit-none
    )
elseif(CMAKE_Fortran_COMPILER_ID MATCHES "Intel")
    target_compile_options(parenttime_fortran PRIVATE
        -warn all -check all
    )
endif()

add_executable(test_parenttime_fortran test/test_format_age.f90)
target_link_libraries(test_parenttime_fortran PRIVATE parenttime_fortran)
target_include_directories(test_parenttime_fortran PRIVATE ${CMAKE_Fortran_MODULE_DIRECTORY})

enable_testing()
add_test(NAME parenttime_fortran_tests COMMAND test_parenttime_fortran)
