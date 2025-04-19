local attack_misc_type = require("HitboxViewer.attack_log.misc_type")
local config = require("HitboxViewer.config")
local table_util = require("HitboxViewer.table_util")

---@class Data
local this = {
    ---@type table<via.physics.ShapeType, string>
    ace_shape_enum = {},
    ---@type table<app.Hit.ROD_EXTRACT, string>
    ace_rod_enum = {},
    ---@type table<app.user_data.EmParamParts.MEAT_SLOT, string>
    ace_meat_slot_enum = {},
    ---@type table<app.cEmModuleScar.cScarParts.STATE, string>
    ace_scar_enum = {},
    ---@type table<app.HitDef.DAMAGE_TYPE, string>
    ace_damage_type_enum = {},
    ---@type table<app.HitDef.CONDITION, string>
    ace_attack_cond_enum = {},
    ---@type table<app.HitDef.DAMAGE_TYPE_CUSTOM, string>
    ace_damage_type_custom_enum = {},
    ---@type table<app.HitDef.DAMAGE_ANGLE, string>
    ace_damage_angle_enum = {},
    ---@type table<app.Hit.GUARD_TYPE, string>
    ace_guard_type_enum = {},
    ---@type table<app.HitDef.ATTR, string>
    ace_attack_attr_enum = {},
    ---@type table<app.Hit.ATTACK_PARAM_TYPE, string>
    ace_attack_param_enum = {},
    ---@type table<app.HitDef.ACTION_TYPE, string>
    ace_action_type_enum = {},
    ---@type table<app.HitDef.BATTLE_RIDING_ATTACK_TYPE, string>
    ace_ride_attack_type_enum = {},
    ---@type table<app.EnemyDef.Damage.ENEMY_DAMAGE_TYPE, string>
    ace_enemy_damage_type_enum = {},
    ---@type table<app.EnemyDef.ATTACK_FILTER_TYPE, string>
    ace_enemy_attack_filter_type_enum = {},
    ---@type table<app.EnemyDef.Damage.FRIEND_HIT_TYPE, string>
    ace_enemy_friend_hit_type_enum = {},
    ---@type table<app.OtomoDef.USE_OTOMO_TOOL_TYPE, string>
    ace_otomo_tool_type_enum = {},
    ---@type table<app.user_data.EmParamParts.INDEX_CATEGORY, string>
    ace_em_part_index_enum = {},
    cMeatFields = sdk.find_type_definition("app.user_data.EmParamParts.cMeat"):get_fields(),
    ---@type app.PlayerManager?
    playman = nil,
    ---@type app.GameFlowManager?
    flowman = nil,
    ---@type integer
    tick_count = 0,
    ---@type string
    name_missing = "???",
    ---@type string
    data_missing = " - ",
    ---@type table<string, boolean>
    missing_shapes = {},
}
local reverse_lookup = {}

