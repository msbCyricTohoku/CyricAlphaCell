cmake_minimum_required(VERSION 3.20)
project(cac LANGUAGES Fortran)

# compiler flags
set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -O3 -Wall -g -fopenmp")

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

# explicitly link X11 directly
target_link_libraries(cac.bin PRIVATE X11)
# the following dynamic way did not work for me, if needed use the below ones
#target_link_libraries(cac.bin PRIVATE ${X11_LIBRARIES})
#target_include_directories(cac.bin PRIVATE ${X11_INCLUDE_DIR})
