---@class ScarCondition : ConditionBase
---@field sub_type ScarType

local condition_base = require("HitboxViewer.box.hurt.conditions.condition_base")
local data = require("HitboxViewer.data.init")

local mod_enum = data.mod.enum

---@class ScarCondition
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = condition_base })

---@param color integer?
---@param state ConditionState?
---@param key integer?
---@param sub_type ScarType?
---@param trail CheckboxTri
---@return ScarCondition
function this:new(state, color, key, sub_type, trail)
    local o = condition_base.new(self, mod_enum.condition_type.Scar, state, color, key, trail)
    setmetatable(o, self)
    ---@cast o ScarCondition
    o.sub_type = sub_type or mod_enum.scar.RAW
    return o
end

---@param args table<string, any>
---@return ScarCondition
function this:new_from_serial(args)
    return this.new(self, args.state, args.color, args.key, args.sub_type, args.trail)
end

---@param scar_state string
---@return ConditionResult, integer
function this:check(scar_state)
    local match = mod_enum.scar[self.sub_type]
    if match == scar_state then
        return self.state == mod_enum.condition_state.Highlight
                and mod_enum.condition_result.Highlight
            or mod_enum.condition_result.Hide,
            self.color
    end
    return mod_enum.condition_result.None, 0
end

return this
