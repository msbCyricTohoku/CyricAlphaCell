cmake_minimum_required(VERSION 3.20)
project(cac LANGUAGES Fortran)

find_package(OpenMP REQUIRED)

add_executable(cac.bin
    types.f90
    physics.f90
    geometry.f90
    source.f90
    tally.f90
    input.f90
    cacplot.f90
    transport.f90
    main.f90
)

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

#explicitly link X11 directly
target_link_libraries(cac.bin PRIVATE X11)
# the following dynamic way did not work for me, if needed use the below ones
#target_link_libraries(cac.bin PRIVATE ${X11_LIBRARIES})
#target_include_directories(cac.bin PRIVATE ${X11_INCLUDE_DIR})
