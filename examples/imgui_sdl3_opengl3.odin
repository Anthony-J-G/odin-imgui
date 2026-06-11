#+private
package examples

import gl "vendor:OpenGL"
import "core:fmt"
import "base:runtime"

import "vendor:sdl3"

import ImGui "../_build/dist"
import ImGui_Impl "../_build/dist/backends"


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
    ImGui.CreateContext()
    io := ImGui.GetIO()
    if (io != nil) {
        io.config_flags = { .Nav_Enable_Keyboard, .Nav_Enable_Gamepad, .Docking_Enable, .Viewports_Enable }
    }    

    ImGui.StyleColorsDark(nil)

    // Setup scaling
    style := ImGui.GetStyle();
    ImGui.Style_ScaleAllSizes(style, main_scale) // Bake a fixed style scale. (until we have a solution for dynamic style scaling, changing this requires resetting Style + calling this again)    
    // style.font = main_scale;        // Set initial font scale. (in docking branch: using io.ConfigDpiScaleFonts=true automatically overrides this for every window depending on the current monitor)

    if (io != nil && .Viewports_Enable in io.config_flags) {
        style.window_rounding = 0.0
        style.colors[ImGui.Col.Window_Bg].w = 1.0
    }

    ImGui_Impl.SDL3_InitForOpenGL(window, gl_ctx)
    ImGui_Impl.OpenGL3_Init()

    show_demo_window := true
    show_another_window := false
    clear_color := ImGui.Vec4{0.45, 0.55, 0.60, 1.00}

    done := false
    for (!done) {
        event: sdl3.Event
        for (sdl3.PollEvent(&event)) {
            ImGui_Impl.SDL3_ProcessEvent(&event);
            #partial switch (event.type) {
            case .QUIT: {done = true}
            case .WINDOW_CLOSE_REQUESTED: { if (event.window.windowID == sdl3.GetWindowID(window)) {done = true} }
            }
        }

        if (.MINIMIZED in sdl3.GetWindowFlags(window)) {
            sdl3.Delay(10)
            continue
        }

        ImGui_Impl.OpenGL3_NewFrame()
        ImGui_Impl.SDL3_NewFrame()
        ImGui.NewFrame()

        if (show_demo_window) { ImGui.ShowDemoWindow(&show_demo_window) }

        @(static) f: f32 = 0.0
        @(static) counter: i32 = 0

        if (ImGui.Begin("Hello, world")) {
            defer ImGui.End()

            ImGui.Text("This is some useful text.")
            ImGui.Checkbox("Demo window", &show_demo_window)
            ImGui.Checkbox("Another Window", &show_another_window)

            ImGui.SliderFloat("float", &f, 0.0, 1.0)
            ImGui.ColorEdit3("float", cast(^[3]f32)(&clear_color))

            if (ImGui.Button("Button")) { counter += 1 }
            ImGui.SameLine()
            ImGui.Text("counter = %d", counter)

            ImGui.Text("Application average %.3f ms/frame (%.1f FPS)", 1000.0 / io.framerate, io.framerate)
        }

        if (show_another_window && ImGui.Begin("Another Window", &show_another_window)) {
            defer ImGui.End()

            ImGui.Text("Hello from another window!")
            if (ImGui.Button("Close Me")) { show_another_window = false }
        }

        ImGui.Render()
        gl.Viewport(0, 0, cast(i32)io.display_size.x, cast(i32)io.display_size.y)
        gl.ClearColor(clear_color.x * clear_color.w, clear_color.y * clear_color.w, clear_color.z * clear_color.w, clear_color.w)
        gl.Clear(gl.COLOR_BUFFER_BIT)
        ImGui_Impl.OpenGL3_RenderDrawData(ImGui.GetDrawData())

        if (io != nil && .Viewports_Enable in io.config_flags) {
            backup_current_window := sdl3.GL_GetCurrentWindow()
            backup_current_context := sdl3.GL_GetCurrentContext()
            ImGui.UpdatePlatformWindows()
            ImGui.RenderPlatformWindowsDefault()
            sdl3.GL_MakeCurrent(backup_current_window, backup_current_context)
        }

        sdl3.GL_SwapWindow(window)
    }

}