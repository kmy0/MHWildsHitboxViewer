---@class (exact) BoxBase
---@field is_enabled boolean
---@field sort integer
---@field pos Vector3f
---@field last_pos Vector3f
---@field distance number
---@field color integer
---@field outline_color nil
---@field draw_outline nil
---@field type BoxType
---@field shape_type ShapeType
---@field shape_data ShapeData
---@field trail_buffer CircularBuffer<TrailBox>
---@field any_trail boolean
---@field queue_dead_box_trail_update fun(col: via.physics.Collidable, box: BoxBase)

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

local call_queue = require("HitboxViewer.util.misc.call_queue")
local circular_buffer = require("HitboxViewer.util.misc.circular_buffer")
local config = require("HitboxViewer.config.init")
local data = require("HitboxViewer.data.init")
local draw_queue = require("HitboxViewer.draw_queue")
local trail_box = require("HitboxViewer.box.trail")
local util_table = require("HitboxViewer.util.misc.table")

local mod_enum = data.mod.enum

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
        shape_type == mod_enum.shape.Capsule
        or shape_type == mod_enum.shape.Cylinder
        or shape_type == mod_enum.shape.ContinuousCapsule
    then
        ---@cast shape_data CylinderShape
        shape_data.pos_a = Vector3f.new(0, 0, 0)
        shape_data.pos_b = Vector3f.new(0, 0, 0)
        shape_data.radius = 0
    elseif shape_type == mod_enum.shape.Sphere or shape_type == mod_enum.shape.ContinuousSphere then
        ---@cast shape_data SphereShape
        shape_data.pos = Vector3f.new(0, 0, 0)
        shape_data.radius = 0
    elseif shape_type == mod_enum.shape.Box or shape_type == mod_enum.shape.Triangle then
        ---@cast shape_data BoxShape
        shape_data.pos = Vector3f.new(0, 0, 0)
        shape_data.extent = Vector3f.new(0, 0, 0)
        shape_data.rot = Matrix4x4f.new(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1)
    elseif shape_type == mod_enum.shape.SlicedCylinder then
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
        trail_buffer = circular_buffer:new(
            math.ceil(config.max_trail_dur / config.current.mod.trailboxes.step)
        ),
        last_pos = Vector3f.new(0, 0, 0),
        any_trail = true,
    }
    ---@cast o BoxBase
    setmetatable(o, self)
    return o
end

---@return boolean
function this:is_trail_disabled()
    return false
end

---@return BoxState
function this:update_data()
    self.color = config.default_color
    return mod_enum.box_state.Draw
end

---@return BoxState
function this:update_shape()
    return mod_enum.box_state.Draw
end

---@return TrailBox[]?
function this:update_trail()
    local disabled = self:is_trail_disabled()
    if disabled and not self.any_trail then
        return
    end

    local ret = {}
    for _, box in ipairs(self.trail_buffer) do
        if box:update() == mod_enum.box_state.Dead then
            break
        end

        table.insert(ret, box)
    end

    local last_trail = self.trail_buffer:front() --[[@as TrailBox?]]
    if
        not disabled
        and (not last_trail or (last_trail.timer:elapsed() >= config.current.mod.trailboxes.step))
        and (self.last_pos - self.pos):length() > 0.1
    then
        self:add_trail()
        self.last_pos = self.pos:clone()
    end

    self.any_trail = not util_table.empty(ret)
    return ret
end

function this:add_trail()
    self.trail_buffer:push_front(trail_box:new(self, config.current.mod.trailboxes.draw_dur))
end

---@return BoxState
function this:update()
    if
        self:update_data() == mod_enum.box_state.Draw
        and self:update_shape() == mod_enum.box_state.Draw
    then
        return mod_enum.box_state.Draw
    end
    return mod_enum.box_state.None
end

---@param _ via.physics.Collidable
---@param box BoxBase
function this.queue_dead_box_trail_update(_, box)
    local function update()
        local trail = box:update_trail()
        if not box.any_trail then
            return false
        end

        draw_queue:extend(trail)
        return true
    end

    call_queue:push_back(update)
end

return this
