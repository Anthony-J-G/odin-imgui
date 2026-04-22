#+private
package examples

import gl "vendor:OpenGL"
import "core:c"
import "core:time"
import "core:log"
import "base:runtime"
import "vendor:glfw"

import imgui "../dist"
import "../dist/imgui_impl_glfw"
import "../dist/imgui_impl_opengl3"

g_ctx: runtime.Context


glfw_error_callback :: proc "c" (error: i32, description: cstring) {
    context = g_ctx

    log.errorf("GLFW Error %d: %s\n", error, description)
}



main :: proc() {
    glfw.SetErrorCallback(glfw_error_callback)
    if !glfw.Init() { panic("glfw: initialization failed") }
    defer glfw.Terminate()

    glsl_version: cstring = "#version 130"
    glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, 3)
    glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, 0)
    glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, 0)

    window := glfw.CreateWindow(1280, 800, "Dear ImGui GLFW+OpenGL3 example", nil, nil)
    if window == nil { panic("") }
    glfw.MakeContextCurrent(window)
    glfw.SwapInterval(1)
    gl.load_up_to(3, 3, glfw.gl_set_proc_address)

    imgui.CHECKVERSION()
    imgui.create_context(nil)
    defer imgui.destroy_context(nil)

    imgui_impl_glfw.init_for_open_gl(window, true)
    imgui_impl_opengl3.init(glsl_version)

    for !glfw.WindowShouldClose(window) {
        glfw.PollEvents()
        if glfw.GetWindowAttrib(window, glfw.ICONIFIED) != 0{
            time.sleep(10)
            continue
        }

        imgui_impl_opengl3.new_frame()
        imgui_impl_glfw.new_frame()
        imgui.new_frame()
        {
            defer imgui.render()

            imgui.show_demo_window(nil)
        }        

        // Render
        w, h := glfw.GetFramebufferSize(window)
        gl.Viewport(0, 0, w, h)
        gl.ClearColor(0, 0, 0, 1)
        gl.Clear(gl.COLOR_BUFFER_BIT)
        imgui_impl_opengl3.render_draw_data(imgui.get_draw_data())        

        glfw.SwapBuffers(window)
    }
}