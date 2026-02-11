local config = require("HitboxViewer.config.init")
local e = require("HitboxViewer.util.game.enum")
local util_game = require("HitboxViewer.util.game.init")
local util_table = require("HitboxViewer.util.misc.table")

local this = {
    gui = require("HitboxViewer.data.gui"),
    ace = require("HitboxViewer.data.ace"),
    mod = require("HitboxViewer.data.mod"),
    custom_attack_type = require("HitboxViewer.data.custom_attack_type"),
}

---@param type_def_name string
---@param t BoxSettings
---@param predicate (fun(key: string, value: any): boolean)?
---@param color integer?
local function write_fields_to_config(type_def_name, t, predicate, color)
    for name, _ in pairs(util_game.get_fields(type_def_name, predicate)) do
        t.disable[name] = false
        if color then
            t.color[name] = color
            t.color_enable[name] = false
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
    if
        not e.wrap_init(function()
            e.new("via.physics.ShapeType")
            e.new("app.Hit.ROD_EXTRACT")
            e.new("app.user_data.EmParamParts.MEAT_SLOT")
            e.new("app.cEmModuleScar.cScarParts.STATE")
            e.new("app.HitDef.DAMAGE_TYPE")
            e.new("app.HitDef.CONDITION")
            e.new("app.HitDef.DAMAGE_TYPE_CUSTOM")
            e.new("app.HitDef.DAMAGE_ANGLE")
            e.new("app.Hit.GUARD_TYPE")
            e.new("app.HitDef.ATTR")
            e.new("app.Hit.ATTACK_PARAM_TYPE")
            e.new("app.HitDef.ACTION_TYPE")
            e.new("app.HitDef.BATTLE_RIDING_ATTACK_TYPE")
            e.new("app.EnemyDef.Damage.ENEMY_DAMAGE_TYPE")
            e.new("app.EnemyDef.ATTACK_FILTER_TYPE")
            e.new("app.EnemyDef.Damage.FRIEND_HIT_TYPE")
            e.new("app.user_data.EmParamParts.INDEX_CATEGORY")
            e.new("app.HunterDef.STATUS_FLAG", function(key, _)
                return key ~= "ICON_MAX"
            end)
            e.new("app.PressDef.PRESS_LEVEL")
            e.new("app.CollisionFilter.LAYER")
            e.new("app.EnemyDef.ATTACK_FILTER_TYPE")
        end)
    then
        return false
    end

    local config_mod = config.default.mod

    write_fields_to_config(
        "app.HitDef.DAMAGE_TYPE",
        config_mod.hitboxes.damage_type,
        nil,
        config.default_color
    )
    write_fields_to_config(
        "app.HitDef.DAMAGE_ANGLE",
        config_mod.hitboxes.damage_angle,
        nil,
        config.default_color
    )
    write_fields_to_config(
        "app.Hit.GUARD_TYPE",
        config_mod.hitboxes.guard_type,
        nil,
        config.default_color
    )
    write_fields_to_config(
        "app.PressDef.PRESS_LEVEL",
        config_mod.pressboxes.press_level,
        nil,
        config.default_color
    )
    write_fields_to_config(
        "app.CollisionFilter.LAYER",
        config_mod.pressboxes.layer,
        function(key, _)
            return key:match("PRESS_.-")
        end,
        config.default_color
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
    config.current.mod = util_table.merge_t(config_mod, config.current.mod)

    return true
end

return this
