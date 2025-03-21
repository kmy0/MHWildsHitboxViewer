local table_util = require "HitboxViewer.table_util"

local this = {
    ---@type string[]
    sorted = {}
}
---@type table<string, fun(entry: AttackLogEntry): boolean>
local types = {}

function types._TerrainHitOnly(entry)
    return entry.more_data._TerrainHitOnly
end

---@param entry AttackLogEntry
---@return string?
function this.check(entry)
    for _, key in ipairs(this.sorted) do
        if types[key](entry) then
            entry.misc_type = key
            return key
        end
    end
end

this.sorted = table_util.keys(types, true)
return this
