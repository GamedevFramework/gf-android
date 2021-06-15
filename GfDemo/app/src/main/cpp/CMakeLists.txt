cmake_minimum_required(VERSION 3.10.2)

set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE BOTH)

project("gfdemo")

# Include prebuilt libraries
list(APPEND CMAKE_FIND_ROOT_PATH "${CMAKE_SOURCE_DIR}/prebuilt/${CMAKE_ANDROID_ARCH_ABI}")
find_package(gf REQUIRED COMPONENTS graphics)
find_package(SDL2 REQUIRED)

add_library(gf-demo SHARED
  gf-demo.cc
)

find_library(log-lib log)

target_link_libraries(gf-demo
  ${log-lib}
  gf::graphics
  SDL2::SDL2
)