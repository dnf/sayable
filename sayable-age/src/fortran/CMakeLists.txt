cmake_minimum_required(VERSION 3.16)
project(sayableage_fortran LANGUAGES Fortran)

set(CMAKE_Fortran_MODULE_DIRECTORY ${CMAKE_BINARY_DIR}/modules)

file(GLOB LOCALE_SOURCES src/locales/*.f90)

add_library(sayableage_fortran STATIC
    src/sayableage_types.f90
    src/sayableage.f90
    ${LOCALE_SOURCES}
)
target_include_directories(sayableage_fortran PUBLIC ${CMAKE_Fortran_MODULE_DIRECTORY})

# Enable strict warnings
if(CMAKE_Fortran_COMPILER_ID MATCHES "GNU")
    target_compile_options(sayableage_fortran PRIVATE
        -Wall -Wextra -Wpedantic -Werror
        -ffree-form -std=f2008
        -fimplicit-none
    )
elseif(CMAKE_Fortran_COMPILER_ID MATCHES "Intel")
    target_compile_options(sayableage_fortran PRIVATE
        -warn all -check all
    )
endif()

add_executable(test_sayableage_fortran test/test_format_age.f90)
target_link_libraries(test_sayableage_fortran PRIVATE sayableage_fortran)
target_include_directories(test_sayableage_fortran PRIVATE ${CMAKE_Fortran_MODULE_DIRECTORY})

enable_testing()
add_test(NAME sayableage_fortran_tests COMMAND test_sayableage_fortran)
