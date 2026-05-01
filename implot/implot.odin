package implot


when ODIN_OS == .Linux || ODIN_OS == .Darwin {
	@(require) foreign import stdcpp "system:c++"
}

when ODIN_OS == .Windows {
	// x86-64
	when ODIN_DEBUG && ODIN_ARCH == .amd64 {
        @(extra_linker_flags="/NODEFAULTLIB:libcmt")
		foreign import lib "../windows/imgui_x64_debug.lib"
	} else when !ODIN_DEBUG && ODIN_ARCH == .amd64 {
        @(extra_linker_flags="/NODEFAULTLIB:libcmt")
		foreign import lib "../windows/imgui_x64_release.lib"
	}

	// Arm64
	when ODIN_DEBUG && ODIN_ARCH == .arm64 {
        @(extra_linker_flags="/NODEFAULTLIB:libcmt")
		foreign import lib "../windows/imgui_arm64_debug.lib"
	} else when !ODIN_DEBUG && ODIN_ARCH == .arm64 {
        @(extra_linker_flags="/NODEFAULTLIB:libcmt")
		foreign import lib "../windows/imgui_arm64_release.lib"
	}
} else when ODIN_OS == .Linux {
	when ODIN_ARCH == .amd64 {
		foreign import lib "../linux/libimgui_linux_x64.a"
	} else {
		foreign import lib "../linux/libimgui_linux_arm64.a"
	}
} else when ODIN_OS == .Darwin {
	when ODIN_ARCH == .amd64 {
		foreign import lib "../darwin/libimgui_macosx_x64.a"
	} else {
		foreign import lib "../darwin/libimgui_macosx_arm64.a"
	}
}


// Forward declarations: ImGui layer
ImPlot_Context :: struct {}

Plot_Flags :: bit_set[Plot_Flag; i32]  // -> enum ImPlotFlags_     // Flags: Options for plots (see BeginPlot).


Vec2 :: struct {
    x: f32,
    y: f32,
}

Plot_Flag :: enum i32 {
    None          = 0,      // default
    NoTitle       = 1,      // the plot title will not be displayed (titles are also hidden if preceded 
                            // by double hashes, e.g. "##MyPlot")
    NoLegend      = 2,      // the legend will not be displayed
    NoMouseText   = 3,      // the mouse position, in plot coordinates, will not be displayed inside of the plot
    NoInputs      = 4,      // the user will not be able to interact with the plot
    NoMenus       = 5,     // the user will not be able to open context menus
    NoBoxSelect   = 6,     // the user will not be able to box-select
    NoFrame       = 7,     // the ImGui frame will not be rendered
    Equal         = 8,    // x and y axes pairs will be constrained to have the same units/pixel
    Crosshairs    = 9,    // the default mouse cursor will be replaced with a crosshair when hovered    
}
PLOT_FLAGS_CANVAS_ONLY :: Plot_Flags{ .NoTitle, .NoLegend, .NoMenus, .NoBoxSelect, .NoMouseText}


@(default_calling_convention = "c")
foreign lib {
    @(link_name = "ImPlot_CreateContext")
    create_context :: proc() -> ^ImPlot_Context ---
    
    @(link_name = "ImPlot_DestroyContext")
    destroy_context :: proc(ctx: ^ImPlot_Context = nil) ---

    @(link_name = "ImPlot_BeginPlot")
    begin_plot :: proc(title_id: cstring, size: Vec2 = {-1, 0}, flags: Plot_Flags = {})  -> bool ---

    @(link_name = "ImPlot_EndPlot")
    end_plot :: proc() ---
}