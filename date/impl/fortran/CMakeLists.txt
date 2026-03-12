cmake_minimum_required(VERSION 3.20)
project(sayabledate_fortran LANGUAGES Fortran)

set(CMAKE_Fortran_MODULE_DIRECTORY ${CMAKE_BINARY_DIR}/modules)

add_library(sayabledate STATIC
  src/sayabledate_types.f90
  src/sayabledate.f90
  src/locales/sayabledate_locales.f90
)
target_include_directories(sayabledate PUBLIC ${CMAKE_Fortran_MODULE_DIRECTORY})

if(CMAKE_Fortran_COMPILER_ID MATCHES "GNU")
  target_compile_options(sayabledate PRIVATE
    -Wall -Wextra -Wpedantic -Werror
    -ffree-form -std=f2008
    -fimplicit-none
  )
endif()

add_executable(test_sayabledate test/test_format_date.f90)
target_link_libraries(test_sayabledate PRIVATE sayabledate)

if(CMAKE_Fortran_COMPILER_ID MATCHES "GNU")
  target_compile_options(test_sayabledate PRIVATE
    -Wall -Wextra -Wpedantic -Werror
    -ffree-form -std=f2008
    -fimplicit-none
  )
endif()

enable_testing()
add_test(NAME test_sayabledate COMMAND test_sayabledate)
