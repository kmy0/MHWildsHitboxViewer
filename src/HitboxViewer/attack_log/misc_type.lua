local table_util = require "HitboxViewer.table_util"

local this = {
    ---@type string[]
    sorted = {}
}
---@type table<string, fun(entry: AttackLogEntry): boolean>
local types = {}
local focus_hitboxes = {
    [22474] = "Great Sword",
    [22482] = "Long Sword",
    [22476] = "SnS",
    [22477] = "Dual Blades",
    [22486] = "Hammer",
    [22489] = "Hunting Horn",
    [22490] = "Lance",
    [22491] = "Gunlance",
    [22492] = "Switch Axe",
    [22496] = "Charge Blade",
    [22499] = "Insect Glave"
}

function types._TerrainHitOnly(entry)
    return entry.more_data._TerrainHitOnly
end

function types.FocusMode(entry)
    return focus_hitboxes[entry.attack_id] ~= nil
end

---@param entry AttackLogEntry
---@return string?
function this.check(entry)
    entry.misc_type = nil
    for _, key in ipairs(this.sorted) do
        if types[key](entry) then
            entry.misc_type = key
            return key
        end
    end
end

this.sorted = table_util.keys(types, true)
return this
