---@class DummyBox : BoxBase
---@field owner Character

local box_base = require("HitboxViewer.box.box_base")
local config = require("HitboxViewer.config.init")
local data = require("HitboxViewer.data.init")
local util_table = require("HitboxViewer.util.misc.table")

local mod_enum = data.mod.enum

local dummy_shapes = {
    ---@type SphereShape
    [mod_enum.shape.Sphere] = {
        pos = Vector3f.new(0, 1, 0),
        radius = 2,
    },
    ---@type CylinderShape
    [mod_enum.shape.Cylinder] = {
        pos_a = Vector3f.new(-1, 2, 0),
        pos_b = Vector3f.new(3, 1, 0),
        radius = 2,
    },
    ---@type CylinderShape
    [mod_enum.shape.Capsule] = {
        pos_a = Vector3f.new(-1, 2, 0),
        pos_b = Vector3f.new(3, 1, 0),
        radius = 2,
    },
    ---@type BoxShape
    [mod_enum.shape.Box] = {
        pos = Vector3f.new(0, 2, 0),
        extent = Vector3f.new(3, 1, 2),
        rot = Matrix4x4f.new(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1),
    },
    ---@type BoxShape
    [mod_enum.shape.Triangle] = {
        pos = Vector3f.new(0, 2, 0),
        extent = Vector3f.new(3, 1, 2),
        rot = Matrix4x4f.new(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1),
    },
    ---@type SlicedCylinderShape
    [mod_enum.shape.SlicedCylinder] = {
        pos_a = Vector3f.new(2.1, 2.5, 0),
        pos_b = Vector3f.new(2, 1, 0),
        radius = 2,
        degrees = 90,
        direction = Vector3f.new(0, 1, 0),
    },
}

---@class DummyBox
local this = {}
this.__index = this
setmetatable(this, { __index = box_base })

---@param shape_type ShapeType
---@param owner Character
---@return DummyBox
function this:new(shape_type, owner)
    local o = box_base.new(self, mod_enum.box.DummyBox, shape_type)
    ---@cast o DummyBox
    setmetatable(o, self)
    o.owner = owner
    local pos = owner:get_pos()

    o.shape_data = util_table.deep_copy(dummy_shapes[shape_type]) --[[@as ShapeData]]
    if
        o.shape_type == mod_enum.shape.Cylinder
        or o.shape_type == mod_enum.shape.Capsule
        or o.shape_type == mod_enum.shape.Donuts
        or o.shape_type == mod_enum.shape.SlicedCylinder
    then
        o.shape_data.pos_a = o.shape_data.pos_a + pos
        o.shape_data.pos_b = o.shape_data.pos_b + pos
        o.pos = (o.shape_data.pos_a + o.shape_data.pos_b) * 0.5
    else
        o.shape_data.pos = o.shape_data.pos + pos
        o.pos = o.shape_data.pos
    end

    return o
end

---@return boolean
function this:is_trail_disabled()
    return true
end

function this:update_data()
    self.color = config.current.mod.dummyboxes.color
    return mod_enum.box_state.Draw
end

function this:update_shape()
    local pos = self.owner:get_pos()
    if (self.pos - pos):length() > config.current.mod.draw.distance then
        return mod_enum.box_state.None
    end
    return mod_enum.box_state.Draw
end

return this
