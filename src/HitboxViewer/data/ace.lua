---@class (exact) AceData
---@field map AceMap

---@class (exact) AceMap
---@field meat_type_to_field_name table<string, string>
---@field char_type_to_name table<string, string>
---@field cMeatFields REField[]
---@field guard_name_to_field_name table<string, string>
---@field guard_name_to_angle table<string, number>
---@field guard_names string[]

---@class AceData
local this = {
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
