

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
    


[working-directory: "build"]
build:
    build.bat
    build.bat debug