---@enum MeatTypeToField
this.meat_type_to_field_name = {
    ["NORMAL"] = "_MeatGuidNormal",
    ["BREAK"] = "_MeatGuidBreak",
    ["CUSTOM1"] = "_MeatGuidCustom1",
    ["CUSTOM2"] = "_MeatGuidCustom2",
    ["CUSTOM3"] = "_MeatGuidCustom3",
}
---@enum CharTypeDefToBase
this.char_type_to_name = {
    ["app.HunterCharacter"] = "Hunter",
    ["app.EnemyBossCharacter"] = "BigMonster",
    ["app.OtomoCharacter"] = "Pet",
    ["app.EnemyZakoCharacter"] = "SmallMonster",
}
---@enum BaseCharType
this.base_char_enum = {
    ["Hunter"] = 1,
    ["BigMonster"] = 2,
    ["Pet"] = 3,
    ["SmallMonster"] = 4,
    ["OtherSmallMonster"] = 5,
}
---@enum ShapeType
this.shape_enum = {
    ["Sphere"] = 1,
    ["Capsule"] = 2,
    ["Box"] = 3,
    ["Cylinder"] = 4,
    ["Triangle"] = 5,
    ["ContinuousCapsule"] = 6,
    ["ContinuousSphere"] = 7,
}
---@enum ShapeDummy
this.shape_dummy = {
    [1] = "Sphere",
    [2] = "Capsule",
    [3] = "Box",
    [4] = "Cylinder",
    [5] = "Triangle",
}
---@enum CharType
this.char_enum = {
    ["Player"] = 1,
    ["MasterPlayer"] = 2,
    ["SmallMonster"] = 3,
    ["BigMonster"] = 4,
    ["Pet"] = 5,
    ["Npc"] = 6,
}
---@enum BoxType
this.box_enum = {
    ["Hurtbox"] = 1,
    ["Hitbox"] = 2,
    ["Scarbox"] = 3,
}
---@enum ConditionType
this.condition_type_enum = {
    ["Element"] = 1,
    ["Break"] = 2,
    ["Scar"] = 3,
    ["Weak"] = 4,
    ["Extract"] = 5,
}
---@enum ElementType
this.element_enum = {
    ["All"] = 1,
    ["Blow"] = 2,
    ["Dragon"] = 3,
    ["Fire"] = 4,
    ["Ice"] = 5,
    ["LightPlant"] = 6,
    ["Shot"] = 7,
    ["Slash"] = 8,
    ["Stun"] = 9,
    ["Thunder"] = 10,
    ["Water"] = 11,
}
---@enum ConditionState
this.condition_state = {
    ["None"] = 1,
    ["Highlight"] = 2,
    ["Hide"] = 3,
}
---@enum ExtractType
this.extract_enum = {
    ["RED"] = 1,
    ["WHITE"] = 2,
    ["ORANGE"] = 3,
    ["GREEN"] = 4,
}
---@enum ScarType
this.scar_enum = {
    ["NORMAL"] = 1,
    ["RAW"] = 2,
    ["TEAR"] = 3,
    ["OLD"] = 4,
    ["HEAL"] = 5,
}
---@enum BreakType
this.break_enum = {
    ["Yes"] = 1,
    ["No"] = 2,
    ["Broken"] = 3,
}
---@enum BoxState
this.box_state = {
    ["None"] = 1,
    ["Draw"] = 2,
    ["Dead"] = 3,
}
---@enum DefaultHurtboxState
this.default_hurtbox_enum = {
    ["Draw"] = 1,
    ["Hide"] = 2,
}
---@enum ConditionStateEnum
this.condition_state_enum = {
    ["Highlight"] = 1,
    ["Hide"] = 2,
}
---@enum GuiColors
this.colors = {
    bad = 0xff1947ff,
    good = 0xff47ff59,
    info = 0xff27f3f5,
}

---@param type_def_name string
---@param as_string boolean?
---@param ignore_values string[]?
local function iter_fields(type_def_name, as_string, ignore_values)
    local type_def = sdk.find_type_definition(type_def_name)
    if not type_def then
        return
    end

    local fields = type_def:get_fields()
    for _, field in pairs(fields) do
        local name = field:get_name()

        if
            string.lower(name) == "max"
            or string.lower(name) == "value__"
            or (ignore_values and table_util.table_contains(ignore_values, name))
        then
            goto continue
        end

        local data = field:get_data()
        if as_string then
            data = tostring(data)
        end
        coroutine.yield(name, data)
        ::continue::
    end
end

---@param type_def_name string
---@param table table
---@param add_color_entry boolean
---@param as_string boolean?
---@param ignore_values string[]?
local function write_fields_to_config(type_def_name, table, add_color_entry, as_string, ignore_values)
    local co = coroutine.create(iter_fields)
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

---@param type_def_name string
---@param table table
---@param as_string boolean?
---@param ignore_values string[]?
local function get_enum(type_def_name, table, as_string, ignore_values)
    local co = coroutine.create(iter_fields)
    local status = true
    ---@type integer
    local data
    ---@type integer | string
    local name
    while status do
        status, name, data = coroutine.resume(co, type_def_name, as_string, ignore_values)
        if name and data then
            table[data] = name
        end
    end
