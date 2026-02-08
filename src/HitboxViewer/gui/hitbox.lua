local config = require("HitboxViewer.config.init")
local data = require("HitboxViewer.data.init")
local e = require("HitboxViewer.util.game.enum")
local generic = require("HitboxViewer.gui.generic")
local gui_util = require("HitboxViewer.gui.util")
local util_imgui = require("HitboxViewer.util.imgui.init")
local util_table = require("HitboxViewer.util.misc.table")

local this = {}

local function options()
    local config_mod = config.current.mod

    util_imgui.tooltip_text(config.lang:tr("mod.tooltip_hitboxes_type"))
    util_imgui.tooltip_text(config.lang:tr("mod.tooltip_attack_log_type"))

    if imgui.tree_node(gui_util.tr("mod.tree_damage_type")) then
        generic.draw_box_type_options(
            util_table.keys(config_mod.hitboxes.damage_type.disable),
            "mod.hitboxes.damage_type",
            function(t, i, _)
                return e.new("app.HitDef.DAMAGE_TYPE")[t[i]] ~= nil
            end
        )
        imgui.tree_pop()
    end

    if imgui.tree_node(gui_util.tr("mod.tree_damage_angle")) then
        generic.draw_box_type_options(
            util_table.keys(config_mod.hitboxes.damage_angle.disable),
            "mod.hitboxes.damage_angle",
            function(t, i, _)
                return e.new("app.HitDef.DAMAGE_ANGLE")[t[i]] ~= nil
            end
        )

        imgui.tree_pop()
    end

    if imgui.tree_node(gui_util.tr("mod.tree_guard_type")) then
        generic.draw_box_type_options(
            util_table.keys(config_mod.hitboxes.guard_type.disable),
            "mod.hitboxes.guard_type",
            function(t, i, _)
                return e.new("app.Hit.GUARD_TYPE")[t[i]] ~= nil
            end
        )

        imgui.tree_pop()
    end

    if imgui.tree_node(gui_util.tr("mod.tree_misc_type")) then
        util_imgui.tooltip_text(config.lang:tr("mod.tooltip_evaluate_order"))
        util_imgui.tooltip_text(config.lang:tr("mod.tooltip_misc_type"))

        generic.draw_box_type_options(
            util_table.keys(config_mod.hitboxes.misc_type.disable),
            "mod.hitboxes.misc_type",
            function(t, i, _)
                return util_table.contains(data.custom_attack_type.sorted, t[i])
            end,
            function(a, b)
                return util_table.index(data.custom_attack_type.sorted, a)
                    < util_table.index(data.custom_attack_type.sorted, b)
            end
        )

        imgui.tree_pop()
    end
end

function this.draw()
    generic.draw_box_options(gui_util.tr("mod.header_hitboxes"), "mod.hitboxes", options)
end

return this
