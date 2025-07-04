---@class (exact) AceData
---@field enum AceEnum
---@field map AceMap

---@class (exact) AceEnum
---@field shape table<via.physics.ShapeType, string>
---@field rod table<app.Hit.ROD_EXTRACT, string>
---@field meat_slot table<app.user_data.EmParamParts.MEAT_SLOT, string>
---@field scar table<app.cEmModuleScar.cScarParts.STATE, string>
---@field damage_type table<app.HitDef.DAMAGE_TYPE, string>
---@field attack_condition table<app.HitDef.CONDITION, string>
---@field damage_type_custom table<app.HitDef.DAMAGE_TYPE_CUSTOM, string>
---@field damage_angle table<app.HitDef.DAMAGE_ANGLE, string>
---@field guard_type table<app.Hit.GUARD_TYPE, string>
---@field attack_attr table<app.HitDef.ATTR, string>
---@field attack_param table<app.Hit.ATTACK_PARAM_TYPE, string>
---@field action_type table<app.HitDef.ACTION_TYPE, string>
---@field ride_attack_type table<app.HitDef.BATTLE_RIDING_ATTACK_TYPE, string>
---@field enemy_damage_type table<app.EnemyDef.Damage.ENEMY_DAMAGE_TYPE, string>
---@field attack_filter_type table<app.EnemyDef.ATTACK_FILTER_TYPE, string>
---@field friend_hit_type table<app.EnemyDef.Damage.FRIEND_HIT_TYPE, string>
---@field otomo_tool_type table<app.OtomoDef.USE_OTOMO_TOOL_TYPE, string>
---@field em_part_index table<app.user_data.EmParamParts.INDEX_CATEGORY, string>
---@field hunter_status_flag table<app.HunterDef.STATUS_FLAG, string>
---@field press_level table<app.PressDef.PRESS_LEVEL, string>
---@field col_layer table<app.CollisionFilter.LAYER, string>

---@class (exact) AceMap
---@field meat_type_to_field_name table<string, string>
---@field char_type_to_name table<string, string>
---@field cMeatFields REField[]
---@field guard_name_to_field_name table<string, string>
---@field guard_name_to_angle table<string, number>
---@field guard_names string[]

---@class AceData
local this = {
    enum = {
        shape = {},
        rod = {},
        meat_slot = {},
        scar = {},
        damage_angle = {},
        damage_type = {},
        damage_type_custom = {},
        enemy_damage_type = {},
        attack_attr = {},
        attack_condition = {},
        action_type = {},
        attack_filter_type = {},
        attack_param = {},
        ride_attack_type = {},
        guard_type = {},
        friend_hit_type = {},
        otomo_tool_type = {},
        em_part_index = {},
        hunter_status_flag = {},
        press_level = {},
        col_layer = {},
    },
    map = {
        meat_type_to_field_name = {
            NORMAL = "_MeatGuidNormal",
            BREAK = "_MeatGuidBreak",
            CUSTOM1 = "_MeatGuidCustom1",
            CUSTOM2 = "_MeatGuidCustom2",
            CUSTOM3 = "_MeatGuidCustom3",
        },
        char_type_to_name = {
            ["app.HunterCharacter"] = "Hunter",
            ["app.EnemyBossCharacter"] = "BigMonster",
            ["app.OtomoCharacter"] = "Pet",
            ["app.EnemyZakoCharacter"] = "SmallMonster",
        },
        cMeatFields = sdk.find_type_definition("app.user_data.EmParamParts.cMeat"):get_fields(),

        guard_name_to_field_name = {
            GUARD = "_GuardDegree",
            GUARD_POINT = "_GuardDegree",
            POWER_GUARD = "_PowerGuardDegree",
            TECHNICAL_GUARD = "_AimGuardDegree",
            LASER_GUARD = "_GuardDegree",
        },
        guard_name_to_angle = {
            SUPER_ARMOR = 360.0,
            HYPER_ARMOR = 360.0,
        },
        -- sorted by check order
        guard_names = {
            "HYPER_ARMOR",
            "SUPER_ARMOR",
            "TECHNICAL_GUARD",
            "GUARD_POINT",
            "LASER_GUARD",
            "POWER_GUARD",
            "GUARD",
        },
    },
}

return this
