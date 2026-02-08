---@class ElementCondition : ConditionBase
---@field from integer
---@field to integer
---@field sub_type ElementType

local condition_base = require("HitboxViewer.box.hurt.conditions.condition_base")
local data = require("HitboxViewer.data.init")

local mod_enum = data.mod.enum

---@class ElementCondition
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = condition_base })

---@param color integer?
---@param state ConditionState?
---@param key integer?
---@param from integer?
---@param to integer?
---@param sub_type ElementType?
---@return ElementCondition
function this:new(state, color, key, sub_type, from, to)
    local o = condition_base.new(self, mod_enum.condition_type.Element, state, color, key)
    setmetatable(o, self)
    ---@cast o ElementCondition
    o.from = from or 0
    o.to = to or 300
    o.sub_type = sub_type or mod_enum.element.Slash
    return o
end

---@param args table<string, any>
---@return ElementCondition
function this:new_from_serial(args)
    return this.new(self, args.state, args.color, args.key, args.sub_type, args.from, args.to)
end

---@param part_group PartGroup
---@return ConditionResult, integer
function this:check(part_group)
    if self.sub_type ~= mod_enum.element.All then
        local value = part_group.part_data.hitzone[mod_enum.element[self.sub_type]]
        if value >= self.from and value <= self.to then
            return self.state == mod_enum.condition_state.Highlight
                    and mod_enum.condition_result.Highlight
                or mod_enum.condition_result.Hide,
                self.color
        end
    else
        for _, value in pairs(part_group.part_data.hitzone) do
            if value >= self.from and value <= self.to then
                return self.state == mod_enum.condition_state.Highlight
                        and mod_enum.condition_result.Highlight
                    or mod_enum.condition_result.Hide,
                    self.color
            end
        end
    end
    return mod_enum.condition_result.None, 0
end

return this
