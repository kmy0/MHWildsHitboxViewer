---@class ExtractCondition : ConditionBase
---@field sub_type ExtractType

local condition_base = require("HitboxViewer.box.hurt.conditions.condition_base")
local data = require("HitboxViewer.data.init")

local mod_enum = data.mod.enum

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
    local o = condition_base.new(self, mod_enum.condition_type.Extract, state, color, key)
    setmetatable(o, self)
    ---@cast o ExtractCondition
    o.sub_type = sub_type or mod_enum.extract.RED
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
    if mod_enum.extract[self.sub_type] == part_group.part_data.extract then
        return self.state == mod_enum.condition_state.Highlight
                and mod_enum.condition_result.Highlight
            or mod_enum.condition_result.Hide,
            self.color
    end
    return mod_enum.condition_result.None, 0
end

return this
