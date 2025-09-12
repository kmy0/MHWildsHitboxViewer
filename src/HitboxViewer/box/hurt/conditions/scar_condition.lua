---@class ScarCondition : ConditionBase
---@field sub_type ScarType

local condition_base = require("HitboxViewer.box.hurt.conditions.condition_base")
local data = require("HitboxViewer.data.init")
local game_data = require("HitboxViewer.util.game.data")

local mod = data.mod
local rl = game_data.reverse_lookup

---@class ScarCondition
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = condition_base })

---@param color integer?
---@param state ConditionState?
---@param key integer?
---@param sub_type ScarType?
---@return ScarCondition
function this:new(state, color, key, sub_type)
    local o = condition_base.new(self, mod.enum.condition_type.Scar, state, color, key)
    setmetatable(o, self)
    ---@cast o ScarCondition
    o.sub_type = sub_type or mod.enum.scar.RAW
    return o
end

---@param args table<string, any>
---@return ScarCondition
function this:new_from_serial(args)
    return this.new(self, args.state, args.color, args.key, args.sub_type)
end

---@param scar_state string
---@return ConditionResult, integer
function this:check(scar_state)
    local match = rl(mod.enum.scar, self.sub_type)
    if match == scar_state then
        return self.state == mod.enum.condition_state.Highlight
                and mod.enum.condition_result.Highlight
            or mod.enum.condition_result.Hide,
            self.color
    end
    return mod.enum.condition_result.None, 0
end

return this
