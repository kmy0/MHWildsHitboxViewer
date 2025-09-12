local config = require("HitboxViewer.config.init")
local game_data = require("HitboxViewer.util.game.data")
local util_table = require("HitboxViewer.util.misc.table")

local this = {
    gui = require("HitboxViewer.data.gui"),
    ace = require("HitboxViewer.data.ace"),
    mod = require("HitboxViewer.data.mod"),
    custom_attack_type = require("HitboxViewer.data.custom_attack_type"),
}

---@param type_def_name string
---@param table BoxSettings
---@param color integer?
---@param as_string boolean?
---@param ignore_values string[]?
---@param filter_regex string?
local function write_fields_to_config(
    type_def_name,
    table,
    color,
    as_string,
    ignore_values,
    filter_regex
)
    local co = coroutine.create(game_data.iter_fields)
    local status = true
    ---@type integer
    local data
    ---@type integer | string
    local name
    while status do
        status, name, data = coroutine.resume(co, type_def_name, as_string, ignore_values)
        if name and data and (not filter_regex or string.match(name, filter_regex)) then
            table.disable[name] = false
            if color then
                table.color[name] = color
                table.color_enable[name] = false
            end
        end
    end
end

---@param strings string[]
---@param table BoxSettings
---@param color integer?
---@param ignore_values string[]?
local function write_strings_to_config(strings, table, color, ignore_values)
    for _, name in ipairs(strings) do
        if ignore_values and util_table.contains(ignore_values, name) then
            goto continue
        end
        table.disable[name] = false
        if color then
            table.color[name] = color
            table.color_enable[name] = false
        end
        ::continue::
    end
end

---@return boolean
function this.init()
    game_data.get_enum("via.physics.ShapeType", this.ace.enum.shape)
    game_data.get_enum("app.Hit.ROD_EXTRACT", this.ace.enum.rod)
    game_data.get_enum("app.user_data.EmParamParts.MEAT_SLOT", this.ace.enum.meat_slot)
    game_data.get_enum("app.cEmModuleScar.cScarParts.STATE", this.ace.enum.scar)
    game_data.get_enum("app.HitDef.DAMAGE_TYPE", this.ace.enum.damage_type)
    game_data.get_enum("app.HitDef.CONDITION", this.ace.enum.attack_condition)
    game_data.get_enum("app.HitDef.DAMAGE_TYPE_CUSTOM", this.ace.enum.damage_type_custom)
    game_data.get_enum("app.HitDef.DAMAGE_ANGLE", this.ace.enum.damage_angle)
    game_data.get_enum("app.Hit.GUARD_TYPE", this.ace.enum.guard_type)
    game_data.get_enum("app.HitDef.ATTR", this.ace.enum.attack_attr)
    game_data.get_enum("app.Hit.ATTACK_PARAM_TYPE", this.ace.enum.attack_param)
    game_data.get_enum("app.HitDef.ACTION_TYPE", this.ace.enum.action_type)
    game_data.get_enum("app.HitDef.BATTLE_RIDING_ATTACK_TYPE", this.ace.enum.ride_attack_type)
    game_data.get_enum("app.EnemyDef.Damage.ENEMY_DAMAGE_TYPE", this.ace.enum.enemy_damage_type)
    game_data.get_enum("app.EnemyDef.ATTACK_FILTER_TYPE", this.ace.enum.attack_filter_type)
    game_data.get_enum("app.EnemyDef.Damage.FRIEND_HIT_TYPE", this.ace.enum.friend_hit_type)
    game_data.get_enum("app.OtomoDef.USE_OTOMO_TOOL_TYPE", this.ace.enum.otomo_tool_type)
    game_data.get_enum("app.user_data.EmParamParts.INDEX_CATEGORY", this.ace.enum.em_part_index)
    game_data.get_enum("app.HunterDef.STATUS_FLAG", this.ace.enum.hunter_status_flag)
    game_data.get_enum("app.PressDef.PRESS_LEVEL", this.ace.enum.press_level)
    game_data.get_enum("app.CollisionFilter.LAYER", this.ace.enum.col_layer)
    game_data.get_enum("app.EnemyDef.ATTACK_FILTER_TYPE", this.ace.enum.attack_filter_type)

    if
        util_table.any(
            this.ace.enum --[[@as table<string, table<integer, string>>]],
            function(key, value)
                return util_table.empty(value)
            end
        )
    then
        return false
    end

    local config_mod = config.default.mod

    write_fields_to_config(
        "app.HitDef.DAMAGE_TYPE",
        config_mod.hitboxes.damage_type,
        config.default_color
    )
    write_fields_to_config(
        "app.HitDef.DAMAGE_ANGLE",
        config_mod.hitboxes.damage_angle,
        config.default_color
    )
    write_fields_to_config(
        "app.Hit.GUARD_TYPE",
        config_mod.hitboxes.guard_type,
        config.default_color
    )
    write_fields_to_config(
        "app.PressDef.PRESS_LEVEL",
        config_mod.pressboxes.press_level,
        config.default_color
    )
    write_fields_to_config(
        "app.CollisionFilter.LAYER",
        config_mod.pressboxes.layer,
        config.default_color,
        nil,
        nil,
        "PRESS_.-"
    )
    write_strings_to_config(
        this.custom_attack_type.sorted,
        config_mod.hitboxes.misc_type,
        config.default_color
    )
    write_strings_to_config(
        util_table.sort(this.ace.map.guard_names),
        config_mod.hurtboxes.guard_type,
        config.default_highlight_color
    )

    return true
end

return this
