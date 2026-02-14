local config = require("HitboxViewer.config.init")
local gui_util = require("HitboxViewer.gui.util")
local set = require("HitboxViewer.util.imgui.config_set"):new(config)

local this = {}

function this.draw()
    imgui.spacing()
    imgui.indent(2)
    imgui.push_item_width(gui_util.get_item_width())

    set:slider_int(
        gui_util.tr("menu.draw_settings.slider_draw_distance"),
        "mod.draw.distance",
        0,
        10000
    )
    set:checkbox(gui_util.tr("menu.draw_settings.box_outline"), "mod.draw.outline")

    imgui.begin_disabled(not config:get("mod.draw.outline"))
    set:color_edit(gui_util.tr("menu.draw_settings.color_outline"), "mod.draw.outline_color")
    imgui.end_disabled()
    set:color_edit(
        gui_util.tr("menu.draw_settings.color_highlight"),
        "mod.hurtboxes.color.highlight"
    )

    imgui.pop_item_width()
    imgui.unindent(2)
    imgui.spacing()
end

return this
