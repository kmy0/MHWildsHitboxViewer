---@class CustomAttackType
---@field types table<string, fun(entry: AttackLogEntry): boolean>
---@field sorted string[]

local table_util = require("HitboxViewer.table_util")

---@class CustomAttackType
local this = {
    types = {},
    sorted = {},
}

function this.types._TerrainHitOnly(entry)
    return entry.more_data._TerrainHitOnly == "true"
end

function this.types.NoMotionValue(entry)
    return entry.motion_value == 0
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

this.sorted = table_util.keys(this.types)
table.sort(this.sorted)
return this
