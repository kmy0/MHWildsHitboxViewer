---@class BreakCondition : ConditionBase
---@field sub_type BreakType

local condition_base = require("HitboxViewer.box.hurt.conditions.condition_base")
local data = require("HitboxViewer.data.init")
local game_data = require("HitboxViewer.util.game.data")

local mod = data.mod
local rl = game_data.reverse_lookup

---@class BreakCondition
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = condition_base })

---@param color integer?
---@param state ConditionState?
---@param key integer?
---@param sub_type BreakType?
---@return BreakCondition
function this:new(state, color, key, sub_type)
    local o = condition_base.new(self, mod.enum.condition_type.Break, state, color, key)
    setmetatable(o, self)
    ---@cast o BreakCondition
    o.sub_type = sub_type or mod.enum.break_state.Yes
    return o
end

---@param args table<string, any>
---@return BreakCondition
function this:new_from_serial(args)
    return this.new(self, args.state, args.color, args.key, args.sub_type)
end

---@param part_group PartGroup
---@return ConditionResult, integer
function this:check(part_group)
    local match = (
        part_group.part_data.can_break and (part_group.part_data.is_broken and "Broken" or "Yes")
    ) or "No"
    if match == rl(mod.enum.break_state, self.sub_type) then
        return self.state == mod.enum.condition_state.Highlight
                and mod.enum.condition_result.Highlight
            or mod.enum.condition_result.Hide,
            self.color
    end
    return mod.enum.condition_result.None, 0
end

return this
