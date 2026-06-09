#+private
package examples

import gl "vendor:OpenGL"
import "core:fmt"
import "base:runtime"

import "vendor:sdl3"

import ImGui "../_build/dist"
import "../_build/dist/imgui_impl_sdl3"
import "../_build/dist/imgui_impl_opengl3"



main :: proc() {
    // ImGui.CHECKVERSION()

    ImGui.create_context()
    io := ImGui.get_io()
    if (io != nil) {
        io.config_flags = { .Nav_Enable_Keyboard, .Nav_Enable_Gamepad }
    }

    
}