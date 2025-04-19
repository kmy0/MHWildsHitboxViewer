local config = require("HitboxViewer.config")
local table_util = require("HitboxViewer.table_util")

local this = {
    gui = require("HitboxViewer.data.gui"),
    ace = require("HitboxViewer.data.ace"),
    runtime = require("HitboxViewer.data.runtime"),
    util = require("HitboxViewer.data.util"),
    custom_attack_type = require("HitboxViewer.data.custom_attack_type"),
}

---@param type_def_name string
---@param table table
---@param add_color_entry boolean
---@param as_string boolean?
---@param ignore_values string[]?
local function write_fields_to_config(type_def_name, table, add_color_entry, as_string, ignore_values)
    local co = coroutine.create(this.util.iter_fields)
    local status = true
    ---@type integer
    local data
    ---@type integer | string
    local name
    while status do
        status, name, data = coroutine.resume(co, type_def_name, as_string, ignore_values)
        if name and data then
            table.disable[name] = false
            if add_color_entry then
                table.color[name] = config.default_color
                table.color_enable[name] = false
            end
        end
    end
end

---@param strings string[]
---@param table table
---@param add_color_entry boolean
---@param ignore_values string[]?
local function write_strings_to_config(strings, table, add_color_entry, ignore_values)
    for _, name in ipairs(strings) do
        if ignore_values and table_util.table_contains(ignore_values, name) then
            goto continue
        end
        table.disable[name] = false
        if add_color_entry then
            table.color[name] = config.default_color
            table.color_enable[name] = false
        end
        ::continue::
    end
end

function this.init()
    this.util.get_enum("via.physics.ShapeType", this.ace.enum.shape)
    this.util.get_enum("app.Hit.ROD_EXTRACT", this.ace.enum.rod)
    this.util.get_enum("app.user_data.EmParamParts.MEAT_SLOT", this.ace.enum.meat_slot)
    this.util.get_enum("app.cEmModuleScar.cScarParts.STATE", this.ace.enum.scar)
    this.util.get_enum("app.HitDef.DAMAGE_TYPE", this.ace.enum.damage_type)
    this.util.get_enum("app.HitDef.CONDITION", this.ace.enum.attack_condition)
    this.util.get_enum("app.HitDef.DAMAGE_TYPE_CUSTOM", this.ace.enum.damage_type_custom)
    this.util.get_enum("app.HitDef.DAMAGE_ANGLE", this.ace.enum.damage_angle)
    this.util.get_enum("app.Hit.GUARD_TYPE", this.ace.enum.guard_type)
    this.util.get_enum("app.HitDef.ATTR", this.ace.enum.attack_attr)
    this.util.get_enum("app.Hit.ATTACK_PARAM_TYPE", this.ace.enum.attack_param)
    this.util.get_enum("app.HitDef.ACTION_TYPE", this.ace.enum.action_type)
    this.util.get_enum("app.HitDef.BATTLE_RIDING_ATTACK_TYPE", this.ace.enum.ride_attack_type)
    this.util.get_enum("app.EnemyDef.Damage.ENEMY_DAMAGE_TYPE", this.ace.enum.enemy_damage_type)
    this.util.get_enum("app.EnemyDef.ATTACK_FILTER_TYPE", this.ace.enum.attack_filter_type)
    this.util.get_enum("app.EnemyDef.Damage.FRIEND_HIT_TYPE", this.ace.enum.friend_hit_type)
    this.util.get_enum("app.OtomoDef.USE_OTOMO_TOOL_TYPE", this.ace.enum.otomo_tool_type)
    this.util.get_enum("app.user_data.EmParamParts.INDEX_CATEGORY", this.ace.enum.em_part_index)

    write_fields_to_config("app.HitDef.DAMAGE_TYPE", config.default.hitboxes.damage_type, true)
    write_fields_to_config("app.HitDef.DAMAGE_ANGLE", config.default.hitboxes.damage_angle, true)
    write_fields_to_config("app.Hit.GUARD_TYPE", config.default.hitboxes.guard_type, true)
    write_strings_to_config(this.custom_attack_type.sorted, config.default.hitboxes.misc_type, true)
end

return this
