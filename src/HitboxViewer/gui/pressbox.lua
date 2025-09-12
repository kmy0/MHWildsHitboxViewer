local config = require("HitboxViewer.config.init")
local data = require("HitboxViewer.data.init")
local generic = require("HitboxViewer.gui.generic")
local gui_util = require("HitboxViewer.gui.util")
local util_table = require("HitboxViewer.util.misc.table")

local ace = data.ace

local this = {}

local function options()
    local config_mod = config.current.mod

    if imgui.tree_node(gui_util.tr("mod.tree_press_level")) then
        generic.draw_box_type_options(
            util_table.keys(config_mod.pressboxes.press_level.disable),
            "mod.pressboxes.press_level",
            function(t, i, j)
                return util_table.contains(util_table.values(ace.enum.press_level), t[i])
            end
        )

        imgui.tree_pop()
    end

    if imgui.tree_node(gui_util.tr("mod.tree_layer")) then
        generic.draw_box_type_options(
            util_table.keys(config_mod.pressboxes.layer.disable),
            "mod.pressboxes.layer",
            function(t, i, j)
                return util_table.contains(util_table.values(ace.enum.col_layer), t[i])
            end
        )

        imgui.tree_pop()
    end
end

function this.draw()
    generic.draw_box_options(gui_util.tr("mod.header_pressboxes"), "mod.pressboxes", options)
end

return this
