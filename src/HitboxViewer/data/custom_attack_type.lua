---@class CustomAttackType
---@field types table<string, fun(entry: AttackLogEntry): boolean>
---@field sorted string[]
---@field custom_data CustomAttackTypeData

---@class (exact) CustomAttackTypeData
---@field focus_hitboxes table<integer, string>

local table_util = require("HitboxViewer.table_util")

---@class CustomAttackType
local this = {
    types = {},
    sorted = {},
    custom_data = {
        focus_hitboxes = {
            [315] = "Great Sword",
            [319] = "Long Sword",
            [317] = "SnS",
            [318] = "Dual Blades",
            [320] = "Hammer",
            [324] = "Hunting Horn",
            [327] = "Lance",
            [329] = "Gunlance",
            [332] = "Switch Axe",
            [335] = "Charge Blade",
            [339] = "Insect Glave",
        },
    },
}

function this.types._TerrainHitOnly(entry)
    return entry.more_data._TerrainHitOnly
end

function this.types.FocusMode(entry)
    return this.custom_data.focus_hitboxes[entry.attack_id] ~= nil
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

this.sorted = table_util.keys(this.types, true)
return this
