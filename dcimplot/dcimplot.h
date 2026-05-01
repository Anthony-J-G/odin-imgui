// implot, v1.0 for dear imgui, v1.92.7
// (headers)

// Library Version
// (Integer encoded as XYYZZ for use in #if preprocessor conditionals, e.g. '#if IMGUI_VERSION_NUM >= 12345')
#include "implot.h"
#ifndef DCIMPLOT_INTERNAL_GLUE_CODE
#define IMPLOT_VERSION       "1.0.0"
#endif // #ifndef DCIMPLOT_INTERNAL_GLUE_CODE
#ifndef DCIMPLOT_INTERNAL_GLUE_CODE
#define IMPLOT_VERSION_NUM   10000
#endif // #ifndef DCIMPLOT_INTERNAL_GLUE_CODE

/*

Index of this file:
// [SECTION] Header mess
// [SECTION] Forward declarations and basic types
// [SECTION] Texture identifiers (ImTextureID, ImTextureRef)
// [SECTION] Dear ImGui end-user API functions
// [SECTION] Flags & Enumerations
// [SECTION] Tables API flags and structures (ImGuiTableFlags, ImGuiTableColumnFlags, ImGuiTableRowFlags, ImGuiTableBgTarget, ImGuiTableSortSpecs, ImGuiTableColumnSortSpecs)
// [SECTION] Helpers: Debug log, Memory allocations macros, ImVector<>
// [SECTION] ImGuiStyle
// [SECTION] ImGuiIO
// [SECTION] Misc data structures (ImGuiInputTextCallbackData, ImGuiSizeCallbackData, ImGuiWindowClass, ImGuiPayload)
// [SECTION] Helpers (ImGuiOnceUponAFrame, ImGuiTextFilter, ImGuiTextBuffer, ImGuiStorage, ImGuiListClipper, Math Operators, ImColor)
// [SECTION] Multi-Select API flags and structures (ImGuiMultiSelectFlags, ImGuiMultiSelectIO, ImGuiSelectionRequest, ImGuiSelectionBasicStorage, ImGuiSelectionExternalStorage)
// [SECTION] Drawing API (ImDrawCallback, ImDrawCmd, ImDrawIdx, ImDrawVert, ImDrawChannel, ImDrawListSplitter, ImDrawFlags, ImDrawListFlags, ImDrawList, ImDrawData)
// [SECTION] Texture API (ImTextureFormat, ImTextureStatus, ImTextureRect, ImTextureData)
// [SECTION] Font API (ImFontConfig, ImFontGlyph, ImFontGlyphRangesBuilder, ImFontAtlasFlags, ImFontAtlas, ImFontBaked, ImFont)
// [SECTION] Viewports (ImGuiViewportFlags, ImGuiViewport)
// [SECTION] ImGuiPlatformIO + other Platform Dependent Interfaces (ImGuiPlatformMonitor, ImGuiPlatformImeData)
// [SECTION] Obsolete functions and types

*/

#pragma once

#ifdef __cplusplus
extern "C"
{
#endif

// Define attributes of all API symbols declarations (e.g. for DLL under Windows)
// CIMGUI_API is used for core imgui functions, CIMGUI_IMPL_API is used for the default backends files (imgui_impl_xxx.h)
// Using dear imgui via a shared library is not recommended: we don't guarantee backward nor forward ABI compatibility + this is a call-heavy library and function call overhead adds up.
#ifndef CIMPLOT_API
#define CIMPLOT_API
#endif // #ifndef CIMGUI_API
#ifndef CIMPLOT_IMPL_API
#define CIMPLOT_IMPL_API              CIMPLOT_API
#endif // #ifndef CIMGUI_IMPL_API

// Forward declarations: ImPlot layer
typedef struct ImVec2_t         ImVec2;
typedef struct ImPlotContext_t  ImPlotContext;                               // ImPlot context

typedef int ImPlotFlags;       // -> enum ImPlotFlags_     // Flags: Options for plots (see BeginPlot).

// ImVec2: 2D vector used to store positions, sizes etc. [Compile-time configurable type]
// - This is a frequently used type in the API. Consider using IM_VEC2_CLASS_EXTRA to create implicit cast from/to our preferred type.
// - Add '#define IMGUI_DEFINE_MATH_OPERATORS' before including this file (or in imconfig.h) to access courtesy maths operators for ImVec2 and ImVec4.
IM_MSVC_RUNTIME_CHECKS_OFF
struct ImVec2_t
{
    float x, y;
};

// ImVec4: 4D vector used to store clipping rectangles, colors etc. [Compile-time configurable type]
struct ImVec4_t
{
    float x, y, z, w;
};
IM_MSVC_RUNTIME_CHECKS_RESTORE


CIMPLOT_API ImPlotContext*  ImPlot_CreateContext(void);
CIMPLOT_API void            ImPlot_DestroyContext(ImPlotContext* ctx /* = NULL */);  // NULL = destroy current context
CIMPLOT_API ImPlotContext*  ImPlot_GetCurrentContext(void);
CIMPLOT_API void            ImPlot_SetCurrentContext(ImPlotContext* ctx);

CIMPLOT_API bool ImPlot_BeginPlot(const char* name, ImVec2 size, ImPlotFlags flags);
CIMPLOT_API void ImPlot_EndPlot(void);



#ifdef __cplusplus
}
#endif