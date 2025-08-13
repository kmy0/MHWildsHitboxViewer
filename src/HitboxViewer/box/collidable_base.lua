---@diagnostic disable: no-unknown

---@class (exact) CollidableBase : BoxBase
---@field parent Character
---@field collidable via.physics.Collidable
---@field shape via.physics.Shape
---@field userdata via.physics.UserData
---@field resource_idx integer
---@field set_idx integer
---@field collidable_idx integer

local box_base = require("HitboxViewer.box.box_base")
local data = require("HitboxViewer.data")

local rt = data.runtime
local ace = data.ace

---@class CollidableBase
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = box_base })

---@param collidable via.physics.Collidable
---@param parent Character
---@param box_type BoxType
---@param resource_idx integer
---@param set_idx integer
---@param collidable_idx integer
---@return CollidableBase?
function this:new(collidable, parent, box_type, resource_idx, set_idx, collidable_idx)
    local ok, shape = pcall(function()
        return collidable:get_TransformedShape()
    end)

    if not ok or not shape then
        return
    end

    local shape_name = ace.enum.shape[shape:get_ShapeType()]
    local shape_type = rt.enum.shape[shape_name]

    if not shape_type then
        return
    end

    local o = box_base.new(self, box_type, shape_type)
    setmetatable(o, self)
    ---@cast o CollidableBase
    o.collidable = collidable
    o.parent = parent
    o.shape = shape
    o.userdata = collidable:get_UserData()
    o.resource_idx = resource_idx
    o.set_idx = set_idx
    o.collidable_idx = collidable_idx
    return o
end

---@return BoxState
function this:update_shape()
    self.is_enabled = self.collidable:read_byte(0x10) ~= 0
    if self.is_enabled then
        if
            self.shape_type == rt.enum.shape.Capsule
            or self.shape_type == rt.enum.shape.Cylinder
            or self.shape_type == rt.enum.shape.ContinuousCapsule
        then
            self.shape_data.pos_a.x = self.shape:read_float(0x60)
            self.shape_data.pos_a.y = self.shape:read_float(0x64)
            self.shape_data.pos_a.z = self.shape:read_float(0x68)
            self.shape_data.pos_b.x = self.shape:read_float(0x70)
            self.shape_data.pos_b.y = self.shape:read_float(0x74)
            self.shape_data.pos_b.z = self.shape:read_float(0x78)
            self.shape_data.radius = self.shape:read_float(0x80)

            self.pos = (self.shape_data.pos_a + self.shape_data.pos_b) * 0.5
        elseif self.shape_type == rt.enum.shape.Sphere or self.shape_type == rt.enum.shape.ContinuousSphere then
            self.shape_data.pos.x = self.shape:read_float(0x60)
            self.shape_data.pos.y = self.shape:read_float(0x64)
            self.shape_data.pos.z = self.shape:read_float(0x68)
            self.shape_data.radius = self.shape:read_float(0x6c)

            self.pos = self.shape_data.pos
        elseif self.shape_type == rt.enum.shape.Box or self.shape_type == rt.enum.shape.Triangle then
            self.shape_data.pos.x = self.shape:read_float(0x90)
            self.shape_data.pos.y = self.shape:read_float(0x94)
            self.shape_data.pos.z = self.shape:read_float(0x98)
            self.shape_data.extent.x = self.shape:read_float(0xa0)
            self.shape_data.extent.y = self.shape:read_float(0xa4)
            self.shape_data.extent.z = self.shape:read_float(0xa8)
            self.shape_data.rot[0].x = self.shape:read_float(0x60)
            self.shape_data.rot[0].y = self.shape:read_float(0x64)
            self.shape_data.rot[0].z = self.shape:read_float(0x68)
            self.shape_data.rot[1].x = self.shape:read_float(0x70)
            self.shape_data.rot[1].y = self.shape:read_float(0x74)
            self.shape_data.rot[1].z = self.shape:read_float(0x78)
            self.shape_data.rot[2].x = self.shape:read_float(0x80)
            self.shape_data.rot[2].y = self.shape:read_float(0x84)
            self.shape_data.rot[2].z = self.shape:read_float(0x88)

            self.pos = self.shape_data.pos
        end

        self.distance = (rt.camera.origin - self.pos):length()
        return rt.enum.box_state.Draw
    end
    return rt.enum.box_state.None
end

---@return BoxState
function this:update()
    if self.collidable:get_reference_count() <= 1 then
        return rt.enum.box_state.Dead
    end
    return box_base.update(self)
end

return this
