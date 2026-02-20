---@class ContactPoint : BoxBase
---@field timer Timer
---@field updated boolean

local box_base = require("HitboxViewer.box.box_base")
local data = require("HitboxViewer.data.init")
local timer = require("HitboxViewer.util.misc.timer")

local mod_enum = data.mod.enum

---@class ContactPoint
local this = {}
this.__index = this
setmetatable(this, { __index = box_base })

---@param pos Vector3f
---@param radius number
---@param color integer
---@param draw_duration integer
---@return ContactPoint
function this:new(pos, radius, color, draw_duration)
    local o = box_base.new(self, mod_enum.box.CollisionContactBox, mod_enum.shape.Sphere)
    ---@cast o ContactPoint
    setmetatable(o, self)

    o.shape_data.pos = pos
    o.shape_data.radius = radius
    o.color = color
    o.timer = timer:new(draw_duration, nil, true, false, false, "time_delta")
    o.updated = false

    return o
end

function this:is_trail_disabled()
    return true
end

function this:remove()
    self.timer:abort()
end

---@return BoxState
function this:update()
    if self.updated and self.timer:finished() or not self.timer:active() then
        return mod_enum.box_state.Dead
    end

    self.updated = true
    return mod_enum.box_state.Draw
end

return this
