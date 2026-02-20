local config = require("HitboxViewer.config.init")
local gui_util = require("HitboxViewer.gui.util")
local set = require("HitboxViewer.util.imgui.config_set"):new(config)
local util_imgui = require("HitboxViewer.util.imgui.init")

local this = {}

function this.draw()
    if imgui.collapsing_header(gui_util.tr("mod.header_collisionboxes")) then
        local config_col = config.current.mod.collisionboxes

        set:checkbox(gui_util.tr("mod.box_disable_damage"), "mod.collisionboxes.disable_damage")
        imgui.begin_disabled(config_col.disable_damage)
        imgui.same_line()
        set:checkbox(
            gui_util.tr("mod.box_disable_damage_enemy"),
            "mod.collisionboxes.disable_damage_enemy"
        )
        imgui.same_line()
        set:checkbox(
            gui_util.tr("mod.box_disable_damage_player"),
            "mod.collisionboxes.disable_damage_player"
        )
        imgui.end_disabled()
        set:checkbox(gui_util.tr("mod.box_disable_press"), "mod.collisionboxes.disable_press")
        set:checkbox(gui_util.tr("mod.box_disable_sensor"), "mod.collisionboxes.disable_sensor")

        imgui.separator()

        imgui.begin_disabled(config_col.ignore_new)
        set:checkbox(gui_util.tr("mod.box_replace_existing"), "mod.collisionboxes.replace_existing")
        imgui.end_disabled()
        util_imgui.tooltip(config.lang:tr("mod.tooltip_box_replace_existing"), true)
        imgui.same_line()
        imgui.begin_disabled(config_col.replace_existing)
        set:checkbox(gui_util.tr("mod.box_ignore_new"), "mod.collisionboxes.ignore_new")
        imgui.end_disabled()
        util_imgui.tooltip(config.lang:tr("mod.tooltip_box_ignore_new"), true)
        set:checkbox(gui_util.tr("mod.box_ignore_failed"), "mod.collisionboxes.ignore_failed")
        util_imgui.tooltip(config.lang:tr("mod.tooltip_box_ignore_failed"), true)
        set:checkbox(gui_util.tr("mod.box_update_once"), "mod.collisionboxes.update_once")
        util_imgui.tooltip(config.lang:tr("mod.tooltip_box_update_once"), true)
        set:checkbox(
            gui_util.tr("mod.box_draw_contact_point"),
            "mod.collisionboxes.draw_contact_point"
        )
        set:color_edit(gui_util.tr("mod.color_col_a"), "mod.collisionboxes.color_col_a")
        set:color_edit(gui_util.tr("mod.color_col_b"), "mod.collisionboxes.color_col_b")
        set:color_edit(gui_util.tr("mod.color_col_point"), "mod.collisionboxes.color_col_point")
        set:slider_float(
            gui_util.tr("mod.slider_draw_dur"),
            "mod.collisionboxes.draw_dur",
            0.001,
            30,
            gui_util.seconds_to_minutes_string(config.current.mod.collisionboxes.draw_dur, "%.3f")
        )
    end
end

return this
