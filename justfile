

configure PLATFORM RENDERER:
    # Run CMake Config
    cmake -B _build -G Ninja -DUSE_IMPLOT=1 -DPLATFORM={{ PLATFORM }} -DRENDERER={{ RENDERER }} -DCMAKE_EXPORT_COMPILE_COMMANDS=1

    # Set up dist directory
    - rm -rf _build/dist
    - mkdir  _build/dist
    - mkdir  _build/dist/include
    - mkdir  _build/dist/windows
    - mkdir  _build/dist/linux
    - mkdir  _build/dist/macos


example PLATFORM RENDERER:
    just package {{ PLATFORM }} {{ RENDERER }}
    odin run ./examples/imgui_{{ PLATFORM }}_{{ RENDERER }}.odin -file -debug


generate:
    odin run ./generator


package PLATFORM RENDERER:
    just configure {{ PLATFORM }} {{ RENDERER }}    
    just build

    cp -r imgui_impl_{{ PLATFORM }}/ ./_build/dist
    cp -r imgui_impl_{{ RENDERER }}/ ./_build/dist
    cp imgui.odin ./_build/dist
    # cp impl_enabled.odin ./_build/dist
    cp -r implot ./_build/dist
    cp LICENSE ./_build/dist
    
    # cp build/deps/imgui/*.h dist/include
    # cp build/generated/*.h dist/include
    

build:
    cmake --build _build --config Debug
    cp _build/imgui.lib _build/dist/windows/imgui_x64_debug.lib

    cmake --build _build --config Release
    cp _build/imgui.lib _build/dist/windows/imgui_x64_release.lib

