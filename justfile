

cmake-build PLATFORM RENDERER:
    # Run CMake Config
    cmake -B _build -G Ninja -DUSE_IMPLOT=1 -DPLATFORM={{ PLATFORM }} -DRENDERER={{ RENDERER }}

    # Set up dist directory
    - rm -rf _build/dist
    - mkdir  _build/dist
    - mkdir  _build/dist/windows
    - mkdir  _build/dist/linux
    - mkdir  _build/dist/macos
    cp imgui.odin ./_build/dist
    cp impl_enabled.odin ./_build/dist
    cp -r imgui_impl_{{PLATFORM}}/ ./_build/dist
    cp -r imgui_impl_{{RENDERER}}/ ./_build/dist

    # Generate C Bindings

    # Build Libraries
    cmake --build _build --config Debug
    mv _build/imgui.lib _build/dist/windows/imgui_x64_debug.lib

    cmake --build _build --config Release
    mv _build/imgui.lib _build/dist/windows/imgui_x64_release.lib


example PLATFORM RENDERER:
    odin run ./examples/imgui_{{ PLATFORM }}_{{ RENDERER }}.odin -file -debug


generate:
    odin run ./generator


package PLATFORM RENDERER:
    - rm -rf dist
    - mkdir dist
    premake5 --backends={{ PLATFORM }},{{ RENDERER }} vs2022
    just build
    mv windows dist
    cp -r imgui_impl_{{PLATFORM}}/ dist
    cp -r imgui_impl_{{RENDERER}}/ dist
    cp imgui.odin dist
    cp impl_enabled.odin dist
    cp LICENSE dist
    mkdir dist/include
    cp build/deps/imgui/*.h dist/include
    cp build/generated/*.h dist/include
    

[working-directory: "build"]
build:
    build.bat
    build.bat debug

