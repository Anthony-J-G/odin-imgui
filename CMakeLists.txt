include(FetchContent)
set(CMAKE_GENERATOR Ninja)
set(CMAKE_C_COMPILER clang)
set(CMAKE_CXX_COMPILER clang)

cmake_minimum_required(VERSION 3.31.5)
cmake_policy(SET CMP0091 NEW)

project(imgui)


FetchContent_Declare(
  imgui_dep
  GIT_REPOSITORY https://github.com/ocornut/imgui.git  
  GIT_TAG        b1bcb12a624af7509894c8e77dd47416997777fa # release-1.92.7
)
set(deps imgui_dep)

FetchContent_Declare(
  dear_bindings_dep
  URL https://github.com/dearimgui/dear_bindings/releases/download/DearBindings_v0.19_ImGui_v1.92.7-docking/DearBindings_v0.19_ImGui_v1.92.7-docking.zip
  URL_HASH        SHA256=6b3ba0bc70a1379f681e85c5173445c7d7fe0e966bfa11dd3449bdff5ab46e12 # release-1.92.7
)

if (USE_IMPLOT)
    FetchContent_Declare(
        implot_dep
        GIT_REPOSITORY https://github.com/epezent/implot.git
        GIT_TAG        524f9fcd48d76c13fdf94c5ffbba8787a1ff7e39 # release-1.0.0
    )
    list(APPEND deps implot_dep)
endif()

if (${PLATFORM} STREQUAL glfw)
    FetchContent_Declare(
        glfw_dep
        GIT_REPOSITORY https://github.com/glfw/glfw.git
        GIT_TAG        3.4
    )
    list(APPEND deps glfw_dep)
endif()

FetchContent_MakeAvailable(${deps})
FetchContent_MakeAvailable(dear_bindings_dep)

# Default Clang (C) Compiler Flags
SET (CMAKE_C_FLAGS_INIT                "-Wall -std=c11")
SET (CMAKE_C_FLAGS_DEBUG_INIT          "-g")
SET (CMAKE_C_FLAGS_MINSIZEREL_INIT     "-Os -DNDEBUG")
SET (CMAKE_C_FLAGS_RELEASE_INIT        "-O3 -DNDEBUG")
SET (CMAKE_C_FLAGS_RELWITHDEBINFO_INIT "-O2 -g")

# Default Clang (C++) Compiler Flags
SET (CMAKE_CXX_FLAGS_INIT                "-Wall -std=c++17")
SET (CMAKE_CXX_FLAGS_DEBUG_INIT          "-g -Zi")
SET (CMAKE_CXX_FLAGS_MINSIZEREL_INIT     "-Os -DNDEBUG")
SET (CMAKE_CXX_FLAGS_RELEASE_INIT        "-O3 -DNDEBUG")
SET (CMAKE_CXX_FLAGS_RELWITHDEBINFO_INIT "-O2 -g")

add_link_options(-fuse-ld=lld -g -Wl,/NODEFAULTLIB -Wl,/pdb:root)

set (CMAKE_CXX_STANDARD 11)

set(SOURCES "")

# Setup ImGui
file(GLOB IMGUI_SOURCES
    ${imgui_dep_SOURCE_DIR}/imgui_demo.cpp
    ${imgui_dep_SOURCE_DIR}/imgui_draw.cpp
    ${imgui_dep_SOURCE_DIR}/imgui_tables.cpp
    ${imgui_dep_SOURCE_DIR}/imgui_widgets.cpp
    ${imgui_dep_SOURCE_DIR}/imgui.cpp
    ${dear_bindings_dep_SOURCE_DIR}/dcimgui.cpp
    ${dear_bindings_dep_SOURCE_DIR}/dcimgui_internal.cpp
)
include_directories(${imgui_dep_SOURCE_DIR})
include_directories(${imgui_dep_SOURCE_DIR}/backends)
include_directories(${dear_bindings_dep_SOURCE_DIR})
include_directories(${dear_bindings_dep_SOURCE_DIR}/backends)
list(APPEND SOURCES ${IMGUI_SOURCES})
# ------------------------------------

# Setup ImGui Backends
if (${PLATFORM} STREQUAL glfw)
    include_directories(${glfw_dep_SOURCE_DIR}/include)
    list(APPEND SOURCES
        ${imgui_dep_SOURCE_DIR}/backends/imgui_impl_${PLATFORM}.cpp
        ${dear_bindings_dep_SOURCE_DIR}/backends/dcimgui_impl_${PLATFORM}.cpp
    )
endif()

if (${RENDERER} STREQUAL opengl3)
    list(APPEND SOURCES
        ${imgui_dep_SOURCE_DIR}/backends/imgui_impl_${RENDERER}.cpp
        ${dear_bindings_dep_SOURCE_DIR}/backends/dcimgui_impl_${RENDERER}.cpp
    )
endif()
# ------------------------------------

# Setup ImGui Extensions
if (USE_IMPLOT)
    file(GLOB IMPLOT_SOURCES
        ${implot_dep_SOURCE_DIR}/implot_demo.cpp
        ${implot_dep_SOURCE_DIR}/implot_items.cpp
        ${implot_dep_SOURCE_DIR}/implot.cpp
    )
    list(APPEND SOURCES ${IMPLOT_SOURCES})
endif()
# ------------------------------------

add_library(imgui STATIC ${SOURCES})