end

---@return app.PlayerManager
function this.get_playman()
    if not this.playman then
        local obj = sdk.get_managed_singleton("app.PlayerManager")
        ---@cast obj app.PlayerManager?
        this.playman = obj
    end
    return this.playman
end

---@return app.GameFlowManager
function this.get_flowman()
    if not this.flowman then
        local obj = sdk.get_managed_singleton("app.GameFlowManager")
        ---@cast obj app.GameFlowManager?
        this.flowman = obj
    end
    return this.flowman
end

---@return boolean
function this.in_game()
    if not this.get_flowman() then
        return false
    end
    return this.get_flowman():get_CurrentGameScene() > 0
end

---@return boolean
function this.in_transition()
    if not this.get_flowman() then
        return true
    end
    return this.get_flowman():get_NextGameStateType() ~= nil
end

---@generic K
---@generic V
---@param table table<K, V>
---@param value V
---@return K?
function this.reverse_lookup(table, value)
    if not reverse_lookup[table] then
        reverse_lookup[table] = {}
        for k, v in pairs(table) do
            reverse_lookup[table][v] = k
        end
    end
    return reverse_lookup[table][value]
end

---@return string?
function this.get_missing_shapes()
    local t = table_util.keys(this.missing_shapes, true)
    if next(t) then
        return table.concat(t, ", ")
    end
end

function this.init()
    get_enum("via.physics.ShapeType", this.ace_shape_enum)
    get_enum("app.Hit.ROD_EXTRACT", this.ace_rod_enum)
    get_enum("app.user_data.EmParamParts.MEAT_SLOT", this.ace_meat_slot_enum)
    get_enum("app.cEmModuleScar.cScarParts.STATE", this.ace_scar_enum)
    get_enum("app.HitDef.DAMAGE_TYPE", this.ace_damage_type_enum)
    get_enum("app.HitDef.CONDITION", this.ace_attack_cond_enum)
    get_enum("app.HitDef.DAMAGE_TYPE_CUSTOM", this.ace_damage_type_custom_enum)
    get_enum("app.HitDef.DAMAGE_ANGLE", this.ace_damage_angle_enum)
    get_enum("app.Hit.GUARD_TYPE", this.ace_guard_type_enum)
    get_enum("app.HitDef.ATTR", this.ace_attack_attr_enum)
    get_enum("app.Hit.ATTACK_PARAM_TYPE", this.ace_attack_param_enum)
    get_enum("app.HitDef.ACTION_TYPE", this.ace_action_type_enum)
    get_enum("app.HitDef.BATTLE_RIDING_ATTACK_TYPE", this.ace_ride_attack_type_enum)
    get_enum("app.EnemyDef.Damage.ENEMY_DAMAGE_TYPE", this.ace_enemy_damage_type_enum)
    get_enum("app.EnemyDef.ATTACK_FILTER_TYPE", this.ace_enemy_attack_filter_type_enum)
    get_enum("app.EnemyDef.Damage.FRIEND_HIT_TYPE", this.ace_enemy_friend_hit_type_enum)
    get_enum("app.OtomoDef.USE_OTOMO_TOOL_TYPE", this.ace_otomo_tool_type_enum)
    get_enum("app.user_data.EmParamParts.INDEX_CATEGORY", this.ace_em_part_index_enum)

    write_fields_to_config("app.HitDef.DAMAGE_TYPE", config.default.hitboxes.damage_type, true)
    write_fields_to_config("app.HitDef.DAMAGE_ANGLE", config.default.hitboxes.damage_angle, true)
    write_fields_to_config("app.Hit.GUARD_TYPE", config.default.hitboxes.guard_type, true)
    write_strings_to_config(attack_misc_type.sorted, config.default.hitboxes.misc_type, true)
end

return this
