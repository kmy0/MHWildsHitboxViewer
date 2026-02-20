---@class DrawQueue
---@field protected _queue BoxBase[]
---@field protected _sorted boolean

local config = require("HitboxViewer.config.init")
local data = require("HitboxViewer.data.init")
local queue = require("HitboxViewer.util.misc.queue")

local mod_enum = data.mod.enum

---@class DrawQueue
local this = {
    _sorted = true,
    _queue = {},
}
table.insert(queue.instances, this)

---@param x BoxBase
---@param y BoxBase
---@return boolean
local function sort_boxes(x, y)
    if x.distance > y.distance then
        return true
    elseif x.distance == y.distance then
        return x.sort < y.sort
    end
    return false
end

---@param box BoxBase
local function draw_shape(box)
    local config_draw = config.current.mod.draw
    local outline = box.draw_outline == nil and config_draw.outline or box.draw_outline --[[@as boolean]]
    local outline_color = box.outline_color or config_draw.outline_color

    if
        box.shape_type == mod_enum.shape.Capsule
        or box.shape_type == mod_enum.shape.ContinuousCapsule
    then
        hb_draw.capsule(
            box.shape_data.pos_a,
            box.shape_data.pos_b,
            box.shape_data.radius,
            box.color,
            outline,
            outline_color
        )
    elseif
        box.shape_type == mod_enum.shape.Sphere
        or box.shape_type == mod_enum.shape.ContinuousSphere
    then
        hb_draw.sphere(box.shape_data.pos, box.shape_data.radius, box.color, outline, outline_color)
    elseif box.shape_type == mod_enum.shape.Box then
        hb_draw.box(
            box.shape_data.pos,
            box.shape_data.extent,
            box.shape_data.rot,
            box.color,
            outline,
            outline_color
        )
    elseif box.shape_type == mod_enum.shape.Cylinder then
        hb_draw.cylinder(
            box.shape_data.pos_a,
            box.shape_data.pos_b,
            box.shape_data.radius,
            box.color,
            outline,
            outline_color
        )
    elseif box.shape_type == mod_enum.shape.Triangle then
        hb_draw.triangle(
            box.shape_data.pos,
            box.shape_data.extent,
            box.shape_data.rot,
            box.color,
            outline,
            outline_color
        )
    elseif box.shape_type == mod_enum.shape.SlicedCylinder then
        hb_draw.sliced_cylinder(
            box.shape_data.pos_a,
            box.shape_data.pos_b,
            box.shape_data.radius,
            box.shape_data.direction,
            box.shape_data.degrees,
            box.color,
            outline,
            outline_color
        )
    end
end

---@param boxes BoxBase[]?
function this:extend(boxes)
    if boxes then
        table.move(boxes, 1, #boxes, #self._queue + 1, self._queue)
        self._sorted = false
    end
end

function this:sort()
    table.sort(self._queue, sort_boxes)
    self._sorted = true
end

function this:draw()
    if not self._sorted then
        self:sort()
    end

    for i = 1, #self._queue do
        local box = self._queue[i]
        box.sort = i
        draw_shape(box)
    end
end

function this:clear()
    self._queue = {}
end

return this
