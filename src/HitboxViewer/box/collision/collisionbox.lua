---@class (exact) CollisionBox : CollidableBase
---@field draw_timer FrameTimer
---@field updated boolean
---@field contact_point ContactPoint?

local colldable_base = require("HitboxViewer.box.collidable_base")
local config = require("HitboxViewer.config.init")
local data = require("HitboxViewer.data.init")
local frame_timer = require("HitboxViewer.util.misc.frame_timer")

local mod_enum = data.mod.enum

---@class CollisionBox
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = colldable_base })

---@param collidable via.physics.Collidable
---@param color integer
---@param draw_duration integer
---@param contact_point ContactPoint?
---@return CollisionBox?
function this:new(collidable, color, draw_duration, contact_point)
    ---@diagnostic disable-next-line: param-type-mismatch
    local o = colldable_base.new(self, collidable, nil, mod_enum.box.CollisionBox, nil, nil, nil)

    if not o then
        return
    end

    ---@cast o CollisionBox
    setmetatable(o, self)

    o.color = color
    o.draw_timer = frame_timer:new(draw_duration)
    o.draw_timer:start()
    o.updated = false
    o.contact_point = contact_point
    o.disabled_ok = true
    o:update()
    return o
end

function this:remove_contact_point()
    if self.contact_point then
        self.contact_point:remove()
    end
end

---@return BoxState
function this:update_data()
    return mod_enum.box_state.Draw
end

---@return BoxState
function this:update()
    if not self.updated or not config.current.mod.collisionboxes.update_once then
        self:update_data()
        self:update_shape()
        self.updated = true
    end

    if self.draw_timer:finished() then
        return mod_enum.box_state.Dead
    end

    return mod_enum.box_state.Draw
end

return this
