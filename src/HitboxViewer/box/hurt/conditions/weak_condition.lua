---@class WeakCondition : ConditionBase

local condition_base = require("HitboxViewer.box.hurt.conditions.condition_base")
local data = require("HitboxViewer.data.init")

local mod_enum = data.mod.enum

---@class WeakCondition
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = condition_base })

---@param color integer?
---@param state ConditionState?
---@param key integer?
---@return WeakCondition
function this:new(state, color, key)
    local o = condition_base.new(self, mod_enum.condition_type.Weak, state, color, key)
    setmetatable(o, self)
    ---@cast o WeakCondition
    return o
end

---@param args table<string, any>
---@return WeakCondition
function this:new_from_serial(args)
    return this.new(self, args.state, args.color, args.key)
end

---@param part_group PartGroup
---@return ConditionResult, integer
function this:check(part_group)
    if part_group.part_data.is_weak then
        return self.state == mod_enum.condition_state.Highlight
                and mod_enum.condition_result.Highlight
            or mod_enum.condition_result.Hide,
            self.color
    end
    return mod_enum.condition_result.None, 0
end

return this
