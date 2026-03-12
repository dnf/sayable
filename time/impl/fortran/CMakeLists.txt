cmake_minimum_required(VERSION 3.20)
project(sayabletime_fortran LANGUAGES Fortran)

set(CMAKE_Fortran_MODULE_DIRECTORY ${CMAKE_BINARY_DIR}/modules)

add_library(sayabletime STATIC
  src/sayabletime_types.f90
  src/sayabletime.f90
  src/locales/sayabletime_locales.f90
)
target_include_directories(sayabletime PUBLIC ${CMAKE_Fortran_MODULE_DIRECTORY})

if(CMAKE_Fortran_COMPILER_ID MATCHES "GNU")
  target_compile_options(sayabletime PRIVATE
    -Wall -Wextra -Wpedantic -Werror
    -ffree-form -std=f2008
    -fimplicit-none
  )
endif()

add_executable(test_sayabletime test/test_format_time.f90)
target_link_libraries(test_sayabletime PRIVATE sayabletime)

if(CMAKE_Fortran_COMPILER_ID MATCHES "GNU")
  target_compile_options(test_sayabletime PRIVATE
    -Wall -Wextra -Wpedantic -Werror
    -ffree-form -std=f2008
    -fimplicit-none
  )
endif()

enable_testing()
add_test(NAME test_sayabletime COMMAND test_sayabletime)
