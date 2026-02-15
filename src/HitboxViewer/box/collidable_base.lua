---@diagnostic disable: no-unknown

---@class (exact) CollidableBase : BoxBase
---@field parent Character
---@field collidable via.physics.Collidable
---@field shape via.physics.Shape
---@field userdata via.physics.UserData
---@field resource_idx integer
---@field set_idx integer
---@field collidable_idx integer
---@field ptr_shape integer
---@field ptr_collidable integer
---@field disabled_ok boolean

local box_base = require("HitboxViewer.box.box_base")
local data = require("HitboxViewer.data.init")
local e = require("HitboxViewer.util.game.enum")
local util_game = require("HitboxViewer.util.game.init")
local util_misc = require("HitboxViewer.util.misc.init")

local mod_enum = data.mod.enum

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
    ---@type via.physics.Shape?
    local shape
    util_misc.try(function()
        shape = collidable:get_TransformedShape()
    end)

    if not shape then
        return
    end

    local shape_name = e.get("via.physics.ShapeType")[shape:get_ShapeType()]
    local shape_type = mod_enum.shape[shape_name]

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
    o.ptr_shape = shape:get_address()
    o.ptr_collidable = collidable:get_address()
    o.disabled_ok = false
    return o
end

---@return BoxState
function this:update_shape()
    self.is_enabled = hb_draw.read_byte(self.ptr_collidable + 0x10) ~= 0
    if self.is_enabled or self.disabled_ok then
        if
            self.shape_type == mod_enum.shape.Capsule
            or self.shape_type == mod_enum.shape.Cylinder
            or self.shape_type == mod_enum.shape.ContinuousCapsule
        then
            self.shape_data.pos_a.x = hb_draw.read_float(self.ptr_shape + 0x60)
            self.shape_data.pos_a.y = hb_draw.read_float(self.ptr_shape + 0x64)
            self.shape_data.pos_a.z = hb_draw.read_float(self.ptr_shape + 0x68)
            self.shape_data.pos_b.x = hb_draw.read_float(self.ptr_shape + 0x70)
            self.shape_data.pos_b.y = hb_draw.read_float(self.ptr_shape + 0x74)
            self.shape_data.pos_b.z = hb_draw.read_float(self.ptr_shape + 0x78)
            self.shape_data.radius = hb_draw.read_float(self.ptr_shape + 0x80)

            self.pos = (self.shape_data.pos_a + self.shape_data.pos_b) * 0.5
        elseif
            self.shape_type == mod_enum.shape.Sphere
            or self.shape_type == mod_enum.shape.ContinuousSphere
        then
            self.shape_data.pos.x = hb_draw.read_float(self.ptr_shape + 0x60)
            self.shape_data.pos.y = hb_draw.read_float(self.ptr_shape + 0x64)
            self.shape_data.pos.z = hb_draw.read_float(self.ptr_shape + 0x68)
            self.shape_data.radius = hb_draw.read_float(self.ptr_shape + 0x6c)

            self.pos = self.shape_data.pos
        elseif
            self.shape_type == mod_enum.shape.Box or self.shape_type == mod_enum.shape.Triangle
        then
            self.shape_data.pos.x = hb_draw.read_float(self.ptr_shape + 0x90)
            self.shape_data.pos.y = hb_draw.read_float(self.ptr_shape + 0x94)
            self.shape_data.pos.z = hb_draw.read_float(self.ptr_shape + 0x98)
            self.shape_data.extent.x = hb_draw.read_float(self.ptr_shape + 0xa0)
            self.shape_data.extent.y = hb_draw.read_float(self.ptr_shape + 0xa4)
            self.shape_data.extent.z = hb_draw.read_float(self.ptr_shape + 0xa8)
            self.shape_data.rot[0].x = hb_draw.read_float(self.ptr_shape + 0x60)
            self.shape_data.rot[0].y = hb_draw.read_float(self.ptr_shape + 0x64)
            self.shape_data.rot[0].z = hb_draw.read_float(self.ptr_shape + 0x68)
            self.shape_data.rot[1].x = hb_draw.read_float(self.ptr_shape + 0x70)
            self.shape_data.rot[1].y = hb_draw.read_float(self.ptr_shape + 0x74)
            self.shape_data.rot[1].z = hb_draw.read_float(self.ptr_shape + 0x78)
            self.shape_data.rot[2].x = hb_draw.read_float(self.ptr_shape + 0x80)
            self.shape_data.rot[2].y = hb_draw.read_float(self.ptr_shape + 0x84)
            self.shape_data.rot[2].z = hb_draw.read_float(self.ptr_shape + 0x88)

            self.pos = self.shape_data.pos
        end

        self.distance = (util_game.get_camera_origin() - self.pos):length()
        return mod_enum.box_state.Draw
    end
    return mod_enum.box_state.None
end

---@return BoxState
function this:update()
    if self.collidable:get_reference_count() <= 1 then
        return mod_enum.box_state.Dead
    end
    return box_base.update(self)
end

return this
