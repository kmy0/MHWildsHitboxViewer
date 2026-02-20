---@class (exact) CollisionBox : CollidableBase
---@field timer Timer
---@field updated boolean
---@field contact_point ContactPoint?
---@field on_remove_callback fun(key: via.physics.Collidable | CollisionBox | ContactPoint, _: CollisionBox | ContactPoint)

local colldable_base = require("HitboxViewer.box.collidable_base")
local config = require("HitboxViewer.config.init")
local data = require("HitboxViewer.data.init")
local timer = require("HitboxViewer.util.misc.timer")

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
    o.timer = timer:new(draw_duration, nil, true, false, false, "time_delta")
    o.updated = false
    o.contact_point = contact_point
    o.disabled_ok = true
    o:update_data()
    o:update_shape()
    return o
end

---@return boolean
function this:is_trail_disabled()
    return true
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
    if self.updated and self.timer:finished() then
        return mod_enum.box_state.Dead
    end

    if not self.updated or not config.current.mod.collisionboxes.update_once then
        self:update_data()
        self:update_shape()
        self.updated = true
    end

    return mod_enum.box_state.Draw
end

---@param key via.physics.Collidable | CollisionBox | ContactPoint
---@param _ CollisionBox | ContactPoint
function this.on_remove_callback(key, _)
    if type(key) == "table" and key.type == mod_enum.box.CollisionBox then
        ---@cast key CollisionBox
        key:remove_contact_point()
    end
end

return this
