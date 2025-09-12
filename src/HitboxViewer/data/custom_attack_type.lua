---@class CustomAttackType
---@field types table<string, fun(entry: AttackLogEntry): boolean>
---@field sorted string[]

local util_table = require("HitboxViewer.util.misc.table")

---@class CustomAttackType
local this = {
    types = {},
    sorted = {},
}

-- All possible 'entry' data is located at HitboxViewer/attack_log.lua
-- keep in mind that booleans are strings

function this.types.TerrainHitOnly(entry)
    return entry.more_data._TerrainHitOnly == "true"
end

function this.types.NoMotionValue(entry)
    return entry.motion_value == 0
end

function this.types.Parry(entry)
    local parry_damage = entry.more_data._ParryDamage
    return parry_damage and parry_damage > 0
end

function this.types.JustDodge(entry)
    return entry.resource_path
        == "GameDesign/Player/ActionData/Common/Collision/Collider/Shell/PlShell_Just_Dodge.rcol"
end

function this.types.AttackHurtbox(entry)
    return entry.userdata_type:is_a("app.col_user_data.DamageParam")
end

---@param entry AttackLogEntry
---@return string?
function this.check(entry)
    entry.misc_type = nil
    for _, key in ipairs(this.sorted) do
        if this.types[key](entry) then
            entry.misc_type = key
            return key
        end
    end
end

-- Evaluation order
-- this.sorted = util_table.keys(this.types)
-- table.sort(this.sorted)
this.sorted = {
    "JustDodge",
    "AttackHurtbox",
    "Parry",
    "NoMotionValue",
    "TerrainHitOnly",
}

return this
