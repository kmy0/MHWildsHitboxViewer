---@class (exact) ConditionBase
---@field color integer
---@field state ConditionState
---@field type ConditionType
---@field key integer
---@field check fun(self: ConditionBase, part_data: PartGroup): ConditionResult, integer

local config = require("HitboxViewer.config")
local data = require("HitboxViewer.data")
local table_util = require("HitboxViewer.table_util")

local rt = data.mod

---@class ConditionBase
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this

---@param color integer?
---@param state ConditionState?
---@param type ConditionType
---@param key integer?
---@return ConditionBase
function this:new(type, state, color, key)
    local o = {
        color = color or config.default.hurtboxes.color.highlight,
        type = type,
        state = state or rt.enum.condition_state.Highlight,
        key = key or self:_get_key(),
    }
    setmetatable(o, self)
    ---@cast o ConditionBase
    return o
end

---@param args table<string, any>
---@return ConditionBase
function this:new_from_serial(args)
    return this.new(self, args.type, args.state, args.color, args.key)
end

---@protected
---@return integer
function this:_get_key()
    local keys = table_util.values(config.current.hurtboxes.conditions, function(o)
        return o.key
    end)
    ---@cast keys integer[]
    table.sort(keys, function(a, b)
        return a > b
    end)
    return keys[1] and keys[1] + 1 or 1
end

return this
