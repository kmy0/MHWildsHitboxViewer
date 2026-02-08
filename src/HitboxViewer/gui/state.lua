---@class GuiState
---@field combo GuiCombo
---@field set ImguiConfigSet

---@class (exact) GuiCombo
---@field condition_type Combo
---@field condition_state Combo
---@field extract Combo
---@field break_state Combo
---@field element Combo
---@field draw_state Combo
---@field shape Combo

local combo = require("HitboxViewer.gui.combo")
local config = require("HitboxViewer.config.init")
local config_set = require("HitboxViewer.util.imgui.config_set")
local data = require("HitboxViewer.data.init")
local util_table = require("HitboxViewer.util.misc.table")

local mod_enum = data.mod.enum

---@class GuiState
local this = {
    combo = {
        condition_type = combo:new(
            util_table.map_table(mod_enum.condition_type, function(o)
                return mod_enum.condition_type[o]
            end, function(o)
                return mod_enum.condition_type[o]
            end),
            function(a, b)
                return a.key < b.key
            end,
            nil,
            function(key)
                return config.lang:tr("mod.combo_condition_type." .. mod_enum.condition_type[key])
            end
        ),
        condition_state = combo:new(
            util_table.map_table(mod_enum.condition_state, function(o)
                return mod_enum.condition_state[o]
            end, function(o)
                return mod_enum.condition_state[o]
            end),
            function(a, b)
                return a.key < b.key
            end,
            nil,
            function(key)
                return config.lang:tr("mod.combo_condition_state." .. mod_enum.condition_state[key])
            end
        ),
        extract = combo:new(
            util_table.map_table(mod_enum.extract, function(o)
                return mod_enum.extract[o]
            end, function(o)
                return mod_enum.extract[o]
            end),
            function(a, b)
                return a.key < b.key
            end,
            nil,
            function(key)
                return config.lang:tr("mod.combo_extract." .. mod_enum.extract[key])
            end
        ),
        break_state = combo:new(
            util_table.map_table(mod_enum.break_state, function(o)
                return mod_enum.break_state[o]
            end, function(o)
                return mod_enum.break_state[o]
            end),
            function(a, b)
                return a.key < b.key
            end,
            nil,
            function(key)
                return config.lang:tr("mod.combo_break_state." .. mod_enum.break_state[key])
            end
        ),
        element = combo:new(
            util_table.map_table(mod_enum.element, function(o)
                return mod_enum.element[o]
            end, function(o)
                return mod_enum.element[o]
            end),
            function(a, b)
                return a.key < b.key
            end,
            nil,
            function(key)
                return config.lang:tr("mod.combo_element." .. mod_enum.element[key])
            end
        ),
        draw_state = combo:new(
            util_table.map_table(mod_enum.default_hurtbox_state, function(o)
                return mod_enum.default_hurtbox_state[o]
            end, function(o)
                return mod_enum.default_hurtbox_state[o]
            end),
            function(a, b)
                return a.key < b.key
            end,
            nil,
            function(key)
                return config.lang:tr(
                    "mod.combo_draw_state." .. mod_enum.default_hurtbox_state[key]
                )
            end
        ),
        shape = combo:new(
            mod_enum.shape_dummy,
            function(a, b)
                return a.key < b.key
            end,
            nil,
            function(key)
                return config.lang:tr("mod.combo_shape." .. mod_enum.shape_dummy[key])
            end
        ),
    },
    set = config_set:new(config),
}

function this.translate_combo()
    for _, c in
        pairs(this.combo --[[@as table<string, Combo>]])
    do
        c:translate()
    end
end

function this.init()
    this.translate_combo()
end

return this
