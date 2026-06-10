package generator




VALID_PLATFORMS :: []string {
    "glfw",
    "null",
    "osx",
    "sdl2",
    "sdl3",
    "win32",
}


VALID_RENDERERS :: []string {    
    "dx11",
    "dx12",    
    "metal",
    "null",
    "opengl3",        
    "sdl3gpu",
    "sdlrenderer2",
    "sdlrenderer3",
    "vulkan",    
}


// odinfmt: disable
IMGUI_FOREIGN_IMPORT :: `
when ODIN_OS == .Linux || ODIN_OS == .Darwin {
	@(require) foreign import stdcpp "system:c++"
}

when ODIN_OS == .Windows {
	// x86-64
	when ODIN_DEBUG && ODIN_ARCH == .amd64 {
		@(extra_linker_flags="/NODEFAULTLIB:libcmt")
		foreign import lib "windows/imgui_x64_debug.lib"

	} else when !ODIN_DEBUG && ODIN_ARCH == .amd64 {
	 	@(extra_linker_flags="/NODEFAULTLIB:libcmt")
		foreign import lib "windows/imgui_x64_release.lib"
		
	}

	// Arm64
	when ODIN_DEBUG && ODIN_ARCH == .arm64 {
		@(extra_linker_flags="/NODEFAULTLIB:libcmt")
		foreign import lib "windows/imgui_arm64_debug.lib"

	} else when !ODIN_DEBUG && ODIN_ARCH == .arm64 {
	 	@(extra_linker_flags="/NODEFAULTLIB:libcmt")
		foreign import lib "windows/imgui_arm64_release.lib"

	}

} else when ODIN_OS == .Linux {
	when ODIN_ARCH == .amd64 {
		foreign import lib "libimgui_linux_x64.a"
	} else {
		foreign import lib "libimgui_linux_arm64.a"
	}
} else when ODIN_OS == .Darwin {
	when ODIN_ARCH == .amd64 {
		foreign import lib "libimgui_macosx_x64.a"
	} else {
		foreign import lib "libimgui_macosx_arm64.a"
	}
}
`
BACKEND_FOREIGN_IMPORT :: `
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
		foreign import lib "libimgui_linux_x64.a"
	} else {
		foreign import lib "libimgui_linux_arm64.a"
	}
} else when ODIN_OS == .Darwin {
	when ODIN_ARCH == .amd64 {
		foreign import lib "libimgui_macosx_x64.a"
	} else {
		foreign import lib "libimgui_macosx_arm64.a"
	}
}
`

MACRO_OVERRIDES :: `
CHECKVERSION :: proc() {
	ensure(
		DebugCheckVersionAndDataLayout(
			VERSION,
			size_of(IO),
			size_of(Style),
			size_of(Vec2),
			size_of(Vec4),
			size_of(Draw_Vert),
			size_of(Draw_Idx),
		),
	)
}

`
// odinfmt: enable