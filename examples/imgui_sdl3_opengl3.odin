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
    if (!sdl3.Init({.VIDEO, .GAMEPAD})) {
        fmt.panicf("SDL_Init(): %s", sdl3.GetError())
    }

    glsl_version: cstring = "#version 130"
    sdl3.GL_SetAttribute(sdl3.GL_CONTEXT_FLAGS, 0)
    sdl3.GL_SetAttribute(sdl3.GL_CONTEXT_PROFILE_MASK, cast(i32)sdl3.GL_CONTEXT_PROFILE_CORE)
    sdl3.GL_SetAttribute(sdl3.GL_CONTEXT_MAJOR_VERSION, 3)
    sdl3.GL_SetAttribute(sdl3.GL_CONTEXT_MINOR_VERSION, 0)

    // Create window with graphics context
    sdl3.GL_SetAttribute(sdl3.GL_DOUBLEBUFFER, 1)
    sdl3.GL_SetAttribute(sdl3.GL_DEPTH_SIZE, 24)
    sdl3.GL_SetAttribute(sdl3.GL_STENCIL_SIZE, 8)

    main_scale: f32 = sdl3.GetDisplayContentScale(sdl3.GetPrimaryDisplay())
    window_flags: sdl3.WindowFlags = { .OPENGL, .RESIZABLE, .HIDDEN, .HIGH_PIXEL_DENSITY }
    window := sdl3.CreateWindow(
        "Dear ImGui SDL3+OpenGL3 example", cast(i32)(1280 * main_scale), cast(i32)(800 * main_scale), window_flags
    )
    if (window == nil) {
        fmt.panicf("SDL_CreateWindow(): %s\n", sdl3.GetError())
    }

    gl_ctx := sdl3.GL_CreateContext(window)
    if (gl_ctx == nil) {
        fmt.panicf("SDL_GL_CreateContext(): %s\n", sdl3.GetError())
    }
    gl.load_up_to(3, 3, sdl3.gl_set_proc_address)

    sdl3.GL_MakeCurrent(window, gl_ctx)
    sdl3.GL_SetSwapInterval(1)
    sdl3.SetWindowPosition(window, sdl3.WINDOWPOS_CENTERED, sdl3.WINDOWPOS_CENTERED)
    sdl3.ShowWindow(window)

    // ImGui.CHECKVERSION()
    ImGui.create_context()
    io := ImGui.get_io()
    if (io != nil) {
        io.config_flags = { .Nav_Enable_Keyboard, .Nav_Enable_Gamepad }
    }

    ImGui.style_colors_dark(nil)

    // Setup scaling
    style := ImGui.get_style();
    ImGui.style_scale_all_sizes(style, main_scale) // Bake a fixed style scale. (until we have a solution for dynamic style scaling, changing this requires resetting Style + calling this again)    
    // style.font = main_scale;        // Set initial font scale. (in docking branch: using io.ConfigDpiScaleFonts=true automatically overrides this for every window depending on the current monitor)

    imgui_impl_sdl3.init_for_open_gl(window, gl_ctx)
    imgui_impl_opengl3.init(glsl_version)

    show_demo_window := true
    show_another_window := false
    clear_color := ImGui.Vec4{0.45, 0.55, 0.60, 1.00}

    done := false
    for (!done) {
        event: sdl3.Event
        for (sdl3.PollEvent(&event)) {
            #partial switch (event.type) {
            case .QUIT: {done = true}
            case .WINDOW_CLOSE_REQUESTED: { if (event.window.windowID == sdl3.GetWindowID(window)) {done = true} }
            }
        }

        if (.MINIMIZED in sdl3.GetWindowFlags(window)) {
            sdl3.Delay(10)
            continue
        }

        imgui_impl_opengl3.new_frame()
        imgui_impl_sdl3.new_frame()
        ImGui.new_frame()

        if (show_demo_window) {
            ImGui.show_demo_window(&show_demo_window)
        }

        ImGui.render()
        gl.Viewport(0, 0, cast(i32)io.display_size.x, cast(i32)io.display_size.y)
        gl.ClearColor(clear_color.x * clear_color.w, clear_color.y * clear_color.w, clear_color.z * clear_color.w, clear_color.w)
        gl.Clear(gl.COLOR_BUFFER_BIT)
        imgui_impl_opengl3.render_draw_data(ImGui.get_draw_data())
        sdl3.GL_SwapWindow(window)
    }

}