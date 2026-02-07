local config = require("HitboxViewer.config.init")
local dummybox = require("HitboxViewer.box.dummy")
local gui_util = require("HitboxViewer.gui.util")
local set = require("HitboxViewer.util.imgui.config_set"):new(config)
local state = require("HitboxViewer.gui.state")

local this = {}

function this.draw()
    imgui.spacing()
    imgui.indent(2)
    imgui.push_item_width(gui_util.get_item_width())

    local config_mod = config.current.mod
    set:combo("##dummy_shape_spawner", "mod.dummyboxes.combo_shape", state.combo.shape.values)

    imgui.same_line()

    if imgui.button(gui_util.tr("menu.draw_settings.button_spawn")) then
        dummybox.spawn(state.combo.shape:get_key(config_mod.dummyboxes.combo_shape))
    end

    imgui.same_line()

    if imgui.button(gui_util.tr("menu.draw_settings.button_clear")) then
        dummybox.clear()
    end

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
