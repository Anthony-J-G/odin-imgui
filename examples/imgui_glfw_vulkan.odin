#+private
package examples

import "base:runtime"
import "core:slice"
import vk "vendor:vulkan"
import "vendor:glfw"

// Global Constants
ENABLE_VALIDATION_LAYERS ::
	#config(ENABLE_VALIDATION_LAYERS, ODIN_DEBUG) || #config(ENABLE_VALIDATION_LAYERS, ODIN_TEST)

DEVICE_EXTENSIONS := []cstring {
	vk.KHR_SWAPCHAIN_EXTENSION_NAME,
	// KHR_PORTABILITY_SUBSET_EXTENSION_NAME,
}

MAX_FRAMES_IN_FLIGHT :: 2


// Global State
g_window: glfw.WindowHandle

// Copy of the Odin context to be used in 'stateless' callback functions
// This should be set manually from the client code
g_ctx: runtime.Context
when ENABLE_VALIDATION_LAYERS {
    g_dbg_messenger: vk.DebugUtilsMessengerEXT
    g_dbg_messenger_callback: vk.ProcDebugUtilsMessengerCallbackEXT = default_vk_messenger_callback
    g_dbg_messenger_userdata: rawptr = nil
}

// Vulkan Global State
g_instance: vk.Instance
g_physical_device: vk.PhysicalDevice
g_device: vk.Device
g_surface: vk.SurfaceKHR
g_queue_family: Queue_Family_Indices
g_graphics_queue: vk.Queue
g_present_queue: vk.Queue

g_swapchain: vk.SwapchainKHR
g_swapchain_images: []vk.Image
g_swapchain_views: []vk.ImageView
g_swapchain_format: vk.SurfaceFormatKHR
g_swapchain_extent: vk.Extent2D
g_swapchain_frame_buffers: []vk.Framebuffer

g_render_pass: vk.RenderPass
g_pipeline_layout: vk.PipelineLayout
g_pipeline: vk.Pipeline

g_descriptor_pool: vk.DescriptorPool
g_descriptor_set_layout: vk.DescriptorSetLayout
g_descriptor_sets: [dynamic]vk.DescriptorSet

g_command_pool: vk.CommandPool
g_command_buffers: [MAX_FRAMES_IN_FLIGHT]vk.CommandBuffer



setup_vulkan :: proc(get_instance_proc_addr: rawptr, required_extensions: []cstring) -> (result: vk.Result) {
    vk.load_proc_addresses_global(get_instance_proc_addr)
    assert(vk.CreateInstance != nil, "vulkan function pointers not loaded")

    create_info := vk.InstanceCreateInfo {
		sType            = .INSTANCE_CREATE_INFO,
		pApplicationInfo = &vk.ApplicationInfo {
			sType = .APPLICATION_INFO,
			pApplicationName = "Hello Triangle",
			applicationVersion = vk.MAKE_VERSION(1, 0, 0),
			pEngineName = "No Engine",
			engineVersion = vk.MAKE_VERSION(1, 0, 0),
			apiVersion = vk.API_VERSION_1_0,
		},
	}    
    extensions := slice.clone_to_dynamic(required_extensions, context.temp_allocator)
    
    when ODIN_OS == .Darwin {
		create_info.flags |= {.ENUMERATE_PORTABILITY_KHR}
		append(&extensions, vk.KHR_PORTABILITY_ENUMERATION_EXTENSION_NAME)
	}

    when ENABLE_VALIDATION_LAYERS {
		create_info.ppEnabledLayerNames = raw_data([]cstring{"VK_LAYER_KHRONOS_validation"})
		create_info.enabledLayerCount = 1

		append(&extensions, vk.EXT_DEBUG_UTILS_EXTENSION_NAME)

		// Severity based on logger level.
		severity: vk.DebugUtilsMessageSeverityFlagsEXT
		if context.logger.lowest_level <= .Error {
			severity |= {.ERROR}
		}
		if context.logger.lowest_level <= .Warning {
			severity |= {.WARNING}
		}
		if context.logger.lowest_level <= .Info {
			severity |= {.INFO}
		}
		if context.logger.lowest_level <= .Debug {
			severity |= {.VERBOSE}
		}		

		dbg_create_info := vk.DebugUtilsMessengerCreateInfoEXT {
			sType           = .DEBUG_UTILS_MESSENGER_CREATE_INFO_EXT,
			messageSeverity = severity,
			messageType     = {.GENERAL, .VALIDATION, .PERFORMANCE, /* .DEVICE_ADDRESS_BINDING */}, // all of them.
			pfnUserCallback = g_dbg_messenger_callback,
			pUserData 		= g_dbg_messenger_userdata,
		}
		create_info.pNext = &dbg_create_info
	}

    create_info.enabledExtensionCount = u32(len(extensions))
	create_info.ppEnabledExtensionNames = raw_data(extensions)

	result = vk.CreateInstance(&create_info, nil, &g_instance)
    if result != .SUCCESS { return result }
	vk.load_proc_addresses_instance(g_instance)

	when ENABLE_VALIDATION_LAYERS {
		result = vk.CreateDebugUtilsMessengerEXT(g_instance, &dbg_create_info, nil, &g_dbg_messenger)
	}    

    return result
}


main :: proc() {
    // glfw.SetErrorCallback
    if !glfw.Init() {
        panic("couldn't initialize GLFW")
    }

    g_window = glfw.CreateWindow(1280, 800, "Dear ImGui GLFW+Vulkan example", nil, nil)
    if !glfw.VulkanSupported() {
        panic("GLFW doesn't support Vulkan")    
    }

    setup_vulkan(rawptr(glfw.GetInstanceProcAddress), glfw.GetRequiredInstanceExtensions())

    // Create Window Surface


}