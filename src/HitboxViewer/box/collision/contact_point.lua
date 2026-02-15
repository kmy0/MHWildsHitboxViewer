---@class ContactPoint : BoxBase
---@field draw_timer FrameTimer

local box_base = require("HitboxViewer.box.box_base")
local data = require("HitboxViewer.data.init")
local frame_timer = require("HitboxViewer.util.misc.frame_timer")

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
    o.draw_timer = frame_timer:new(draw_duration)
    o.draw_timer:start()

    return o
end

function this:remove()
    self.draw_timer:abort()
end

---@return BoxState
function this:update()
    if self.draw_timer:finished() or not self.draw_timer:active() then
        return mod_enum.box_state.Dead
    end

    return mod_enum.box_state.Draw
end

return this
