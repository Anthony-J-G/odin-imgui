#+private
package examples

import "core:log"
import "base:runtime"

import ImGui "../_build/dist"
import ImGui_Impl "../_build/dist/backends"



main :: proc() {
    context.logger = log.create_console_logger()

    // ImGui.CHECKVERSION()

    ImGui.CreateContext()
    defer ImGui_Impl.Null_Shutdown()

    io := ImGui.GetIO()
    if (io != nil) {
        io.config_flags = { .Nav_Enable_Keyboard, .Nav_Enable_Gamepad }
    }

    ImGui_Impl.NullPlatform_Init()
    ImGui_Impl.NullRender_Init()
    defer ImGui_Impl.NullPlatform_Shutdown()
    defer ImGui_Impl.NullRender_Shutdown()

    for n := 0; n < 20; n = n + 1 {
        log.infof("New Frame() %d", n)
        ImGui_Impl.NullPlatform_NewFrame()
        ImGui_Impl.NullRender_NewFrame()
        ImGui.NewFrame()

        @(static) f: f32 = 0.0

        ImGui.Text("Hello, world!")
        ImGui.SliderFloat("float", &f, 0.0, 1.0)
        ImGui.Text("Application average %.3f ms/frame (%.1f FPS)", 1000.0 / io.framerate, io.framerate)
        ImGui.ShowDemoWindow(nil)

        ImGui.Render()
    }

    log.info("DestroyContext")    
}