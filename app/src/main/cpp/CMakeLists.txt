cmake_minimum_required(VERSION 3.22.1)
project("librecuts_native")

add_library(native_processing SHARED
    native_processing.cpp
    image_utils.cpp
)

find_library(log-lib log)
find_library(jnigraphics-lib jnigraphics)

target_link_libraries(native_processing
    ${log-lib}
    ${jnigraphics-lib}
    android
)

target_compile_options(native_processing PRIVATE -O3 -fopenmp)
