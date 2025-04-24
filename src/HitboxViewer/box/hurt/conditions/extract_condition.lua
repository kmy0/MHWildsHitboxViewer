---@class ExtractCondition : ConditionBase
---@field sub_type ExtractType

local condition_base = require("HitboxViewer.box.hurt.conditions.condition_base")
local data = require("HitboxViewer.data")

local rt = data.runtime
local rl = data.util.reverse_lookup

---@class ExtractCondition
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = condition_base })

---@param color integer?
---@param state ConditionState?
---@param key integer?
---@param sub_type ExtractType?
---@return ExtractCondition
function this:new(state, color, key, sub_type)
    local o = condition_base.new(self, rt.enum.condition_type.Extract, state, color, key)
    setmetatable(o, self)
    ---@cast o ExtractCondition
    o.sub_type = sub_type or rt.enum.extract.RED
    return o
end

---@param args table<string, any>
---@return ExtractCondition
function this:new_from_serial(args)
    return this.new(self, args.state, args.color, args.key, args.sub_type)
end

---@param part_group PartGroup
---@return ConditionResult, integer
function this:check(part_group)
    if rl(rt.enum.extract, self.sub_type) == part_group.part_data.extract then
        return self.state == rt.enum.condition_state.Highlight and rt.enum.condition_result.Highlight
            or rt.enum.condition_result.Hide,
            self.color
    end
    return rt.enum.condition_result.None, 0
end

return this
