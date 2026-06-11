package generator

// Core
import "core:slice"
import "core:fmt"
import "core:strings"
import "core:encoding/json"
import "core:log"
import "core:mem"
import "core:mem/virtual"
import os "core:os/old"

Generator :: struct {
	// Allocator
	allocator:           mem.Allocator,
	tmp_arena:           mem.Arena,

	// Containers
	flags:               [dynamic]Enum_Definition,
	types_to_ignore:     []string,
	functions_to_ignore: []string,
	pointers_to_ignore:  []string,

	// Maps
	type_map:            map[string]string,
	identifier_map:      map[string]bool,
	replace_map:         map[string]string,
}

FLAG_TYPE 				:: "i32"
TAB_SPACE 				:: "    "
BUILD_DIR				:: "./_build/"
DEAR_BINDINGS_DIR		:: BUILD_DIR + "_deps/dear_bindings_dep-src/"
IMGUI_JSON 				:: DEAR_BINDINGS_DIR + "dcimgui.json"
IMGUI_ODIN 				:: BUILD_DIR + "dist/imgui.odin"


PLATFORM :: #config(PLATFORM, "")
RENDERER :: #config(RENDERER, "")


main :: proc() {
	context.logger = log.create_console_logger(opt = {.Terminal_Color, .Level})
	defer log.destroy_console_logger(context.logger)

	arena: virtual.Arena
	ensure(virtual.arena_init_growing(&arena) == nil, "Failed to initialize 'virtual.Arena'")
	defer virtual.arena_destroy(&arena)

	allocator := virtual.arena_allocator(&arena)

	gen := new(Generator, allocator)
	ensure(gen != nil, "Failed to allocate new 'Generator'")

	gen.allocator = allocator
	gen.flags.allocator = allocator
	gen.type_map.allocator = allocator
	gen.identifier_map.allocator = allocator
	gen.replace_map.allocator = allocator

	fill_type_map(gen)

	// Enough memory for the dcimgui.json
	tmp_ally_buf := make([]byte, 30 * mem.Megabyte, allocator)
	ensure(tmp_ally_buf != nil)
	mem.arena_init(&gen.tmp_arena, tmp_ally_buf[:])

	if !write_imgui(gen) { return }

	if slice.contains(VALID_PLATFORMS, PLATFORM) {
		write_imgui_backend(gen, PLATFORM)
	} else {
		log.errorf("Invalid ImGui Platform: %s", PLATFORM)
	}

	if slice.contains(VALID_RENDERERS, RENDERER) {
		write_imgui_backend(gen, RENDERER)
	} else {
		log.errorf("Invalid ImGui Renderer: %s", RENDERER)
	}
}


write_imgui :: proc(gen: ^Generator) -> (ok: bool) {
	file_allocator := mem.arena_allocator(&gen.tmp_arena)
	defer free_all(file_allocator)
	
	if os.exists(IMGUI_ODIN) {
		os.remove(IMGUI_ODIN)
	}	

	im := create_file_handle(IMGUI_ODIN, IMGUI_JSON, file_allocator)
	defer os.close(im.handle)

	write_package_name(im.handle, "imgui", nl = false)

	os.write_string(im.handle, IMGUI_FOREIGN_IMPORT)
	os.write_string(im.handle, MACRO_OVERRIDES)

	gen.functions_to_ignore = {"ImStr_FromCharStr"}
	defer gen.functions_to_ignore = {}

	write_defines(gen, im.handle, &im.data)
	write_enums(gen, im.handle, &im.data)
	write_typedefs(gen, im.handle, &im.data)
	write_structs(gen, im.handle, &im.data)
	write_procedures(gen, im.handle, &im.data)

	return true
}


write_imgui_backend :: proc(gen: ^Generator, backend: string) -> (ok: bool) {
	file_allocator := mem.arena_allocator(&gen.tmp_arena)
	defer free_all(file_allocator)
		
	// if os.exists(IMGUI_ODIN) { os.remove(IMGUI_ODIN) }

	json_sb: strings.Builder
	backend_json := fmt.sbprintf(&json_sb, DEAR_BINDINGS_DIR + "backends/dcimgui_impl_%s.json", backend)

	output_sb: strings.Builder
	output_path := fmt.sbprintf(&output_sb, BUILD_DIR + "dist/backends/imgui_impl_%s.odin", backend)

	im := create_file_handle(output_path, backend_json, file_allocator)
	defer os.close(im.handle)

	write_package_name(im.handle, "backends", nl = false)	

	write_package_import(im.handle, "./../", "ImGui")

	// Handle Backend Specific Imports (for projects in the O)
	if (strings.compare(backend, "sdl2") == 0) { write_package_import(im.handle, "vendor:sdl2", "SDL2") }
	else if (strings.compare(backend, "sdl3") == 0) { write_package_import(im.handle, "vendor:sdl3", "SDL3") }	
	else if (strings.compare(backend, "opengl2") == 0) { write_package_import(im.handle, "vendor:OpenGL", "gl") }
	else if (strings.compare(backend, "opengl3") == 0) { write_package_import(im.handle, "vendor:OpenGL", "gl") }
	else if (strings.compare(backend, "wgpu") == 0) { write_package_import(im.handle, "vendor:wgpu") }
	else { log.warnf("no extra imports for backend '%s' added", backend) }

	os.write_string(im.handle, BACKEND_FOREIGN_IMPORT)

	gen.functions_to_ignore = {"ImStr_FromCharStr"}
	defer gen.functions_to_ignore = {}

	// write_defines(gen, im.handle, &im.data)
	write_enums(gen, im.handle, &im.data)
	// write_typedefs(gen, im.handle, &im.data)
	write_structs(gen, im.handle, &im.data)
	write_procedures(gen, im.handle, &im.data)

	return true
}


File_Handle :: struct {
	data:   json.Value,
	handle: os.Handle,
}

create_file_handle :: proc(
	filename: string,
	json_path: string,
	allocator := context.allocator,
) -> File_Handle {
	json_file, json_file_ok := os.read_entire_file_from_filename(json_path, allocator)
	if !json_file_ok {
		log.panicf("Failed to load '%s' file!", json_path)
	}

	json_data, json_err := json.parse(json_file, allocator = allocator)
	if json_err != nil {
		log.errorf("Failed to parse '%s' file!", json_path)
		log.panicf("Json Error: %s", json_err)
	}

	file_handle, handle_err := os.open(filename, os.O_WRONLY | os.O_CREATE)
	if handle_err != nil {
		log.errorf("Failed to create '%s' file.", filename)
		log.panicf("Handle Error: %s", handle_err)
	}

	return {json_data, file_handle}
}
