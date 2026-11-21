cmake_minimum_required(VERSION 3.20)
project(cac LANGUAGES Fortran)

option(ENABLE_X11 "Enable X11-based cacplotter support if available" ON)

find_package(OpenMP REQUIRED)

add_executable(cac.bin
    types.f90
    physics.f90
    geometry.f90
    source.f90
    tally.f90
    input.f90
    transport.f90
    main.f90
)

set_source_files_properties(main.f90 PROPERTIES Fortran_PREPROCESS ON)

if(ENABLE_X11)
    find_library(X11_LIB NAMES X11)
endif()

if(X11_LIB)
    message(STATUS "Found X11 (${X11_LIB}): enabling cacplotter.")
    target_sources(cac.bin PRIVATE cacplot.f90)
    target_link_libraries(cac.bin PRIVATE "${X11_LIB}")
    target_compile_definitions(cac.bin PRIVATE HAVE_X11)
else()
    message(STATUS "X11 not found (or disabled): building without cacplotter.")
endif()

target_compile_options(cac.bin PRIVATE
    -O3
    -march=native
    -ffast-math
    -fno-math-errno
    -fno-trapping-math
    -funroll-loops
    -g
)

include(CheckIPOSupported)
check_ipo_supported(RESULT ipo_supported)
if(ipo_supported)
    set_property(TARGET cac.bin PROPERTY INTERPROCEDURAL_OPTIMIZATION TRUE)
else()
    message(WARNING "IPO/LTO is not supported by this compiler. Falling back to standard linking.")
endif()

target_link_libraries(cac.bin PRIVATE OpenMP::OpenMP_Fortran)