

#include "imgui.h"
#include "imgui_internal.h"
#include "implot.h"

#include <stdio.h>

// Wrap this in a namespace to keep it separate from the C++ API

// This define prevents #defines in the header getting defined again (as they are already in the normal header above),
// and thus generating redefinition warnings
#define DCIMPLOT_INTERNAL_GLUE_CODE
namespace cimplot
{
#include "dcimplot.h"
}
#undef DCIMPLOT_INTERNAL_GLUE_CODE


static inline ::ImVec2 ConvertToCPP_ImVec2(const cimplot::ImVec2& src)
{
    ::ImVec2 dest;
    dest.x = src.x;
    dest.y = src.y;
    return dest;
}



CIMPLOT_API cimplot::ImPlotContext* cimplot::ImPlot_CreateContext()
{
    return reinterpret_cast<::cimplot::ImPlotContext*>(
        ::ImPlot::CreateContext()
    );
}


CIMPLOT_API void cimplot::ImPlot_DestroyContext(cimplot::ImPlotContext* ctx)
{
    ::ImPlot::DestroyContext(reinterpret_cast<::ImPlotContext*>(ctx));
}


CIMPLOT_API bool cimplot::ImPlot_BeginPlot(const char* name, cimplot::ImVec2 size, ImGuiWindowFlags flags)
{
    return ::ImPlot::BeginPlot(name, ConvertToCPP_ImVec2(size), flags);
}


CIMPLOT_API void cimplot::ImPlot_EndPlot(void)
{
    ::ImPlot::EndPlot();
}