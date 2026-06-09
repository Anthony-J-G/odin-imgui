package imgui_impl_wgpu

import im "./../"
import "vendor:wgpu"


when ODIN_OS == .Windows {
	// x86-64
	when ODIN_DEBUG && ODIN_ARCH == .amd64 {
		foreign import lib "../windows/imgui_x64_debug.lib"
	} else when !ODIN_DEBUG && ODIN_ARCH == .amd64 {
		foreign import lib "../windows/imgui_x64_release.lib"
	}

	// Arm64
	when ODIN_DEBUG && ODIN_ARCH == .arm64 {
		foreign import lib "../windows/imgui_arm64_debug.lib"
	} else when !ODIN_DEBUG && ODIN_ARCH == .arm64 {
		foreign import lib "../windows/imgui_arm64_release.lib"
	}
	
} else when ODIN_OS == .Linux {
	// x86-64
	when ODIN_DEBUG && ODIN_ARCH == .amd64 {
		foreign import lib "../linux/imgui_x64_debug.a"
	} else when !ODIN_DEBUG && ODIN_ARCH == .amd64 {
		foreign import lib "../linux/imgui_x64_release.a"
	}

	// Arm64
	when ODIN_DEBUG && ODIN_ARCH == .arm64 {
		foreign import lib "../linux/imgui_arm64_debug.a"
	} else when !ODIN_DEBUG && ODIN_ARCH == .arm64 {
		foreign import lib "../linux/imgui_arm64_release.a"
	}

} else when ODIN_OS == .Darwin {
	when ODIN_ARCH == .amd64 {
		foreign import lib "libimgui_macosx_x64.a"
	} else {
		foreign import lib "libimgui_macosx_arm64.a"
	}
}

Draw_Data :: im.Draw_Data

Init_Info :: struct {
	device:                     wgpu.Device,
	num_frames_in_flight:       i32,
	render_target_format:       wgpu.TextureFormat,
	depth_stencil_format:       wgpu.TextureFormat,
	pipeline_multisample_state: wgpu.MultisampleState,
}

INIT_INFO_DEFAULT :: Init_Info {
	num_frames_in_flight = 3,
	render_target_format = .Undefined,
	depth_stencil_format = .Undefined,
	pipeline_multisample_state = {count = 1, mask = max(u32), alphaToCoverageEnabled = false},
}

@(default_calling_convention = "c")
foreign lib {
	// Follow "Getting Started" link and check examples/ folder to learn about using backends!
	@(link_name = "ImGui_ImplWGPU_Init")
	init :: proc(init_info: ^Init_Info) -> bool ---
	@(link_name = "ImGui_ImplWGPU_Shutdown")
	shutdown :: proc() ---
	@(link_name = "ImGui_ImplWGPU_NewFrame")
	new_frame :: proc() ---
	@(link_name = "ImGui_ImplWGPU_RenderDrawData")
	render_draw_data :: proc(draw_data: ^Draw_Data, pass_encoder: wgpu.RenderPassEncoder) ---
	// Use if you want to reset your rendering device without losing Dear ImGui state.
	@(link_name = "ImGui_ImplWGPU_CreateDeviceObjects")
	create_device_objects :: proc() -> bool ---
	@(link_name = "ImGui_ImplWGPU_InvalidateDeviceObjects")
	invalidate_device_objects :: proc() ---
}
