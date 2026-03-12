cmake_minimum_required(VERSION 3.20)
project(sayableduration_fortran LANGUAGES Fortran)

set(CMAKE_Fortran_MODULE_DIRECTORY ${CMAKE_BINARY_DIR}/modules)

add_library(sayableduration STATIC
  src/sayableduration_types.f90
  src/sayableduration.f90
  src/locales/sayableduration_locales.f90
)
target_include_directories(sayableduration PUBLIC ${CMAKE_Fortran_MODULE_DIRECTORY})

if(CMAKE_Fortran_COMPILER_ID MATCHES "GNU")
  target_compile_options(sayableduration PRIVATE
    -Wall -Wextra -Wpedantic -Werror
    -ffree-form -std=f2008
    -fimplicit-none
  )
endif()

add_executable(test_sayableduration test/test_format_duration.f90)
target_link_libraries(test_sayableduration PRIVATE sayableduration)

if(CMAKE_Fortran_COMPILER_ID MATCHES "GNU")
  target_compile_options(test_sayableduration PRIVATE
    -Wall -Wextra -Wpedantic -Werror
    -ffree-form -std=f2008
    -fimplicit-none
  )
endif()

enable_testing()
add_test(NAME test_sayableduration COMMAND test_sayableduration)
