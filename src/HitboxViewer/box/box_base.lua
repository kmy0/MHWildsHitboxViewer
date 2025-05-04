---@class (exact) BoxBase
---@field is_enabled boolean
---@field sort integer
---@field pos Vector3f
---@field distance number
---@field color integer
---@field type BoxType
---@field shape_type ShapeType
---@field shape_data ShapeData
---@field update_shape fun(self: BoxBase): BoxState
---@field update_data fun(self: BoxBase): BoxState
---@field update fun(self: BoxBase): BoxState

---@class (exact) CylinderShape
---@field pos_a Vector3f
---@field pos_b Vector3f
---@field radius number

---@class (exact) SlicedCylinderShape : CylinderShape
---@field direction Vector3f
---@field degrees number

---@class (exact) BoxShape
---@field pos Vector3f
---@field extent Vector3f
---@field rot Matrix4x4f

---@class (exact) SphereShape
---@field pos Vector3f
---@field radius number

---@alias ShapeData CylinderShape | BoxShape | SphereShape | SlicedCylinderShape

local data = require("HitboxViewer.data")

local rt = data.runtime

---@class BoxBase
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this

---@param box_type BoxType
---@param shape_type ShapeType
---@return BoxBase
function this:new(box_type, shape_type)
    local shape_data = {}

    if
        shape_type == rt.enum.shape.Capsule
        or shape_type == rt.enum.shape.Cylinder
        or shape_type == rt.enum.shape.ContinuousCapsule
    then
        ---@cast shape_data CylinderShape
        shape_data.pos_a = Vector3f.new(0, 0, 0)
        shape_data.pos_b = Vector3f.new(0, 0, 0)
        shape_data.radius = 0
    elseif shape_type == rt.enum.shape.Sphere or shape_type == rt.enum.shape.ContinuousSphere then
        ---@cast shape_data SphereShape
        shape_data.pos = Vector3f.new(0, 0, 0)
        shape_data.radius = 0
    elseif shape_type == rt.enum.shape.Box or shape_type == rt.enum.shape.Triangle then
        ---@cast shape_data BoxShape
        shape_data.pos = Vector3f.new(0, 0, 0)
        shape_data.extent = Vector3f.new(0, 0, 0)
        shape_data.rot = Matrix4x4f.new(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1)
    elseif shape_type == rt.enum.shape.SlicedCylinder then
        ---@cast shape_data SlicedCylinderShape
        shape_data.pos_a = Vector3f.new(0, 0, 0)
        shape_data.pos_b = Vector3f.new(0, 0, 0)
        shape_data.radius = 0
        shape_data.degrees = 0
        shape_data.direction = Vector3f.new(0, 0, 0)
    end

    local o = {
        is_enabled = true,
        sort = 0,
        pos = Vector3f.new(0, 0, 0),
        distance = 0,
        color = 0,
        type = box_type,
        shape_type = shape_type,
        shape_data = shape_data,
    }
    ---@cast o BoxBase
    setmetatable(o, self)
    return o
end

---@return BoxState
function this:update()
    if self:update_data() == rt.enum.box_state.Draw and self:update_shape() == rt.enum.box_state.Draw then
        return rt.enum.box_state.Draw
    end
    return rt.enum.box_state.None
end

return this
